import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/consulta_model.dart';
import '../../services/doctor_service.dart';
import 'nuevo_doctor_screen.dart';
import 'editar_doctor_screen.dart';

class DoctoresScreen extends StatefulWidget {
  const DoctoresScreen({super.key});

  @override
  State<DoctoresScreen> createState() => _DoctoresScreenState();
}

class _DoctoresScreenState extends State<DoctoresScreen> {
  final _service = DoctorService();
  List<DoctorModel> _doctores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctores();
  }

  Future<void> _loadDoctores() async {
    setState(() => _isLoading = true);
    try {
      final doctores = await _service.getDoctores();
      setState(() => _doctores = doctores);
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDoctor(int id) async {
    try {
      await _service.deleteDoctor(id);
      _loadDoctores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor eliminado correctamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctores.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _loadDoctores,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _doctores.length,
                itemBuilder: (context, index) => _buildCard(_doctores[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevoDoctorScreen()),
          );
          if (result == true) _loadDoctores();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outlined,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay doctores registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca el botón + para agregar uno',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.person_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (doctor.especialidad != null)
                    Text(
                      doctor.especialidad!,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  if (doctor.consultorio != null)
                    Text(
                      doctor.consultorio!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  if (doctor.telefono != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.telefono!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Botón editar
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppTheme.primaryColor,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarDoctorScreen(doctor: doctor),
                  ),
                );
                if (result == true) _loadDoctores();
              },
              tooltip: 'Editar',
            ),
            // Botón eliminar
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar doctor'),
                  content: const Text('¿Estás seguro de eliminar este doctor?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteDoctor(doctor.id);
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
