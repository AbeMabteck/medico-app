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
    public class InventarioController : ControllerBase
    {
        private readonly AppDbContext _context;

        public InventarioController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var inventario = await _context.Inventario
                .Include(i => i.Medicamento)
                .Where(i => i.UserId == userId)
                .Select(i => new InventarioResponseDTO
                {
                    Id = i.Id,
                    MedicamentoId = i.MedicamentoId,
                    MedicamentoNombre = i.Medicamento.Nombre,
                    MedicamentoPresentacion = i.Medicamento.Presentacion,
                    MedicamentoConcentracion = i.Medicamento.Concentracion,
                    CantidadActual = i.CantidadActual,
                    CantidadMinima = i.CantidadMinima,
                    Unidad = i.Unidad,
                    FechaCaducidad = i.FechaCaducidad,
                    LugarCompra = i.LugarCompra,
                    Precio = i.Precio,
                    Status = i.Status,
                    StockBajo = i.CantidadActual <= i.CantidadMinima,
                    UpdatedAt = i.UpdatedAt
                })
                .ToListAsync();

            return Ok(inventario);
        }

        [HttpGet("stock-bajo")]
        public async Task<IActionResult> GetStockBajo()
        {
            var userId = GetUserId();
            var inventario = await _context.Inventario
                .Include(i => i.Medicamento)
                .Where(i => i.UserId == userId && i.CantidadActual <= i.CantidadMinima)
                .Select(i => new InventarioResponseDTO
                {
                    Id = i.Id,
                    MedicamentoId = i.MedicamentoId,
                    MedicamentoNombre = i.Medicamento.Nombre,
                    MedicamentoPresentacion = i.Medicamento.Presentacion,
                    MedicamentoConcentracion = i.Medicamento.Concentracion,
                    CantidadActual = i.CantidadActual,
                    CantidadMinima = i.CantidadMinima,
                    Unidad = i.Unidad,
                    FechaCaducidad = i.FechaCaducidad,
                    LugarCompra = i.LugarCompra,
                    Precio = i.Precio,
                    Status = i.Status,
                    StockBajo = true,
                    UpdatedAt = i.UpdatedAt
                })
                .ToListAsync();

            return Ok(inventario);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var item = await _context.Inventario
                .Include(i => i.Medicamento)
                .Where(i => i.Id == id && i.UserId == userId)
                .Select(i => new InventarioResponseDTO
                {
                    Id = i.Id,
                    MedicamentoId = i.MedicamentoId,
                    MedicamentoNombre = i.Medicamento.Nombre,
                    MedicamentoPresentacion = i.Medicamento.Presentacion,
                    MedicamentoConcentracion = i.Medicamento.Concentracion,
                    CantidadActual = i.CantidadActual,
                    CantidadMinima = i.CantidadMinima,
                    Unidad = i.Unidad,
                    FechaCaducidad = i.FechaCaducidad,
                    LugarCompra = i.LugarCompra,
                    Precio = i.Precio,
                    Status = i.Status,
                    StockBajo = i.CantidadActual <= i.CantidadMinima,
                    UpdatedAt = i.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateInventarioDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();

            var medicamento = await _context.MedicamentosCatalogo
                .FindAsync(dto.MedicamentoId);
            if (medicamento == null)
                return BadRequest(new { message = "Medicamento no encontrado en el catálogo." });

            var yaExiste = await _context.Inventario
                .AnyAsync(i => i.UserId == userId && i.MedicamentoId == dto.MedicamentoId);
            if (yaExiste)
                return BadRequest(new { message = "Este medicamento ya está en tu inventario." });

            var item = new Inventario
            {
                UserId = userId,
                MedicamentoId = dto.MedicamentoId,
                CantidadActual = dto.CantidadActual,
                CantidadMinima = dto.CantidadMinima,
                Unidad = dto.Unidad,
                FechaCaducidad = dto.FechaCaducidad,
                LugarCompra = dto.LugarCompra,
                Precio = dto.Precio,
                Status = dto.CantidadActual > 0 ? "disponible" : "agotado"
            };

            _context.Inventario.Add(item);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = item.Id }, new { item.Id, message = "Medicamento agregado al inventario." });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateInventarioDTO dto)
        {
            var userId = GetUserId();
            var item = await _context.Inventario
                .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);

            if (item == null) return NotFound();

            if (dto.CantidadActual != null) item.CantidadActual = dto.CantidadActual.Value;
            if (dto.CantidadMinima != null) item.CantidadMinima = dto.CantidadMinima.Value;
            if (dto.Unidad != null) item.Unidad = dto.Unidad;
            if (dto.FechaCaducidad != null) item.FechaCaducidad = dto.FechaCaducidad;
            if (dto.LugarCompra != null) item.LugarCompra = dto.LugarCompra;
            if (dto.Precio != null) item.Precio = dto.Precio;

            // Actualizar status automáticamente
            item.Status = item.CantidadActual == 0 ? "agotado" :
                          item.FechaCaducidad.HasValue && item.FechaCaducidad.Value < DateTime.UtcNow ? "vencido" :
                          item.FechaCaducidad.HasValue && item.FechaCaducidad.Value < DateTime.UtcNow.AddDays(30) ? "por_vencer" :
                          "disponible";

            if (dto.Status != null) item.Status = dto.Status;

            item.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var item = await _context.Inventario
                .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);

            if (item == null) return NotFound();

            _context.Inventario.Remove(item);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpGet("catalogo")]
        public async Task<IActionResult> GetCatalogo()
        {
            var catalogo = await _context.MedicamentosCatalogo
                .Select(m => new MedicamentoCatalogoDTO
                {
                    Id = m.Id,
                    Nombre = m.Nombre,
                    NombreGenerico = m.NombreGenerico,
                    Presentacion = m.Presentacion,
                    Concentracion = m.Concentracion
                })
                .ToListAsync();

            return Ok(catalogo);
        }

        [HttpPost("catalogo")]
        public async Task<IActionResult> CreateCatalogo([FromBody] MedicamentoCatalogoDTO dto)
        {
            var medicamento = new MedicamentoCatalogo
            {
                Nombre = dto.Nombre,
                NombreGenerico = dto.NombreGenerico,
                Presentacion = dto.Presentacion,
                Concentracion = dto.Concentracion
            };

            _context.MedicamentosCatalogo.Add(medicamento);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCatalogo), new { id = medicamento.Id }, medicamento);
        }
    }
}