using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.Entities
{
    public class Inventario
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MedicamentoId { get; set; }
        public int CantidadActual { get; set; } = 0;
        public int CantidadMinima { get; set; } = 5;
        [Required] public string Unidad { get; set; } = "tabletas";
        public DateTime? FechaCaducidad { get; set; }
        public string? LugarCompra { get; set; }
        public decimal? Precio { get; set; }
        [Required] public string Status { get; set; } = "disponible";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User User { get; set; } = null!;
        public MedicamentoCatalogo Medicamento { get; set; } = null!;
    }
}