using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using MedicoApp.API.Data;
using MedicoApp.API.Models.DTOs;

namespace MedicoApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PerfilController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PerfilController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<IActionResult> GetPerfil()
        {
            var userId = GetUserId();
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return NotFound();

            return Ok(new
            {
                user.Id,
                user.Nombre,
                user.Email,
                user.Telefono,
                user.FechaNacimiento,
                user.TipoSangre,
                user.CreatedAt
            });
        }

        [HttpPut]
        public async Task<IActionResult> UpdatePerfil([FromBody] UpdatePerfilDTO dto)
        {
            var userId = GetUserId();
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return NotFound();

            if (dto.Nombre != null) user.Nombre = dto.Nombre;
            if (dto.Telefono != null) user.Telefono = dto.Telefono;
            if (dto.TipoSangre != null) user.TipoSangre = dto.TipoSangre;
            if (dto.FechaNacimiento != null) user.FechaNacimiento = dto.FechaNacimiento;

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}