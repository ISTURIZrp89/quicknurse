import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'symptom_screen.dart';
import 'guides_screen.dart';
import 'planes_pae_screen.dart';
import 'calculadoras_screen.dart';
import 'farmacologia_screen.dart';
import 'cronometro_screen.dart';
import 'chat_screen.dart';
import 'education_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const HomeScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('QuickNurse'),
              actions: [
                IconButton(
                  icon: Icon(widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  onPressed: widget.onToggleTheme,
                  tooltip: 'Cambiar tema',
                ),
              ],
            )
          : null,
      drawer: _buildDrawer(context, cs),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(),
          FarmacologiaScreen(),
          ChatScreen(),
          EducationScreen(),
          _buildMoreTab(context, cs),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication_rounded),
            label: 'Fármacos',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'IA',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Estudiar',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Más',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme cs) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.local_hospital_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text('QuickNurse', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Asistente Clínico de Enfermería', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _drawerItem(cs, Icons.dashboard_rounded, 'Dashboard', () { Navigator.pop(context); _setTab(0); }),
          _drawerItem(cs, Icons.healing_rounded, 'Triaje', () { Navigator.pop(context); _openScreen(context, SymptomScreen()); }),
          _drawerItem(cs, Icons.assignment_rounded, 'Planes PAE', () { Navigator.pop(context); _openScreen(context, PlanesPaeScreen()); }),
          _drawerItem(cs, Icons.menu_book_rounded, 'Guías Clínicas', () { Navigator.pop(context); _openScreen(context, GuidesScreen()); }),
          const Divider(),
          _drawerItem(cs, Icons.medication_rounded, 'Farmacología', () { Navigator.pop(context); _setTab(1); }),
          _drawerItem(cs, Icons.calculate_rounded, 'Calculadoras', () { Navigator.pop(context); _openScreen(context, CalculadorasScreen()); }),
          _drawerItem(cs, Icons.timer_rounded, 'Cronómetro', () { Navigator.pop(context); _openScreen(context, CronometroScreen()); }),
          const Divider(),
          _drawerItem(cs, Icons.smart_toy_rounded, 'Chat IA', () { Navigator.pop(context); _setTab(2); }),
          _drawerItem(cs, Icons.school_rounded, 'Educación', () { Navigator.pop(context); _setTab(3); }),
          const Divider(),
          SwitchListTile(
            secondary: Icon(widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: cs.onSurfaceVariant),
            title: Text('Modo oscuro', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
            value: widget.isDark,
            onChanged: (_) { Navigator.pop(context); widget.onToggleTheme(); },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant),
            title: Text('v1.0.0', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
            subtitle: Text('Modelos locales Ollama', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(ColorScheme cs, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
      onTap: onTap,
    );
  }

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildMoreTab(BuildContext context, ColorScheme cs) {
    final moduleColor = cs.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Todos los módulos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _moreTile(context, cs, Icons.healing_rounded, 'Triaje', moduleColor, const SymptomScreen()),
          _moreTile(context, cs, Icons.assignment_rounded, 'Planes PAE', moduleColor, const PlanesPaeScreen()),
          _moreTile(context, cs, Icons.menu_book_rounded, 'Guías Clínicas', moduleColor, const GuidesScreen()),
          _moreTile(context, cs, Icons.medication_rounded, 'Farmacología', moduleColor, const FarmacologiaScreen()),
          _moreTile(context, cs, Icons.calculate_rounded, 'Calculadoras', moduleColor, const CalculadorasScreen()),
          _moreTile(context, cs, Icons.timer_rounded, 'Cronómetro', moduleColor, const CronometroScreen()),
          _moreTile(context, cs, Icons.smart_toy_rounded, 'Chat IA', moduleColor, const ChatScreen()),
          _moreTile(context, cs, Icons.school_rounded, 'Educación', moduleColor, const EducationScreen()),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Acerca de', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 8),
                  Text('QuickNurse v1.1.0', style: TextStyle(color: cs.onSurfaceVariant)),
                  Text('Asistente clínico para profesionales de enfermería', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 12),
                  Text('Modelos locales: Ollama (phi4-mini, llama3.2, mistral)', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  Text('Datos: Vademécum 800+ fármacos, guías clínicas, PAE', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('Contenido educativo basado en fuentes abiertas (OMS, MS España, PubMed) sin copyright', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreTile(BuildContext context, ColorScheme cs, IconData icon, String title, Color color, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
