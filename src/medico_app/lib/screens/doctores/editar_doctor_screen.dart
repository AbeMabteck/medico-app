import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/consulta_model.dart';
import '../../services/doctor_service.dart';

class EditarDoctorScreen extends StatefulWidget {
  final DoctorModel doctor;

  const EditarDoctorScreen({super.key, required this.doctor});

  @override
  State<EditarDoctorScreen> createState() => _EditarDoctorScreenState();
}

class _EditarDoctorScreenState extends State<EditarDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _consultorioCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _service = DoctorService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = widget.doctor.nombre;
    _especialidadCtrl.text = widget.doctor.especialidad ?? '';
    _consultorioCtrl.text = widget.doctor.consultorio ?? '';
    _telefonoCtrl.text = widget.doctor.telefono ?? '';
    _notasCtrl.text = widget.doctor.notas ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especialidadCtrl.dispose();
    _consultorioCtrl.dispose();
    _telefonoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.updateDoctor(
        widget.doctor.id,
        nombre: _nombreCtrl.text.trim(),
        especialidad: _especialidadCtrl.text.trim(),
        consultorio: _consultorioCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        notas: _notasCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Doctor actualizado correctamente'),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar doctor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _especialidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Especialidad (opcional)',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _consultorioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Consultorio (opcional)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notasCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
