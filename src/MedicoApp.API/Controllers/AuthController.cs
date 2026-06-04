using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicoApp.API.Data;
using MedicoApp.API.Models.DTOs;
using MedicoApp.API.Models.Entities;
using MedicoApp.API.Helpers;

namespace MedicoApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly JwtHelper _jwtHelper;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _jwtHelper = new JwtHelper(configuration);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
                return BadRequest(new { message = "El email ya está registrado." });

            var user = new User
            {
                Nombre = dto.Nombre,
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Telefono = dto.Telefono,
                FechaNacimiento = dto.FechaNacimiento,
                TipoSangre = dto.TipoSangre
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var token = _jwtHelper.GenerateToken(user);

            return Ok(new AuthResponseDTO
            {
                Token = token,
                Nombre = user.Nombre,
                Email = user.Email,
                Expiration = DateTime.UtcNow.AddHours(24)
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email && u.Activo);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized(new { message = "Credenciales incorrectas." });

            var token = _jwtHelper.GenerateToken(user);

            return Ok(new AuthResponseDTO
            {
                Token = token,
                Nombre = user.Nombre,
                Email = user.Email,
                Expiration = DateTime.UtcNow.AddHours(24)
            });
        }
    }
}