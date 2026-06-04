import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../models/tratamiento_model.dart';
import '../models/inventario_model.dart';
import '../services/tratamiento_service.dart';
import '../services/inventario_service.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _tratamientoService = TratamientoService();
  final _inventarioService = InventarioService();
  final _authService = AuthService();

  List<TomaModel> _proximasTomas = [];
  List<InventarioModel> _stockBajo = [];
  List<TratamientoModel> _activos = [];
  String _nombre = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final nombre = await _authService.getNombre();
      final tomas = await _tratamientoService.getProximasTomas();
      final stockBajo = await _inventarioService.getStockBajo();
      final activos = await _tratamientoService.getTratamientosActivos();

      setState(() {
        _nombre = nombre ?? '';
        _proximasTomas = tomas;
        _stockBajo = stockBajo;
        _activos = activos;
      });
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

  String _getSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getSaludo()}, $_nombre 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'es',
                      ).format(DateTime.now()),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjetas resumen
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.medication,
                            label: 'Tratamientos\nactivos',
                            value: '${_activos.length}',
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.notifications_active,
                            label: 'Tomas\nhoy',
                            value: '${_proximasTomas.length}',
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.warning_amber,
                            label: 'Stock\nbajo',
                            value: '${_stockBajo.length}',
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Próximas tomas
                    _buildSectionHeader(
                      title: 'Próximas tomas',
                      icon: Icons.schedule,
                    ),
                    const SizedBox(height: 8),
                    if (_proximasTomas.isEmpty)
                      _buildEmptyCard('No hay tomas pendientes para hoy ✅')
                    else
                      ..._proximasTomas.take(3).map((t) => _buildTomaCard(t)),
                    const SizedBox(height: 24),

                    // Stock bajo
                    _buildSectionHeader(
                      title: 'Medicamentos con stock bajo',
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 8),
                    if (_stockBajo.isEmpty)
                      _buildEmptyCard(
                        'Todos los medicamentos tienen stock suficiente ✅',
                      )
                    else
                      ..._stockBajo.map((i) => _buildStockCard(i)),
                    const SizedBox(height: 24),

                    // Tratamientos activos
                    _buildSectionHeader(
                      title: 'Tratamientos activos',
                      icon: Icons.medication,
                    ),
                    const SizedBox(height: 8),
                    if (_activos.isEmpty)
                      _buildEmptyCard('No hay tratamientos activos')
                    else
                      ..._activos.map((t) => _buildTratamientoCard(t)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTomaCard(TomaModel toma) {
    final horaLocal = toma.horaProgramada.toLocal();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.medication,
            color: AppTheme.warningColor,
            size: 20,
          ),
        ),
        title: Text(
          toma.medicamentoNombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(toma.dosis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(horaLocal),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('dd/MM').format(horaLocal),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(InventarioModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.warning_amber,
            color: AppTheme.errorColor,
            size: 20,
          ),
        ),
        title: Text(
          item.medicamentoNombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.medicamentoPresentacion ?? ''} ${item.medicamentoConcentracion ?? ''}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item.cantidadActual}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
                fontSize: 20,
              ),
            ),
            Text(
              item.unidad,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTratamientoCard(TratamientoModel t) {
    final progreso = t.totalTomas > 0 ? t.tomasTomadas / t.totalTomas : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medication,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.medicamentoNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${(progreso * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${t.dosis} • cada ${t.frecuenciaHoras}h • ${t.tomasPendientes} tomas pendientes',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progreso,
              backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
