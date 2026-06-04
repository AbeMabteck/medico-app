import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../services/perfil_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _service = PerfilService();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  Map<String, dynamic>? _perfil;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _tipoSangre;
  DateTime? _fechaNacimiento;

  final List<String> _tiposSangre = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPerfil() async {
    setState(() => _isLoading = true);
    try {
      final perfil = await _service.getPerfil();
      setState(() {
        _perfil = perfil;
        _nombreCtrl.text = perfil['nombre'] ?? '';
        _telefonoCtrl.text = perfil['telefono'] ?? '';
        _tipoSangre = perfil['tipoSangre'];
        _fechaNacimiento = perfil['fechaNacimiento'] != null
            ? DateTime.parse(perfil['fechaNacimiento'])
            : null;
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

  Future<void> _selectFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaNacimiento = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _service.updatePerfil(
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        tipoSangre: _tipoSangre,
        fechaNacimiento: _fechaNacimiento,
      );

      setState(() => _isEditing = false);
      await _loadPerfil();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
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
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar perfil',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancelar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _perfil?['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    _perfil?['email'] ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  if (!_isEditing) ...[
                    // Vista de datos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.person_outlined,
                              label: 'Nombre',
                              value: _perfil?['nombre'] ?? '-',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: _perfil?['email'] ?? '-',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Teléfono',
                              value: _perfil?['telefono'] ?? '-',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.bloodtype_outlined,
                              label: 'Tipo de sangre',
                              value: _perfil?['tipoSangre'] ?? '-',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.cake_outlined,
                              label: 'Fecha de nacimiento',
                              value: _perfil?['fechaNacimiento'] != null
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(
                                        _perfil!['fechaNacimiento'],
                                      ),
                                    )
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Formulario de edición
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoSangre,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de sangre',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                      items: _tiposSangre
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _tipoSangre = v),
                    ),
                    const SizedBox(height: 16),
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
                              Icons.cake_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha de nacimiento',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  _fechaNacimiento != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_fechaNacimiento!)
                                      : 'Seleccionar',
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
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
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}
