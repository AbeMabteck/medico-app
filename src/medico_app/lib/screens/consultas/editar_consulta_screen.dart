import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/consulta_model.dart';
import '../../services/consulta_service.dart';

class EditarConsultaScreen extends StatefulWidget {
  final ConsultaModel consulta;

  const EditarConsultaScreen({super.key, required this.consulta});

  @override
  State<EditarConsultaScreen> createState() => _EditarConsultaScreenState();
}

class _EditarConsultaScreenState extends State<EditarConsultaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _sintomasCtrl = TextEditingController();
  final _diagCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _service = ConsultaService();

  DateTime _fecha = DateTime.now();
  DoctorModel? _doctorSeleccionado;
  List<DoctorModel> _doctores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _motivoCtrl.text = widget.consulta.motivo ?? '';
    _sintomasCtrl.text = widget.consulta.sintomas ?? '';
    _diagCtrl.text = widget.consulta.diagnostico ?? '';
    _notasCtrl.text = widget.consulta.notas ?? '';
    _fecha = widget.consulta.fecha;
    _loadDoctores();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _sintomasCtrl.dispose();
    _diagCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctores() async {
    try {
      final doctores = await _service.getDoctores();
      setState(() {
        _doctores = doctores;
        _doctorSeleccionado = doctores.firstWhere(
          (d) => d.id == widget.consulta.doctorId,
          orElse: () => doctores.first,
        );
      });
    } catch (_) {}
  }

  Future<void> _selectFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.updateConsulta(
        id: widget.consulta.id,
        fecha: _fecha,
        doctorId: _doctorSeleccionado?.id,
        motivo: _motivoCtrl.text.trim(),
        sintomas: _sintomasCtrl.text.trim(),
        diagnostico: _diagCtrl.text.trim(),
        notas: _notasCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Consulta actualizada correctamente'),
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
      appBar: AppBar(title: const Text('Editar consulta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fecha
              GestureDetector(
                onTap: _selectFecha,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de consulta',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_fecha),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Doctor
              DropdownButtonFormField<DoctorModel>(
                value: _doctorSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Doctor (opcional)',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                items: _doctores
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text(d.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _doctorSeleccionado = v),
              ),
              const SizedBox(height: 16),

              // Motivo
              TextFormField(
                controller: _motivoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motivo de consulta',
                  prefixIcon: Icon(Icons.info_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa el motivo' : null,
              ),
              const SizedBox(height: 16),

              // Síntomas
              TextFormField(
                controller: _sintomasCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Síntomas',
                  prefixIcon: Icon(Icons.sick_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Diagnóstico
              TextFormField(
                controller: _diagCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico',
                  prefixIcon: Icon(Icons.assignment_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notasCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
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
