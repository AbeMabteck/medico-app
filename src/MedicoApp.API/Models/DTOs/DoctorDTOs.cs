using System.ComponentModel.DataAnnotations;

namespace MedicoApp.API.Models.DTOs
{
    public class CreateDoctorDTO
    {
        [Required] public string Nombre { get; set; } = string.Empty;
        public string? Especialidad { get; set; }
        public string? Consultorio { get; set; }
        public string? Telefono { get; set; }
        public string? Notas { get; set; }
    }

    public class UpdateDoctorDTO
    {
        public string? Nombre { get; set; }
        public string? Especialidad { get; set; }
        public string? Consultorio { get; set; }
        public string? Telefono { get; set; }
        public string? Notas { get; set; }
        public bool? Activo { get; set; }
    }

    public class DoctorResponseDTO
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Especialidad { get; set; }
        public string? Consultorio { get; set; }
        public string? Telefono { get; set; }
        public string? Notas { get; set; }
        public bool Activo { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}