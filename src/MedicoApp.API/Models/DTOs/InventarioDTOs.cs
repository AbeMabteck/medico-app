using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.DTOs
{
    public class CreateInventarioDTO
    {
        [Required] public int MedicamentoId { get; set; }
        [Required] public int CantidadActual { get; set; }
        public int CantidadMinima { get; set; } = 5;
        public string Unidad { get; set; } = "tabletas";
        public DateTime? FechaCaducidad { get; set; }
        public string? LugarCompra { get; set; }
        public decimal? Precio { get; set; }
    }

    public class UpdateInventarioDTO
    {
        public int? CantidadActual { get; set; }
        public int? CantidadMinima { get; set; }
        public string? Unidad { get; set; }
        public DateTime? FechaCaducidad { get; set; }
        public string? LugarCompra { get; set; }
        public decimal? Precio { get; set; }
        public string? Status { get; set; }
    }

    public class InventarioResponseDTO
    {
        public int Id { get; set; }
        public int MedicamentoId { get; set; }
        public string MedicamentoNombre { get; set; } = string.Empty;
        public string? MedicamentoPresentacion { get; set; }
        public string? MedicamentoConcentracion { get; set; }
        public int CantidadActual { get; set; }
        public int CantidadMinima { get; set; }
        public string Unidad { get; set; } = string.Empty;
        public DateTime? FechaCaducidad { get; set; }
        public string? LugarCompra { get; set; }
        public decimal? Precio { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool StockBajo { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class MedicamentoCatalogoDTO
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? NombreGenerico { get; set; }
        public string? Presentacion { get; set; }
        public string? Concentracion { get; set; }
    }
}