using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.DTOs
{
    public class CreateConsultaDTO
    {
        public int? DoctorId { get; set; }
        [Required] public DateTime Fecha { get; set; }
        public string? Motivo { get; set; }
        public string? Sintomas { get; set; }
        public string? Diagnostico { get; set; }
        public string? Notas { get; set; }
    }

    public class UpdateConsultaDTO
    {
        public int? DoctorId { get; set; }
        public DateTime? Fecha { get; set; }
        public string? Motivo { get; set; }
        public string? Sintomas { get; set; }
        public string? Diagnostico { get; set; }
        public string? Notas { get; set; }
    }

    public class ConsultaResponseDTO
    {
        public int Id { get; set; }
        public int? DoctorId { get; set; }
        public string? DoctorNombre { get; set; }
        public string? DoctorEspecialidad { get; set; }
        public DateTime Fecha { get; set; }
        public string? Motivo { get; set; }
        public string? Sintomas { get; set; }
        public string? Diagnostico { get; set; }
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<RecetaResponseDTO> Recetas { get; set; } = new();
    }

    public class CreateRecetaDTO
    {
        [Required] public int ConsultaId { get; set; }
        public string? Notas { get; set; }
    }

    public class RecetaResponseDTO
    {
        public int Id { get; set; }
        public int ConsultaId { get; set; }
        public string? FotoPath { get; set; }
        public string? Notas { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}