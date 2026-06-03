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
    public class RecetasController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _env;

        public RecetasController(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpPost]
        public async Task<IActionResult> Create([FromForm] CreateRecetaDTO dto, IFormFile? foto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();

            // Verificar que la consulta pertenece al usuario
            var consulta = await _context.Consultas
                .FirstOrDefaultAsync(c => c.Id == dto.ConsultaId && c.UserId == userId);

            if (consulta == null) return NotFound(new { message = "Consulta no encontrada." });

            string? fotoPath = null;

            if (foto != null && foto.Length > 0)
            {
                var uploadsFolder = Path.Combine(_env.ContentRootPath, "Uploads", "Recetas");
                Directory.CreateDirectory(uploadsFolder);

                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(foto.FileName)}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using var stream = new FileStream(filePath, FileMode.Create);
                await foto.CopyToAsync(stream);

                fotoPath = $"/uploads/recetas/{fileName}";
            }

            var receta = new Receta
            {
                ConsultaId = dto.ConsultaId,
                FotoPath = fotoPath,
                Notas = dto.Notas
            };

            _context.Recetas.Add(receta);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = receta.Id }, new RecetaResponseDTO
            {
                Id = receta.Id,
                ConsultaId = receta.ConsultaId,
                FotoPath = receta.FotoPath,
                Notas = receta.Notas,
                CreatedAt = receta.CreatedAt
            });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var receta = await _context.Recetas
                .Include(r => r.Consulta)
                .Where(r => r.Id == id && r.Consulta.UserId == userId)
                .Select(r => new RecetaResponseDTO
                {
                    Id = r.Id,
                    ConsultaId = r.ConsultaId,
                    FotoPath = r.FotoPath,
                    Notas = r.Notas,
                    CreatedAt = r.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (receta == null) return NotFound();
            return Ok(receta);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var receta = await _context.Recetas
                .Include(r => r.Consulta)
                .FirstOrDefaultAsync(r => r.Id == id && r.Consulta.UserId == userId);

            if (receta == null) return NotFound();

            // Eliminar archivo físico si existe
            if (!string.IsNullOrEmpty(receta.FotoPath))
            {
                var filePath = Path.Combine(_env.ContentRootPath, receta.FotoPath.TrimStart('/'));
                if (System.IO.File.Exists(filePath))
                    System.IO.File.Delete(filePath);
            }

            _context.Recetas.Remove(receta);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}