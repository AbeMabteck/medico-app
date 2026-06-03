import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/consulta_model.dart';

class DetalleConsultaScreen extends StatelessWidget {
  final ConsultaModel consulta;

  const DetalleConsultaScreen({super.key, required this.consulta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de consulta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha y doctor
            _buildCard(
              children: [
                _buildRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value: DateFormat('dd/MM/yyyy').format(consulta.fecha),
                ),
                if (consulta.doctorNombre != null) ...[
                  const Divider(),
                  _buildRow(
                    icon: Icons.person_outlined,
                    label: 'Doctor',
                    value: consulta.doctorNombre!,
                  ),
                ],
                if (consulta.doctorEspecialidad != null) ...[
                  const Divider(),
                  _buildRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Especialidad',
                    value: consulta.doctorEspecialidad!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Motivo
            if (consulta.motivo != null)
              _buildSection(
                title: 'Motivo de consulta',
                icon: Icons.info_outlined,
                content: consulta.motivo!,
              ),

            // Síntomas
            if (consulta.sintomas != null)
              _buildSection(
                title: 'Síntomas',
                icon: Icons.sick_outlined,
                content: consulta.sintomas!,
              ),

            // Diagnóstico
            if (consulta.diagnostico != null)
              _buildSection(
                title: 'Diagnóstico',
                icon: Icons.assignment_outlined,
                content: consulta.diagnostico!,
              ),

            // Notas
            if (consulta.notas != null)
              _buildSection(
                title: 'Notas',
                icon: Icons.notes_outlined,
                content: consulta.notas!,
              ),

            // Recetas
            if (consulta.recetas.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Recetas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...consulta.recetas.map(
                (r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text('Receta #${r.id}'),
                    subtitle: r.notas != null ? Text(r.notas!) : null,
                    trailing: r.fotoPath != null
                        ? const Icon(
                            Icons.image_outlined,
                            color: AppTheme.successColor,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
