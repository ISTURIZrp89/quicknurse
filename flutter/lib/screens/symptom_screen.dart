import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/symptom_response.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final _ctrl = TextEditingController();
  SymptomResponse? _result;
  bool _loading = false;
  bool _useLlm = false;

  String _selectedSex = 'no_especifica';
  final _ageCtrl = TextEditingController();

  final List<String> _bodySystems = [
    'Cardiovascular',
    'Respiratorio',
    'Neurológico',
    'Gastrointestinal',
    'Genitourinario',
    'Musculoesquelético',
    'Piel/Tegumentario',
    'Psiquiátrico',
    'Infeccioso',
    'General/Inespecífico',
  ];

  String? _selectedSystem;

  @override
  void dispose() {
    _ctrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final age = int.tryParse(_ageCtrl.text);
      final r = await ApiService.analyzeSymptoms(
        text,
        llm: _useLlm,
        age: age,
        sex: _selectedSex == 'no_especifica' ? null : _selectedSex,
      );
      setState(() { _result = r; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _priorityColor(String priority, ColorScheme cs) {
    switch (priority) {
      case 'emergencia': return cs.error;
      case 'urgente': return cs.tertiary;
      default: return cs.tertiary;
    }
  }

  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'emergencia': return Icons.warning_rounded;
      case 'urgente': return Icons.report_problem_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triaje Clínico'),
        actions: [
          IconButton(
            icon: Icon(_useLlm ? Icons.psychology_rounded : Icons.rule_rounded, color: _useLlm ? cs.primary : cs.onSurfaceVariant),
            tooltip: _useLlm ? 'Análisis profundo (IA local)' : 'Reglas offline',
            onPressed: () => setState(() => _useLlm = !_useLlm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // System selector
            _sectionTitle(cs, 'Sistema afectado'),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bodySystems.length,
                itemBuilder: (_, i) {
                  final sel = _selectedSystem == _bodySystems[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_bodySystems[i], style: TextStyle(fontSize: 11)),
                      selected: sel,
                      onSelected: (v) => setState(() => _selectedSystem = _bodySystems[i]),
                      visualDensity: VisualDensity.compact,
                      selectedColor: cs.primary.withOpacity(0.15),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Patient data
            _sectionTitle(cs, 'Datos del paciente'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageCtrl,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Edad',
                      hintText: 'años',
                      isDense: true,
                      prefixIcon: Icon(Icons.cake_outlined, size: 18, color: cs.onSurfaceVariant),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSex,
                    decoration: InputDecoration(
                      labelText: 'Sexo',
                      isDense: true,
                      prefixIcon: Icon(Icons.people_outline_rounded, size: 18, color: cs.onSurfaceVariant),
                    ),
                    items: [
                      'no_especifica', 'masculino', 'femenino',
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s == 'no_especifica' ? 'No especifica' : s == 'masculino' ? 'Masculino' : 'Femenino', style: TextStyle(fontSize: 14, color: cs.onSurface)))).toList(),
                    onChanged: (v) => setState(() => _selectedSex = v ?? 'no_especifica'),
                    style: TextStyle(color: cs.onSurface, fontSize: 14),
                    dropdownColor: cs.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Symptoms input
            _sectionTitle(cs, 'Describa los síntomas'),
            TextField(
              controller: _ctrl,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Ej: Dolor de pecho intenso, falta de aire, sudoración...',
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.3),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 8),

            // Mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (_useLlm ? cs.primary : cs.secondary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    _useLlm ? Icons.psychology_rounded : Icons.rule_rounded,
                    size: 18,
                    color: _useLlm ? cs.primary : cs.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _useLlm ? 'Análisis profundo con IA local' : 'Evaluación por reglas offline',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ),
                  Switch(
                    value: _useLlm,
                    onChanged: (v) => setState(() => _useLlm = v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Analyze button
            FilledButton.icon(
              onPressed: _loading ? null : _analyze,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: _useLlm ? cs.primary : cs.secondary,
              ),
              icon: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                : Icon(Icons.search_rounded),
              label: Text(_loading ? 'Analizando...' : 'Evaluar síntomas'),
            ),

            // Result
            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _priorityColor(_result!.priority, cs).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _priorityColor(_result!.priority, cs).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(_result!.priority, cs).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_priorityIcon(_result!.priority), size: 14, color: _priorityColor(_result!.priority, cs)),
                              const SizedBox(width: 4),
                              Text(
                                _result!.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _priorityColor(_result!.priority, cs),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_result!.redFlag) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('RED FLAG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.error)),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${(_result!.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _priorityColor(_result!.priority, cs),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Diagnóstico probable:', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(_result!.diagnosis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    const SizedBox(height: 12),
                    Text('Recomendación:', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(_result!.recommendation, style: TextStyle(fontSize: 14, color: cs.onSurface, height: 1.5)),
                    const SizedBox(height: 8),
                    Text('Fuente: ${_result!.source}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              // Disclaimer
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.tertiary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: cs.tertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Esto es una herramienta de apoyo. No reemplaza la evaluación clínica profesional. En caso de emergencia, contacte a servicios de urgencia.',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(ColorScheme cs, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
