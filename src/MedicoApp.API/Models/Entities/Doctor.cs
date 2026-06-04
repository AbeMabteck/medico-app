using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.Entities
{
    public class Doctor
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        [Required] public string Nombre { get; set; } = string.Empty;
        public string? Especialidad { get; set; }
        public string? Consultorio { get; set; }
        public string? Telefono { get; set; }
        public string? Notas { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User User { get; set; } = null!;
        public ICollection<Consulta> Consultas { get; set; } = new List<Consulta>();
    }
}