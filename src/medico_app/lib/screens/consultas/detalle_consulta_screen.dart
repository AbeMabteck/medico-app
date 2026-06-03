import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_theme.dart';
import '../../models/consulta_model.dart';
import '../../services/receta_service.dart';

class DetalleConsultaScreen extends StatefulWidget {
  final ConsultaModel consulta;

  const DetalleConsultaScreen({super.key, required this.consulta});

  @override
  State<DetalleConsultaScreen> createState() => _DetalleConsultaScreenState();
}

class _DetalleConsultaScreenState extends State<DetalleConsultaScreen> {
  final _recetaService = RecetaService();
  final _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _subirFoto() async {
    final opcion = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (opcion == null) return;

    final picked = await _picker.pickImage(source: opcion, imageQuality: 80);

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      await _recetaService.subirReceta(
        consultaId: widget.consulta.id,
        foto: File(picked.path),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Receta subida correctamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de consulta'),
        actions: [
          IconButton(
            icon: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add_a_photo_outlined),
            onPressed: _isUploading ? null : _subirFoto,
            tooltip: 'Agregar receta',
          ),
        ],
      ),
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
                  value: DateFormat('dd/MM/yyyy').format(widget.consulta.fecha),
                ),
                if (widget.consulta.doctorNombre != null) ...[
                  const Divider(),
                  _buildRow(
                    icon: Icons.person_outlined,
                    label: 'Doctor',
                    value: widget.consulta.doctorNombre!,
                  ),
                ],
                if (widget.consulta.doctorEspecialidad != null) ...[
                  const Divider(),
                  _buildRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Especialidad',
                    value: widget.consulta.doctorEspecialidad!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            if (widget.consulta.motivo != null)
              _buildSection(
                title: 'Motivo de consulta',
                icon: Icons.info_outlined,
                content: widget.consulta.motivo!,
              ),

            if (widget.consulta.sintomas != null)
              _buildSection(
                title: 'Síntomas',
                icon: Icons.sick_outlined,
                content: widget.consulta.sintomas!,
              ),

            if (widget.consulta.diagnostico != null)
              _buildSection(
                title: 'Diagnóstico',
                icon: Icons.assignment_outlined,
                content: widget.consulta.diagnostico!,
              ),

            if (widget.consulta.notas != null)
              _buildSection(
                title: 'Notas',
                icon: Icons.notes_outlined,
                content: widget.consulta.notas!,
              ),

            // Recetas
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recetas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isUploading ? null : _subirFoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.consulta.recetas.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'No hay recetas adjuntas',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...widget.consulta.recetas.map(
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
