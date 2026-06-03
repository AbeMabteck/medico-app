namespace MedicoApp.API.Models.Entities
{
    public class Receta
    {
        public int Id { get; set; }
        public int ConsultaId { get; set; }
        public string? FotoPath { get; set; }
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Consulta Consulta { get; set; } = null!;
        public ICollection<Tratamiento> Tratamientos { get; set; } = new List<Tratamiento>();
    }
}