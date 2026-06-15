import 'package:flutter/material.dart';
import 'dart:math';

class CalculadorasScreen extends StatefulWidget {
  const CalculadorasScreen({super.key});

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadoras Clínicas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant.withValues(alpha: 0.6),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Goteo IV'),
            Tab(text: 'Dosis Líquida'),
            Tab(text: 'Pediatría'),
            Tab(text: 'Adultos & UCI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GoteoIVTab(),
          _DosisLiquidaTab(),
          _PediatriaTab(),
          _AdultosUCITab(),
        ],
      ),
    );
  }
}

// ─── Widget base reutilizable ────────────────────────────────────
class _CalcCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _CalcCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.primary.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.primary)),
            Divider(color: cs.primary),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _ResultBox(
      {required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = color ?? cs.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: accentColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: accentColor)),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  const _NumField(
      {required this.controller,
      required this.label,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: cs.primary),
          suffixText: suffix,
          suffixStyle: TextStyle(color: cs.primary),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: cs.primary)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: cs.primary)),
        ),
      ),
    );
  }
}

// ─── Tab 1: Goteo IV ──────────────────────────────────────────────
class _GoteoIVTab extends StatefulWidget {
  const _GoteoIVTab();
  @override
  State<_GoteoIVTab> createState() => _GoteoIVTabState();
}

class _GoteoIVTabState extends State<_GoteoIVTab> {
  final _volCtrl = TextEditingController();
  final _durCtrl = TextEditingController();
  int _factor = 20;
  double? _resultado;

