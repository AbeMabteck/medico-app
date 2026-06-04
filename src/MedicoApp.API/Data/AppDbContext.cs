using MedicoApp.API.Models.Entities;
using Microsoft.EntityFrameworkCore;
using System.Numerics;

namespace MedicoApp.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Doctor> Doctors { get; set; }
        public DbSet<Consulta> Consultas { get; set; }
        public DbSet<Receta> Recetas { get; set; }
        public DbSet<MedicamentoCatalogo> MedicamentosCatalogo { get; set; }
        public DbSet<Inventario> Inventario { get; set; }
        public DbSet<Tratamiento> Tratamientos { get; set; }
        public DbSet<Toma> Tomas { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<Doctor>().ToTable("Doctors");
            modelBuilder.Entity<Consulta>().ToTable("Consultas");
            modelBuilder.Entity<Receta>().ToTable("Recetas");
            modelBuilder.Entity<MedicamentoCatalogo>().ToTable("MedicamentosCatalogo");
            modelBuilder.Entity<Inventario>().ToTable("Inventario");
            modelBuilder.Entity<Tratamiento>().ToTable("Tratamientos");
            modelBuilder.Entity<Toma>().ToTable("Tomas");
        }
    }
}