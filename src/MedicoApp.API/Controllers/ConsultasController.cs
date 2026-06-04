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
    public class ConsultasController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ConsultasController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var consultas = await _context.Consultas
                .Include(c => c.Doctor)
                .Include(c => c.Recetas)
                .Where(c => c.UserId == userId)
                .OrderByDescending(c => c.Fecha)
                .Select(c => new ConsultaResponseDTO
                {
                    Id = c.Id,
                    DoctorId = c.DoctorId,
                    DoctorNombre = c.Doctor != null ? c.Doctor.Nombre : null,
                    DoctorEspecialidad = c.Doctor != null ? c.Doctor.Especialidad : null,
                    Fecha = c.Fecha,
                    Motivo = c.Motivo,
                    Sintomas = c.Sintomas,
                    Diagnostico = c.Diagnostico,
                    Notas = c.Notas,
                    CreatedAt = c.CreatedAt,
                    Recetas = c.Recetas.Select(r => new RecetaResponseDTO
                    {
                        Id = r.Id,
                        ConsultaId = r.ConsultaId,
                        FotoPath = r.FotoPath,
                        Notas = r.Notas,
                        CreatedAt = r.CreatedAt
                    }).ToList()
                })
                .ToListAsync();

            return Ok(consultas);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var consulta = await _context.Consultas
                .Include(c => c.Doctor)
                .Include(c => c.Recetas)
                .Where(c => c.Id == id && c.UserId == userId)
                .Select(c => new ConsultaResponseDTO
                {
                    Id = c.Id,
                    DoctorId = c.DoctorId,
                    DoctorNombre = c.Doctor != null ? c.Doctor.Nombre : null,
                    DoctorEspecialidad = c.Doctor != null ? c.Doctor.Especialidad : null,
                    Fecha = c.Fecha,
                    Motivo = c.Motivo,
                    Sintomas = c.Sintomas,
                    Diagnostico = c.Diagnostico,
                    Notas = c.Notas,
                    CreatedAt = c.CreatedAt,
                    Recetas = c.Recetas.Select(r => new RecetaResponseDTO
                    {
                        Id = r.Id,
                        ConsultaId = r.ConsultaId,
                        FotoPath = r.FotoPath,
                        Notas = r.Notas,
                        CreatedAt = r.CreatedAt
                    }).ToList()
                })
                .FirstOrDefaultAsync();

            if (consulta == null) return NotFound();
            return Ok(consulta);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateConsultaDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var consulta = new Consulta
            {
                UserId = userId,
                DoctorId = dto.DoctorId,
                Fecha = dto.Fecha,
                Motivo = dto.Motivo,
                Sintomas = dto.Sintomas,
                Diagnostico = dto.Diagnostico,
                Notas = dto.Notas
            };

            _context.Consultas.Add(consulta);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = consulta.Id }, new ConsultaResponseDTO
            {
                Id = consulta.Id,
                DoctorId = consulta.DoctorId,
                Fecha = consulta.Fecha,
                Motivo = consulta.Motivo,
                Sintomas = consulta.Sintomas,
                Diagnostico = consulta.Diagnostico,
                Notas = consulta.Notas,
                CreatedAt = consulta.CreatedAt
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateConsultaDTO dto)
        {
            var userId = GetUserId();
            var consulta = await _context.Consultas
                .FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId);

            if (consulta == null) return NotFound();

            if (dto.DoctorId != null) consulta.DoctorId = dto.DoctorId;
            if (dto.Fecha != null) consulta.Fecha = dto.Fecha.Value;
            if (dto.Motivo != null) consulta.Motivo = dto.Motivo;
            if (dto.Sintomas != null) consulta.Sintomas = dto.Sintomas;
            if (dto.Diagnostico != null) consulta.Diagnostico = dto.Diagnostico;
            if (dto.Notas != null) consulta.Notas = dto.Notas;

            consulta.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var consulta = await _context.Consultas
                .FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId);

            if (consulta == null) return NotFound();

            _context.Consultas.Remove(consulta);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}