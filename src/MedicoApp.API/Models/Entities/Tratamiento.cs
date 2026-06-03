using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.Entities
{
    public class Tratamiento
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? RecetaId { get; set; }
        public int MedicamentoId { get; set; }
        [Required] public string Dosis { get; set; } = string.Empty;
        public int FrecuenciaHoras { get; set; }
        public int DuracionDias { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }
        [Required] public string Status { get; set; } = "activo";
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User User { get; set; } = null!;
        public Receta? Receta { get; set; }
        public MedicamentoCatalogo Medicamento { get; set; } = null!;
        public ICollection<Toma> Tomas { get; set; } = new List<Toma>();
    }
}