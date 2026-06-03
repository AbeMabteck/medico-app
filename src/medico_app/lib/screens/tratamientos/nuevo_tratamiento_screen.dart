import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/inventario_model.dart';
import '../../services/inventario_service.dart';
import '../../services/tratamiento_service.dart';
import '../../services/notification_service.dart';

class NuevoTratamientoScreen extends StatefulWidget {
  const NuevoTratamientoScreen({super.key});

  @override
  State<NuevoTratamientoScreen> createState() => _NuevoTratamientoScreenState();
}

class _NuevoTratamientoScreenState extends State<NuevoTratamientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dosisCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _tratamientoService = TratamientoService();
  final _inventarioService = InventarioService();

  List<MedicamentoCatalogoModel> _catalogo = [];
  MedicamentoCatalogoModel? _medicamentoSeleccionado;
  int _frecuenciaHoras = 8;
  int _duracionDias = 7;
  DateTime _fechaInicio = DateTime.now();
  bool _isLoading = false;

  final List<int> _frecuencias = [4, 6, 8, 12, 24];
  final List<int> _duraciones = [1, 3, 5, 7, 10, 14, 21, 30];

  @override
  void initState() {
    super.initState();
    _loadCatalogo();
  }

  @override
  void dispose() {
    _dosisCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogo() async {
    try {
      final catalogo = await _inventarioService.getCatalogo();
      setState(() => _catalogo = catalogo);
    } catch (_) {}
  }

  Future<void> _selectFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fechaInicio = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medicamentoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un medicamento'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _tratamientoService.createTratamiento(
        medicamentoId: _medicamentoSeleccionado!.id,
        dosis: _dosisCtrl.text.trim(),
        frecuenciaHoras: _frecuenciaHoras,
        duracionDias: _duracionDias,
        fechaInicio: _fechaInicio,
        notas: _notasCtrl.text.trim(),
      );

      if (mounted) {
        // Obtener tomas y programar notificaciones
        final tomas = await _tratamientoService.getTomas(result['id']);
        await NotificationService().programarTodasLasTomas(
          tratamientoId: result['id'],
          medicamento: _medicamentoSeleccionado!.nombre,
          dosis: _dosisCtrl.text.trim(),
          horasProgramadas: tomas.map((t) => t.horaProgramada).toList(),
        );

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Tratamiento creado con ${result['tomasGeneradas']} tomas y notificaciones programadas',
            ),
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
      appBar: AppBar(title: const Text('Nuevo tratamiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicamento
              DropdownButtonFormField<MedicamentoCatalogoModel>(
                value: _medicamentoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                items: _catalogo
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text('${m.nombre} ${m.concentracion ?? ''}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _medicamentoSeleccionado = v),
                validator: (v) =>
                    v == null ? 'Selecciona un medicamento' : null,
              ),
              const SizedBox(height: 16),

              // Dosis
              TextFormField(
                controller: _dosisCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosis (ej: 1 tableta)',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa la dosis' : null,
              ),
              const SizedBox(height: 16),

              // Frecuencia
              DropdownButtonFormField<int>(
                value: _frecuenciaHoras,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: _frecuencias
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text('Cada $f horas'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _frecuenciaHoras = v!),
              ),
              const SizedBox(height: 16),

              // Duración
              DropdownButtonFormField<int>(
                value: _duracionDias,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                items: _duraciones
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text('$d días')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _duracionDias = v!),
              ),
              const SizedBox(height: 16),

              // Fecha inicio
              GestureDetector(
                onTap: _selectFechaInicio,
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
                            'Fecha de inicio',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                            style: const TextStyle(
                              fontSize: 15,
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

              // Notas
              TextFormField(
                controller: _notasCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Resumen
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Se generarán ${(_duracionDias * 24 / _frecuenciaHoras).ceil()} tomas programadas',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
                    : const Text('Crear tratamiento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
