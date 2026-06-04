import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/inventario_model.dart';
import '../../services/inventario_service.dart';

class AgregarInventarioScreen extends StatefulWidget {
  const AgregarInventarioScreen({super.key});

  @override
  State<AgregarInventarioScreen> createState() =>
      _AgregarInventarioScreenState();
}

class _AgregarInventarioScreenState extends State<AgregarInventarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();
  final _cantMinimaCtrl = TextEditingController(text: '5');
  final _lugarCompraCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _service = InventarioService();

  List<MedicamentoCatalogoModel> _catalogo = [];
  MedicamentoCatalogoModel? _medicamentoSeleccionado;
  String _unidad = 'tabletas';
  DateTime? _fechaCaducidad;
  bool _isLoading = false;

  final List<String> _unidades = [
    'tabletas',
    'cápsulas',
    'ml',
    'mg',
    'sobres',
    'ampollas',
  ];

  @override
  void initState() {
    super.initState();
    _loadCatalogo();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _cantMinimaCtrl.dispose();
    _lugarCompraCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogo() async {
    try {
      final catalogo = await _service.getCatalogo();
      setState(() => _catalogo = catalogo);
    } catch (_) {}
  }

  Future<void> _selectFechaCaducidad() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) setState(() => _fechaCaducidad = picked);
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
      await _service.agregarInventario(
        medicamentoId: _medicamentoSeleccionado!.id,
        cantidadActual: int.parse(_cantidadCtrl.text),
        cantidadMinima: int.parse(_cantMinimaCtrl.text),
        unidad: _unidad,
        fechaCaducidad: _fechaCaducidad,
        lugarCompra: _lugarCompraCtrl.text.trim(),
        precio: _precioCtrl.text.isEmpty
            ? null
            : double.parse(_precioCtrl.text),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento agregado al inventario'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
      appBar: AppBar(title: const Text('Agregar medicamento')),
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

              // Cantidad actual
              TextFormField(
                controller: _cantidadCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad actual',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la cantidad';
                  if (int.tryParse(v) == null)
                    return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cantidad mínima
              TextFormField(
                controller: _cantMinimaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad mínima (alerta)',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Ingresa la cantidad mínima';
                  if (int.tryParse(v) == null)
                    return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unidad
              DropdownButtonFormField<String>(
                value: _unidad,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                items: _unidades
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _unidad = v!),
              ),
              const SizedBox(height: 16),

              // Fecha caducidad
              GestureDetector(
                onTap: _selectFechaCaducidad,
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
                        Icons.event_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de caducidad',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            _fechaCaducidad != null
                                ? '${_fechaCaducidad!.day}/${_fechaCaducidad!.month}/${_fechaCaducidad!.year}'
                                : 'Seleccionar (opcional)',
                            style: TextStyle(
                              fontSize: 15,
                              color: _fechaCaducidad != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lugar de compra
              TextFormField(
                controller: _lugarCompraCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lugar de compra (opcional)',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Precio
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio (opcional)',
                  prefixIcon: Icon(Icons.attach_money_outlined),
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
                    : const Text('Agregar al inventario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
