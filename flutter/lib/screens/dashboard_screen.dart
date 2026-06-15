import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'symptom_screen.dart';
import 'guides_screen.dart';
import 'planes_pae_screen.dart';
import 'calculadoras_screen.dart';
import 'farmacologia_screen.dart';
import 'cronometro_screen.dart';
import 'chat_screen.dart';
import 'education_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await ApiService.getDashboard();
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_data == null) {
      return const Center(
        child: Text('Error al cargar dashboard (¿backend apagado?)'),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final d = _data!;
    final planes = (d['planes_pae'] ?? 0) as int;
    final timers = (d['timers_hoy'] ?? 0) as int;
    final guias = (d['guias_disponibles'] ?? 0) as int;
    final chat = (d['chat_ia'] ?? '—') as String;
    final timerActivo = d['timer_activo'] is Map<String, dynamic>
        ? d['timer_activo'] as Map<String, dynamic>
        : null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('General', cs),
          Row(
            children: [
              Expanded(child: _metricCard('Planes PAE', '$planes', Icons.assignment_rounded, cs.secondary, cs)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Timers hoy', '$timers', Icons.timer_rounded, cs.error, cs)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard('Guías clínicas', '$guias', Icons.menu_book_rounded, cs.tertiary, cs)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Chat IA', chat, Icons.smart_toy_rounded, cs.primary, cs)),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Atajos', cs),
          _actionTile(
            context,
            title: 'Nuevo plan PAE',
            subtitle: 'Crear plan de cuidados rápido',
            icon: Icons.add_circle_rounded,
            color: cs.secondary,
            cs: cs,
            onTap: () => _openScreenByName(context, 'PAE'),
          ),
          _actionTile(
            context,
            title: 'Abrir Farmacología',
            subtitle: 'Buscar medicamento o compatibilidad IV',
            icon: Icons.medication_rounded,
            color: cs.tertiary,
            cs: cs,
            onTap: () => _openScreenByName(context, 'Farmacología'),
          ),
          _actionTile(
            context,
            title: 'Ir a Educación',
            subtitle: 'Flashcards, quizzes y dossier',
            icon: Icons.school_rounded,
            color: cs.primary,
            cs: cs,
            onTap: () => _openScreenByName(context, 'Educación'),
          ),
          if (timerActivo != null) ...[
            const SizedBox(height: 16),
            _sectionTitle('Turno activo', cs),
            _timerCard(timerActivo, cs),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color, ColorScheme cs) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.35), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerCard(Map<String, dynamic> t, ColorScheme cs) {
    final centro = (t['centro'] ?? '-').toString();
    final ganancia = (t['ganancia'] ?? 0).toString();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.primary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cs.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(centro, style: TextStyle(color: cs.onSurface, fontSize: 14)),
                  Text(
                    'Ganancia estimada: \$$ganancia',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.timer, color: cs.primary),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required ColorScheme cs, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        onTap: onTap,
      ),
    );
  }

  void _openScreenByName(BuildContext context, String name) {
    final map = <String, WidgetBuilder>{
      'Síntomas': (_) => SymptomScreen(),
      'PAE': (_) => PlanesPaeScreen(),
      'Farmacología': (_) => FarmacologiaScreen(),
      'Guías Clínicas': (_) => GuidesScreen(),
      'Calculadoras': (_) => CalculadorasScreen(),
      'Asistente IA': (_) => ChatScreen(),
      'Cronómetro': (_) => CronometroScreen(),
      'Educación': (_) => EducationScreen(),
    };
    final builder = map[name];
    if (builder == null) return;
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }
}
