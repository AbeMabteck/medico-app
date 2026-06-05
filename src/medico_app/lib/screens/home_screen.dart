import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'consultas/consultas_screen.dart';
import 'doctores/doctores_screen.dart';
import 'inventario/inventario_screen.dart';
import 'tratamientos/tratamientos_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  String _nombreUsuario = '';

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ConsultasScreen(),
    const DoctoresScreen(),
    const InventarioScreen(),
    const TratamientosScreen(),
  ];

  final List<String> _titles = [
    'Inicio',
    'Expediente Médico',
    'Mis Doctores',
    'Inventario',
    'Tratamientos',
  ];

  @override
  void initState() {
    super.initState();
    _loadNombre();
  }

  Future<void> _loadNombre() async {
    final nombre = await _authService.getNombre();
    setState(() => _nombreUsuario = nombre ?? '');
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_nombreUsuario.isNotEmpty)
              Text(
                'Hola, $_nombreUsuario',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()),
              );
              _loadNombre();
            },
            tooltip: 'Mi perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information_outlined),
            activeIcon: Icon(Icons.medical_information),
            label: 'Expediente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Doctores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication),
            label: 'Tratamientos',
          ),
        ],
      ),
    );
  }
}
