import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/inventario_model.dart';
import '../../services/inventario_service.dart';

class EditarInventarioScreen extends StatefulWidget {
  final InventarioModel item;

  const EditarInventarioScreen({super.key, required this.item});

  @override
  State<EditarInventarioScreen> createState() => _EditarInventarioScreenState();
}

class _EditarInventarioScreenState extends State<EditarInventarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();
  final _cantMinimaCtrl = TextEditingController();
  final _lugarCompraCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _service = InventarioService();

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
    _cantidadCtrl.text = widget.item.cantidadActual.toString();
    _cantMinimaCtrl.text = widget.item.cantidadMinima.toString();
    _lugarCompraCtrl.text = widget.item.lugarCompra ?? '';
    _precioCtrl.text = widget.item.precio?.toString() ?? '';
    _unidad = widget.item.unidad;
    _fechaCaducidad = widget.item.fechaCaducidad;
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _cantMinimaCtrl.dispose();
    _lugarCompraCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectFechaCaducidad() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _fechaCaducidad ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) setState(() => _fechaCaducidad = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.actualizarInventario(
        id: widget.item.id,
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
            content: Text('✅ Inventario actualizado correctamente'),
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
      appBar: AppBar(title: Text(widget.item.medicamentoNombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Info del medicamento
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.medicamentoNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.item.medicamentoPresentacion ?? ''} ${widget.item.medicamentoConcentracion ?? ''}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                  if (int.tryParse(v) == null) return 'Número inválido';
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
                  if (int.tryParse(v) == null) return 'Número inválido';
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
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
