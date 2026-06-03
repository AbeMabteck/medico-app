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
    public class DoctoresController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DoctoresController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var doctores = await _context.Doctors
                .Where(d => d.UserId == userId)
                .Select(d => new DoctorResponseDTO
                {
                    Id = d.Id,
                    Nombre = d.Nombre,
                    Especialidad = d.Especialidad,
                    Consultorio = d.Consultorio,
                    Telefono = d.Telefono,
                    Notas = d.Notas,
                    Activo = d.Activo,
                    CreatedAt = d.CreatedAt
                })
                .ToListAsync();

            return Ok(doctores);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var doctor = await _context.Doctors
                .Where(d => d.Id == id && d.UserId == userId)
                .Select(d => new DoctorResponseDTO
                {
                    Id = d.Id,
                    Nombre = d.Nombre,
                    Especialidad = d.Especialidad,
                    Consultorio = d.Consultorio,
                    Telefono = d.Telefono,
                    Notas = d.Notas,
                    Activo = d.Activo,
                    CreatedAt = d.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (doctor == null) return NotFound();
            return Ok(doctor);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateDoctorDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var doctor = new Doctor
            {
                UserId = userId,
                Nombre = dto.Nombre,
                Especialidad = dto.Especialidad,
                Consultorio = dto.Consultorio,
                Telefono = dto.Telefono,
                Notas = dto.Notas
            };

            _context.Doctors.Add(doctor);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = doctor.Id }, new DoctorResponseDTO
            {
                Id = doctor.Id,
                Nombre = doctor.Nombre,
                Especialidad = doctor.Especialidad,
                Consultorio = doctor.Consultorio,
                Telefono = doctor.Telefono,
                Notas = doctor.Notas,
                Activo = doctor.Activo,
                CreatedAt = doctor.CreatedAt
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateDoctorDTO dto)
        {
            var userId = GetUserId();
            var doctor = await _context.Doctors
                .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

            if (doctor == null) return NotFound();

            if (dto.Nombre != null) doctor.Nombre = dto.Nombre;
            if (dto.Especialidad != null) doctor.Especialidad = dto.Especialidad;
            if (dto.Consultorio != null) doctor.Consultorio = dto.Consultorio;
            if (dto.Telefono != null) doctor.Telefono = dto.Telefono;
            if (dto.Notas != null) doctor.Notas = dto.Notas;
            if (dto.Activo != null) doctor.Activo = dto.Activo.Value;

            doctor.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var doctor = await _context.Doctors
                .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

            if (doctor == null) return NotFound();

            doctor.Activo = false;
            doctor.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}