namespace MedicoApp.API.Models.DTOs
{
    public class UpdatePerfilDTO
    {
        public string? Nombre { get; set; }
        public string? Telefono { get; set; }
        public string? TipoSangre { get; set; }
        public DateTime? FechaNacimiento { get; set; }
    }
}