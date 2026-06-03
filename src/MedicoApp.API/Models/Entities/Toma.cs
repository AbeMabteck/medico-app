namespace MedicoApp.API.Models.Entities
{
    public class Toma
    {
        public int Id { get; set; }
        public int TratamientoId { get; set; }
        public DateTime HoraProgramada { get; set; }
        public DateTime? HoraTomada { get; set; }
        public string Status { get; set; } = "pendiente";
        public bool DescontadoInventario { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Tratamiento Tratamiento { get; set; } = null!;
    }
}