using System.ComponentModel.DataAnnotations;
using System.Numerics;

namespace MedicoApp.API.Models.Entities
{
    public class User
    {
        public int Id { get; set; }
        [Required] public string Nombre { get; set; } = string.Empty;
        [Required] public string Email { get; set; } = string.Empty;
        [Required] public string PasswordHash { get; set; } = string.Empty;
        public string? Telefono { get; set; }
        public DateTime? FechaNacimiento { get; set; }
        public string? TipoSangre { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Doctor> Doctors { get; set; } = new List<Doctor>();
        public ICollection<Consulta> Consultas { get; set; } = new List<Consulta>();
        public ICollection<Inventario> Inventario { get; set; } = new List<Inventario>();
        public ICollection<Tratamiento> Tratamientos { get; set; } = new List<Tratamiento>();
    }
}