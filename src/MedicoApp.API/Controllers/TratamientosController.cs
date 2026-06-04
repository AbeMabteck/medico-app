using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using MedicoApp.API.Data;
using MedicoApp.API.Models.DTOs;
using MedicoApp.API.Models.Entities;

namespace MedicoApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TratamientosController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TratamientosController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var tratamientos = await _context.Tratamientos
                .Include(t => t.Medicamento)
                .Include(t => t.Tomas)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .Select(t => new TratamientoResponseDTO
                {
                    Id = t.Id,
                    RecetaId = t.RecetaId,
                    MedicamentoId = t.MedicamentoId,
                    MedicamentoNombre = t.Medicamento.Nombre,
                    Dosis = t.Dosis,
                    FrecuenciaHoras = t.FrecuenciaHoras,
                    DuracionDias = t.DuracionDias,
                    FechaInicio = t.FechaInicio,
                    FechaFin = t.FechaFin,
                    Status = t.Status,
                    Notas = t.Notas,
                    TotalTomas = t.Tomas.Count,
                    TomasTomadas = t.Tomas.Count(to => to.Status == "tomada"),
                    TomasPendientes = t.Tomas.Count(to => to.Status == "pendiente"),
                    CreatedAt = t.CreatedAt
                })
                .ToListAsync();

            return Ok(tratamientos);
        }

        [HttpGet("activos")]
        public async Task<IActionResult> GetActivos()
        {
            var userId = GetUserId();
            var tratamientos = await _context.Tratamientos
                .Include(t => t.Medicamento)
                .Include(t => t.Tomas)
                .Where(t => t.UserId == userId && t.Status == "activo")
                .Select(t => new TratamientoResponseDTO
                {
                    Id = t.Id,
                    RecetaId = t.RecetaId,
                    MedicamentoId = t.MedicamentoId,
                    MedicamentoNombre = t.Medicamento.Nombre,
                    Dosis = t.Dosis,
                    FrecuenciaHoras = t.FrecuenciaHoras,
                    DuracionDias = t.DuracionDias,
                    FechaInicio = t.FechaInicio,
                    FechaFin = t.FechaFin,
                    Status = t.Status,
                    Notas = t.Notas,
                    TotalTomas = t.Tomas.Count,
                    TomasTomadas = t.Tomas.Count(to => to.Status == "tomada"),
                    TomasPendientes = t.Tomas.Count(to => to.Status == "pendiente"),
                    CreatedAt = t.CreatedAt
                })
                .ToListAsync();

            return Ok(tratamientos);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var tratamiento = await _context.Tratamientos
                .Include(t => t.Medicamento)
                .Include(t => t.Tomas)
                .Where(t => t.Id == id && t.UserId == userId)
                .Select(t => new TratamientoResponseDTO
                {
                    Id = t.Id,
                    RecetaId = t.RecetaId,
                    MedicamentoId = t.MedicamentoId,
                    MedicamentoNombre = t.Medicamento.Nombre,
                    Dosis = t.Dosis,
                    FrecuenciaHoras = t.FrecuenciaHoras,
                    DuracionDias = t.DuracionDias,
                    FechaInicio = t.FechaInicio,
                    FechaFin = t.FechaFin,
                    Status = t.Status,
                    Notas = t.Notas,
                    TotalTomas = t.Tomas.Count,
                    TomasTomadas = t.Tomas.Count(to => to.Status == "tomada"),
                    TomasPendientes = t.Tomas.Count(to => to.Status == "pendiente"),
                    CreatedAt = t.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (tratamiento == null) return NotFound();
            return Ok(tratamiento);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateTratamientoDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();

            var medicamento = await _context.MedicamentosCatalogo.FindAsync(dto.MedicamentoId);
            if (medicamento == null)
                return BadRequest(new { message = "Medicamento no encontrado." });

            var fechaFin = dto.FechaInicio.AddDays(dto.DuracionDias);

            var tratamiento = new Tratamiento
            {
                UserId = userId,
                RecetaId = dto.RecetaId,
                MedicamentoId = dto.MedicamentoId,
                Dosis = dto.Dosis,
                FrecuenciaHoras = dto.FrecuenciaHoras,
                DuracionDias = dto.DuracionDias,
                FechaInicio = dto.FechaInicio,
                FechaFin = fechaFin,
                Status = "activo",
                Notas = dto.Notas
            };

            _context.Tratamientos.Add(tratamiento);
            await _context.SaveChangesAsync();

            // Generar tomas automáticamente
            var tomas = new List<Toma>();
            var horaToma = dto.FechaInicio;

            while (horaToma <= fechaFin)
            {
                tomas.Add(new Toma
                {
                    TratamientoId = tratamiento.Id,
                    HoraProgramada = horaToma,
                    Status = "pendiente"
                });
                horaToma = horaToma.AddHours(dto.FrecuenciaHoras);
            }

            _context.Tomas.AddRange(tomas);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = tratamiento.Id }, new
            {
                tratamiento.Id,
                TomasGeneradas = tomas.Count,
                message = $"Tratamiento creado con {tomas.Count} tomas programadas."
            });
        }

        [HttpPut("{id}/cancelar")]
        public async Task<IActionResult> Cancelar(int id)
        {
            var userId = GetUserId();
            var tratamiento = await _context.Tratamientos
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (tratamiento == null) return NotFound();

            tratamiento.Status = "cancelado";
            tratamiento.UpdatedAt = DateTime.UtcNow;

            // Cancelar tomas pendientes
            var tomasPendientes = await _context.Tomas
                .Where(t => t.TratamientoId == id && t.Status == "pendiente")
                .ToListAsync();

            foreach (var toma in tomasPendientes)
                toma.Status = "omitida";

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("{id}/tomas")]
        public async Task<IActionResult> GetTomas(int id)
        {
            var userId = GetUserId();

            var tratamiento = await _context.Tratamientos
                .Include(t => t.Medicamento)
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (tratamiento == null) return NotFound();

            var tomas = await _context.Tomas
                .Where(t => t.TratamientoId == id)
                .OrderBy(t => t.HoraProgramada)
                .Select(t => new TomaResponseDTO
                {
                    Id = t.Id,
                    TratamientoId = t.TratamientoId,
                    MedicamentoNombre = tratamiento.Medicamento.Nombre,
                    Dosis = tratamiento.Dosis,
                    HoraProgramada = t.HoraProgramada,
                    HoraTomada = t.HoraTomada,
                    Status = t.Status,
                    DescontadoInventario = t.DescontadoInventario
                })
                .ToListAsync();

            return Ok(tomas);
        }

        [HttpPost("tomas/{tomaId}/confirmar")]
        public async Task<IActionResult> ConfirmarToma(int tomaId, [FromBody] ConfirmarTomaDTO dto)
        {
            var userId = GetUserId();

            var toma = await _context.Tomas
                .Include(t => t.Tratamiento)
                .FirstOrDefaultAsync(t => t.Id == tomaId && t.Tratamiento.UserId == userId);

            if (toma == null) return NotFound();
            if (toma.Status == "tomada")
                return BadRequest(new { message = "Esta toma ya fue confirmada." });

            toma.Status = "tomada";
            toma.HoraTomada = dto.HoraTomada ?? DateTime.UtcNow;

            // Descontar del inventario
            if (!toma.DescontadoInventario)
            {
                var inventario = await _context.Inventario
                    .FirstOrDefaultAsync(i =>
                        i.UserId == userId &&
                        i.MedicamentoId == toma.Tratamiento.MedicamentoId);

                if (inventario != null && inventario.CantidadActual > 0)
                {
                    inventario.CantidadActual--;
                    inventario.Status = inventario.CantidadActual == 0 ? "agotado" :
                                          inventario.CantidadActual <= inventario.CantidadMinima ? "disponible" : "disponible";
                    inventario.UpdatedAt = DateTime.UtcNow;
                    toma.DescontadoInventario = true;
                }
            }

            // Verificar si todas las tomas están completadas
            var todasCompletadas = await _context.Tomas
                .Where(t => t.TratamientoId == toma.TratamientoId)
                .AllAsync(t => t.Status == "tomada" || t.Status == "omitida");

            if (todasCompletadas)
            {
                toma.Tratamiento.Status = "completado";
                toma.Tratamiento.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Toma confirmada correctamente.", DescontadoInventario = toma.DescontadoInventario });
        }

        [HttpPost("tomas/{tomaId}/omitir")]
        public async Task<IActionResult> OmitirToma(int tomaId)
        {
            var userId = GetUserId();

            var toma = await _context.Tomas
                .Include(t => t.Tratamiento)
                .FirstOrDefaultAsync(t => t.Id == tomaId && t.Tratamiento.UserId == userId);

            if (toma == null) return NotFound();
            if (toma.Status == "tomada")
                return BadRequest(new { message = "Esta toma ya fue confirmada y no puede omitirse." });

            toma.Status = "omitida";
            await _context.SaveChangesAsync();

            return Ok(new { message = "Toma omitida." });
        }

        [HttpGet("tomas/proximas")]
        public async Task<IActionResult> GetProximasTomas()
        {
            var userId = GetUserId();
            var ahora = DateTime.UtcNow;
            var limite = ahora.AddHours(24);

            var tomas = await _context.Tomas
                .Include(t => t.Tratamiento)
                    .ThenInclude(t => t.Medicamento)
                .Where(t =>
                    t.Tratamiento.UserId == userId &&
                    t.Status == "pendiente" &&
                    t.HoraProgramada >= ahora &&
                    t.HoraProgramada <= limite)
                .OrderBy(t => t.HoraProgramada)
                .Select(t => new TomaResponseDTO
                {
                    Id = t.Id,
                    TratamientoId = t.TratamientoId,
                    MedicamentoNombre = t.Tratamiento.Medicamento.Nombre,
                    Dosis = t.Tratamiento.Dosis,
                    HoraProgramada = t.HoraProgramada,
                    HoraTomada = t.HoraTomada,
                    Status = t.Status,
                    DescontadoInventario = t.DescontadoInventario
                })
                .ToListAsync();

            return Ok(tomas);
        }
    }
}