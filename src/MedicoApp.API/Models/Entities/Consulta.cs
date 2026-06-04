using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.Entities
{
    public class Consulta
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? DoctorId { get; set; }
        [Required] public DateTime Fecha { get; set; }
        public string? Motivo { get; set; }
        public string? Sintomas { get; set; }
        public string? Diagnostico { get; set; }
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User User { get; set; } = null!;
        public Doctor? Doctor { get; set; }
        public ICollection<Receta> Recetas { get; set; } = new List<Receta>();
    }
}