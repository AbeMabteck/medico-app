using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.Entities
{
    public class MedicamentoCatalogo
    {
        public int Id { get; set; }
        [Required] public string Nombre { get; set; } = string.Empty;
        public string? NombreGenerico { get; set; }
        public string? Presentacion { get; set; }
        public string? Concentracion { get; set; }
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Inventario> Inventarios { get; set; } = new List<Inventario>();
        public ICollection<Tratamiento> Tratamientos { get; set; } = new List<Tratamiento>();
    }
}