  void _calcular() {
    final vol = double.tryParse(_volCtrl.text);
    final dur = double.tryParse(_durCtrl.text);
    if (vol == null || dur == null || dur <= 0) {
      setState(() => _resultado = null);
      return;
    }
    setState(() {
      _resultado = (vol / dur) * _factor / 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _CalcCard(
          title: 'Goteo Intravenoso',
          child: Column(
            children: [
              _NumField(
                  controller: _volCtrl,
                  label: 'Volumen',
                  suffix: 'mL'),
              _NumField(
                  controller: _durCtrl,
                  label: 'Duración',
                  suffix: 'horas'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _factor,
                dropdownColor: cs.surfaceContainerHighest,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: 'Factor de goteo',
                  labelStyle: TextStyle(color: cs.primary),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.primary)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.primary)),
                ),
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10 gotas/mL - Macro')),
                  DropdownMenuItem(value: 15, child: Text('15 gotas/mL - Macro')),
                  DropdownMenuItem(value: 20, child: Text('20 gotas/mL - Estándar')),
                  DropdownMenuItem(value: 60, child: Text('60 gotas/mL - Micro')),
                ],
                onChanged: (v) {
                  setState(() => _factor = v!);
                  _calcular();
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: _calcular,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
              ),
              if (_resultado != null)
                _ResultBox(
                  label: 'Gotas por minuto',
                  value: '${_resultado!.toStringAsFixed(1)} gotas/min',
                ),
              if (_resultado != null && _factor == 60)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '(${(_resultado! / 60).toStringAsFixed(1)} mL/h micro)',
                    style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 2: Dosis Líquida ────────────────────────────────────────
class _DosisLiquidaTab extends StatefulWidget {
  const _DosisLiquidaTab();
  @override
  State<_DosisLiquidaTab> createState() => _DosisLiquidaTabState();
}

class _DosisLiquidaTabState extends State<_DosisLiquidaTab> {
  final _dosisCtrl = TextEditingController();
  final _concCtrl = TextEditingController();
  final _volStockCtrl = TextEditingController();
  double? _resultado;

  void _calcular() {
    final dosis = double.tryParse(_dosisCtrl.text); // mg requeridos
    final conc = double.tryParse(_concCtrl.text); // mg/mL
    if (dosis == null || conc == null || conc <= 0) {
      setState(() => _resultado = null);
      return;
    }
    setState(() {
      _resultado = dosis / conc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _CalcCard(
          title: 'Dosis Líquida',
          child: Column(
            children: [
              _NumField(
                  controller: _dosisCtrl,
                  label: 'Dosis requerida',
                  suffix: 'mg'),
              _NumField(
                  controller: _concCtrl,
                  label: 'Concentración del stock',
                  suffix: 'mg/mL'),
              _NumField(
                  controller: _volStockCtrl,
                  label: 'Volumen del stock (opcional)',
                  suffix: 'mL'),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: _calcular,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
              ),
              if (_resultado != null)
                _ResultBox(
                  label: 'Volumen a administrar',
                  value: '${_resultado!.toStringAsFixed(2)} mL',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 3: Pediatría ─────────────────────────────────────────────
class _PediatriaTab extends StatefulWidget {
  const _PediatriaTab();
  @override
  State<_PediatriaTab> createState() => _PediatriaTabState();
}

class _PediatriaTabState extends State<_PediatriaTab> {
  // APGAR
  final _apgarValores = <int>[0, 0, 0, 0, 0];
  final _apgarLabels = [
    'Color (0-2)',
    'Frecuencia (0-2)',
    'Reflejo (0-2)',
    'Tono (0-2)',
    'Respiración (0-2)',
  ];

  // SC (Mosteller)
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();

  // PEWS
  int _pewsComportamiento = 0;
  int _pewsCardiovascular = 0;
  int _pewsRespiratorio = 0;

  double? _apgarResultado;
  double? _scResultado;
  int? _pewsResultado;

  String _apgarInterpretacion(int score) {
    if (score >= 8) return 'Normal (sin depresión)';
    if (score >= 5) return 'Depresión leve a moderada';
    return 'Depresión severa';
  }

  String _pewsAlerta(int score) {
    if (score >= 5) return '¡ALERTA! Activación RRT/médico inmediato';
    if (score >= 3) return 'Precaución: monitoreo c/2h';
    return 'Normal: continuar monitoreo';
  }

  Color _pewsColor(int score, ColorScheme cs) {
    if (score >= 5) return cs.error;
    if (score >= 3) return cs.tertiary;
    return cs.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── APGAR ──
        _CalcCard(
          title: 'APGAR',
          child: Column(
            children: [
              for (int i = 0; i < 5; i++) ...[
                Row(
                  children: [
                    Expanded(
                        child: Text(_apgarLabels[i],
                            style: TextStyle(
                                color: cs.onSurface))),
                    for (int v = 0; v <= 2; v++)
                      ChoiceChip(
                        label: Text('$v',
                            style: TextStyle(
                                color: _apgarValores[i] == v
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant)),
                        selected: _apgarValores[i] == v,
                        selectedColor: cs.primary,
                        onSelected: (_) {
                          setState(() {
                            _apgarValores[i] = v;
                            _apgarResultado = _apgarValores
                                .reduce((a, b) => a + b)
                                .toDouble();
                          });
                        },
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (_apgarResultado != null) ...[
                _ResultBox(
                  label: 'Puntaje APGAR /10',
                  value:
                      '${_apgarResultado!.toInt()}/10 - ${_apgarInterpretacion(_apgarResultado!.toInt())}',
                  color: _apgarResultado! >= 8
                      ? cs.secondary
                      : _apgarResultado! >= 5
                          ? cs.tertiary
                          : cs.error,
                ),
              ],
            ],
          ),
        ),

        // ── Superficie Corporal ──
        _CalcCard(
          title: 'Superficie Corporal (Mosteller)',
          child: Column(
            children: [
              _NumField(
                  controller: _pesoCtrl,
                  label: 'Peso',
                  suffix: 'kg'),
              _NumField(
                  controller: _alturaCtrl,
                  label: 'Altura',
                  suffix: 'cm'),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: () {
                  final p = double.tryParse(_pesoCtrl.text);
                  final a = double.tryParse(_alturaCtrl.text);
                  if (p == null || a == null || p <= 0 || a <= 0) {
                    setState(() => _scResultado = null);
                    return;
                  }
                  setState(() {
                    _scResultado =
                        sqrt((p * a) / 3600);
                  });
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
              ),
              if (_scResultado != null)
                _ResultBox(
                  label: 'Superficie Corporal',
                  value:
                      '${_scResultado!.toStringAsFixed(2)} m²',
                ),
            ],
          ),
        ),

        // ── PEWS ──
        _CalcCard(
          title: 'PEWS (Pediatric Early Warning Score)',
          child: Column(
            children: [
              _pewsRow('Comportamiento (0-2)',
                  _pewsComportamiento, (v) {
                setState(
                    () => _pewsComportamiento = v);
                _calcPews();
              }, cs),
              _pewsRow('Cardiovascular (0-2)',
                  _pewsCardiovascular, (v) {
                setState(
                    () => _pewsCardiovascular = v);
                _calcPews();
              }, cs),
              _pewsRow('Respiratorio (0-2)',
                  _pewsRespiratorio, (v) {
                setState(
                    () => _pewsRespiratorio = v);
                _calcPews();
              }, cs),
              if (_pewsResultado != null) ...[
                _ResultBox(
                  label: 'Puntaje PEWS /6',
                  value:
                      '${_pewsResultado}/6 - ${_pewsAlerta(_pewsResultado!)}',
                  color:
                      _pewsColor(_pewsResultado!, cs),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _calcPews() {
    setState(() {
      _pewsResultado = _pewsComportamiento +
          _pewsCardiovascular +
          _pewsRespiratorio;
    });
  }

  Widget _pewsRow(
      String label, int value, ValueChanged<int> onChanged, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style:
                      TextStyle(color: cs.onSurface))),
          for (int v = 0; v <= 2; v++)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text('$v',
                    style: TextStyle(
                        color: value == v
                            ? cs.onSurface
                            : cs.onSurfaceVariant)),
                selected: value == v,
                selectedColor:
                    cs.primary,
                onSelected: (_) => onChanged(v),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tab 4: Adultos & UCI ────────────────────────────────────────
class _AdultosUCITab extends StatefulWidget {
  const _AdultosUCITab();
  @override
  State<_AdultosUCITab> createState() => _AdultosUCITabState();
}

class _AdultosUCITabState extends State<_AdultosUCITab> {
  // IMC
  final _imcPesoCtrl = TextEditingController();
  final _imcAlturaCtrl = TextEditingController();
  double? _imc;

  // Creatinina (Cockcroft-Gault)
  final _crEdadCtrl = TextEditingController();
  final _crPesoCtrl = TextEditingController();
  final _crCtrl = TextEditingController();
  String _crSexo = 'femenino';
  double? _crResultado;

  // Infusión UCI
  final _infDosisCtrl = TextEditingController();
  final _infPesoCtrl = TextEditingController();
  final _infSolutoCtrl = TextEditingController();
  final _infSolventeCtrl = TextEditingController();
  double? _infResultado;

  // PAM
  final _pamSisCtrl = TextEditingController();
  final _pamDiasCtrl = TextEditingController();
  double? _pamResultado;

  // Glasgow
  int _gcsOcular = 4;
  int _gcsVerbal = 5;
  int _gcsMotor = 6;
  int? _gcsResultado;

  String _imcClasificacion(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    if (imc < 35) return 'Obesidad grado I';
    if (imc < 40) return 'Obesidad grado II';
    return 'Obesidad grado III (mórbida)';
  }

  String _gcsSeveridad(int score) {
    if (score >= 13) return 'Lesión leve';
    if (score >= 9) return 'Lesión moderada';
    return 'Lesión severa (coma)';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── IMC ──
        _CalcCard(
          title: 'Índice de Masa Corporal (IMC)',
          child: Column(
            children: [
              _NumField(
                  controller: _imcPesoCtrl,
                  label: 'Peso',
                  suffix: 'kg'),
              _NumField(
                  controller: _imcAlturaCtrl,
                  label: 'Altura',
                  suffix: 'cm'),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: () {
                  final p = double.tryParse(_imcPesoCtrl.text);
                  final a = double.tryParse(_imcAlturaCtrl.text);
                  if (p == null || a == null || a <= 0) {
                    setState(() => _imc = null);
                    return;
                  }
                  setState(() {
                    _imc = p / pow(a / 100, 2);
                  });
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular IMC'),
              ),
              if (_imc != null)
                _ResultBox(
                  label: 'IMC',
                  value:
                      '${_imc!.toStringAsFixed(1)} kg/m² - ${_imcClasificacion(_imc!)}',
                  color: _imc! < 18.5 || _imc! >= 30
                      ? cs.tertiary
                      : cs.secondary,
                ),
            ],
          ),
        ),

        // ── Creatinina ──
        _CalcCard(
          title: 'Creatinina (Cockcroft-Gault)',
          child: Column(
            children: [
              _NumField(
                  controller: _crEdadCtrl,
                  label: 'Edad',
                  suffix: 'años'),
              _NumField(
                  controller: _crPesoCtrl,
                  label: 'Peso',
                  suffix: 'kg'),
              _NumField(
                  controller: _crCtrl,
                  label: 'Creatinina sérica',
                  suffix: 'mg/dL'),
              DropdownButtonFormField<String>(
                value: _crSexo,
                dropdownColor: cs.surfaceContainerHighest,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  labelStyle: TextStyle(color: cs.primary),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.primary)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.primary)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'femenino', child: Text('Femenino')),
                  DropdownMenuItem(
                      value: 'masculino', child: Text('Masculino')),
                ],
                onChanged: (v) =>
                    setState(() => _crSexo = v!),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: () {
                  final edad = double.tryParse(_crEdadCtrl.text);
                  final peso = double.tryParse(_crPesoCtrl.text);
                  final cr = double.tryParse(_crCtrl.text);
                  if (edad == null || peso == null || cr == null ||
                      cr <= 0) {
                    setState(() => _crResultado = null);
                    return;
                  }
                  final factor = _crSexo == 'femenino' ? 0.85 : 1.0;
                  final raw = ((140 - edad) * peso) / (72 * cr);
                  setState(() {
                    _crResultado = raw * factor;
                  });
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular CrCl'),
              ),
              if (_crResultado != null)
                _ResultBox(
                  label: 'Clearance de Creatinina',
                  value:
                      '${_crResultado!.toStringAsFixed(1)} mL/min${_crResultado! < 60 ? " - ¡ALERTA! <60 mL/min" : " - Normal"}',
                  color: _crResultado! < 60
                      ? cs.error
                      : cs.secondary,
                ),
            ],
          ),
        ),

        // ── Infusión UCI ──
        _CalcCard(
          title: 'Infusión UCI (mcg/kg/min → mL/h)',
          child: Column(
            children: [
              _NumField(
                  controller: _infDosisCtrl,
                  label: 'Dosis',
                  suffix: 'mcg/kg/min'),
              _NumField(
                  controller: _infPesoCtrl,
                  label: 'Peso',
                  suffix: 'kg'),
              _NumField(
                  controller: _infSolutoCtrl,
                  label: 'Soluto (fármaco)',
                  suffix: 'mg'),
              _NumField(
                  controller: _infSolventeCtrl,
                  label: 'Solvente',
                  suffix: 'mL'),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: () {
                  final dosis =
                      double.tryParse(_infDosisCtrl.text);
                  final peso =
                      double.tryParse(_infPesoCtrl.text);
                  final soluto =
                      double.tryParse(_infSolutoCtrl.text);
                  final solvente =
                      double.tryParse(_infSolventeCtrl.text);
                  if (dosis == null ||
                      peso == null ||
                      soluto == null ||
                      solvente == null ||
                      soluto <= 0 ||
                      solvente <= 0) {
                    setState(() => _infResultado = null);
                    return;
                  }
                  // dosis (mcg/kg/min) * peso (kg) * 60 (min/h) / (soluto (mg) * 1000 (mcg/mg) / solvente (mL))
                  // = dosis * peso * 60 / (soluto * 1000 / solvente)
                  // = dosis * peso * 60 * solvente / (soluto * 1000)
                  final concMcgPerMl =
                      (soluto * 1000) / solvente;
                  final mcgPerMin = dosis * peso;
                  setState(() {
                    _infResultado =
                        (mcgPerMin * 60) / concMcgPerMl;
                  });
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular mL/h'),
              ),
              if (_infResultado != null)
                _ResultBox(
                  label: 'Velocidad de infusión',
                  value:
                      '${_infResultado!.toStringAsFixed(1)} mL/h',
                ),
            ],
          ),
        ),

        // ── PAM ──
        _CalcCard(
          title: 'Presión Arterial Media (PAM)',
          child: Column(
            children: [
              _NumField(
                  controller: _pamSisCtrl,
                  label: 'Presión sistólica',
                  suffix: 'mmHg'),
              _NumField(
                  controller: _pamDiasCtrl,
                  label: 'Presión diastólica',
                  suffix: 'mmHg'),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary),
                onPressed: () {
                  final sis =
                      double.tryParse(_pamSisCtrl.text);
                  final dias =
                      double.tryParse(_pamDiasCtrl.text);
                  if (sis == null || dias == null) {
                    setState(() => _pamResultado = null);
                    return;
                  }
                  setState(() {
                    _pamResultado =
                        dias + (sis - dias) / 3;
                  });
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular PAM'),
              ),
              if (_pamResultado != null)
                _ResultBox(
                  label: 'PAM',
                  value:
                      '${_pamResultado!.toStringAsFixed(0)} mmHg - ${_pamResultado! >= 65 ? "Adecuada (≥65)" : "¡Hipotensión! (<65)"}',
                  color: _pamResultado! >= 65
                      ? cs.secondary
                      : cs.error,
                ),
            ],
          ),
        ),

        // ── Glasgow ──
        _CalcCard(
          title: 'Escala de Glasgow',
          child: Column(
            children: [
              _gcsRow('Ocular (1-4)', [1, 2, 3, 4],
                  _gcsOcular, (v) {
                setState(() {
                  _gcsOcular = v;
                  _gcsResultado =
                      _gcsOcular + _gcsVerbal + _gcsMotor;
                });
              }, cs),
              _gcsRow('Verbal (1-5)', [1, 2, 3, 4, 5],
                  _gcsVerbal, (v) {
                setState(() {
                  _gcsVerbal = v;
                  _gcsResultado =
                      _gcsOcular + _gcsVerbal + _gcsMotor;
                });
              }, cs),
              _gcsRow('Motor (1-6)', [1, 2, 3, 4, 5, 6],
                  _gcsMotor, (v) {
                setState(() {
                  _gcsMotor = v;
                  _gcsResultado =
                      _gcsOcular + _gcsVerbal + _gcsMotor;
                });
              }, cs),
              if (_gcsResultado != null)
                _ResultBox(
                  label: 'Glasgow /15',
                  value:
                      '${_gcsResultado}/15 - ${_gcsSeveridad(_gcsResultado!)}',
                  color: _gcsResultado! >= 13
                      ? cs.secondary
                      : _gcsResultado! >= 9
                          ? cs.tertiary
                          : cs.error,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gcsRow(String label, List<int> vals, int selected,
      ValueChanged<int> onChanged, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: cs.onSurface)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: vals
                .map((v) => ChoiceChip(
                      label: Text('$v',
                          style: TextStyle(
                              color: selected == v
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant,
                              fontSize: 13)),
                      selected: selected == v,
                      selectedColor:
                          cs.primary,
                      onSelected: (_) => onChanged(v),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
