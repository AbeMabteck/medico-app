import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/tratamiento_model.dart';
import '../../services/tratamiento_service.dart';

class DetalleTratamientoScreen extends StatefulWidget {
  final TratamientoModel tratamiento;

  const DetalleTratamientoScreen({super.key, required this.tratamiento});

  @override
  State<DetalleTratamientoScreen> createState() =>
      _DetalleTratamientoScreenState();
}

class _DetalleTratamientoScreenState extends State<DetalleTratamientoScreen> {
  final _service = TratamientoService();
  List<TomaModel> _tomas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTomas();
  }

  Future<void> _loadTomas() async {
    setState(() => _isLoading = true);
    try {
      final tomas = await _service.getTomas(widget.tratamiento.id);
      setState(() => _tomas = tomas);
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

  Future<void> _confirmarToma(int tomaId) async {
    try {
      await _service.confirmarToma(tomaId);
      _loadTomas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Toma confirmada e inventario actualizado'),
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

  Future<void> _omitirToma(int tomaId) async {
    try {
      await _service.omitirToma(tomaId);
      _loadTomas();
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

  Future<void> _cancelarTratamiento() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar tratamiento'),
        content: const Text('¿Estás seguro de cancelar este tratamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.cancelarTratamiento(widget.tratamiento.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Color _getTomaColor(String status) {
    switch (status) {
      case 'tomada':
        return AppTheme.successColor;
      case 'omitida':
        return AppTheme.errorColor;
      case 'retrasada':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getTomaIcon(String status) {
    switch (status) {
      case 'tomada':
        return Icons.check_circle;
      case 'omitida':
        return Icons.cancel;
      case 'retrasada':
        return Icons.warning;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tratamiento;
    final progreso = t.totalTomas > 0 ? t.tomasTomadas / t.totalTomas : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.medicamentoNombre),
        actions: [
          if (t.status == 'activo')
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _cancelarTratamiento,
              tooltip: 'Cancelar tratamiento',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat('Dosis', t.dosis),
                              _buildStat(
                                'Frecuencia',
                                'Cada ${t.frecuenciaHoras}h',
                              ),
                              _buildStat('Duración', '${t.duracionDias} días'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progreso
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${t.tomasTomadas}/${t.totalTomas} tomas',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${(progreso * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progreso,
                            backgroundColor: AppTheme.textSecondary.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(t.fechaInicio),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(t.fechaFin),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tomas
                  const Text(
                    'Tomas programadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._tomas.map(
                    (toma) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getTomaIcon(toma.status),
                          color: _getTomaColor(toma.status),
                        ),
                        title: Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(toma.horaProgramada.toLocal()),
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: toma.horaTomada != null
                            ? Text(
                                'Tomada: ${DateFormat('HH:mm').format(toma.horaTomada!.toLocal())}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                ),
                              )
                            : null,
                        trailing: toma.status == 'pendiente'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: AppTheme.successColor,
                                    ),
                                    onPressed: () => _confirmarToma(toma.id),
                                    tooltip: 'Confirmar toma',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: AppTheme.errorColor,
                                    ),
                                    onPressed: () => _omitirToma(toma.id),
                                    tooltip: 'Omitir toma',
                                  ),
                                ],
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
