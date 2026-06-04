using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.DTOs
{
    public class CreateTratamientoDTO
    {
        public int? RecetaId { get; set; }
        [Required] public int MedicamentoId { get; set; }
        [Required] public string Dosis { get; set; } = string.Empty;
        [Required] public int FrecuenciaHoras { get; set; }
        [Required] public int DuracionDias { get; set; }
        [Required] public DateTime FechaInicio { get; set; }
        public string? Notas { get; set; }
    }

    public class TratamientoResponseDTO
    {
        public int Id { get; set; }
        public int? RecetaId { get; set; }
        public int MedicamentoId { get; set; }
        public string MedicamentoNombre { get; set; } = string.Empty;
        public string Dosis { get; set; } = string.Empty;
        public int FrecuenciaHoras { get; set; }
        public int DuracionDias { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Notas { get; set; }
        public int TotalTomas { get; set; }
        public int TomasTomadas { get; set; }
        public int TomasPendientes { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class TomaResponseDTO
    {
        public int Id { get; set; }
        public int TratamientoId { get; set; }
        public string MedicamentoNombre { get; set; } = string.Empty;
        public string Dosis { get; set; } = string.Empty;
        public DateTime HoraProgramada { get; set; }
        public DateTime? HoraTomada { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool DescontadoInventario { get; set; }
    }

    public class ConfirmarTomaDTO
    {
        public DateTime? HoraTomada { get; set; }
    }
}