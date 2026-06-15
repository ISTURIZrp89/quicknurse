import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─── Cronometro Screen ────────────────────────────────────────────

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  // ── Reloj digital ──
  String _horaActual = '--:--:--';
  String _fechaActual = '';

  // ── Cronómetro ──
  bool _cronoActivo = false;
  int _milisegundos = 0; // resolución 0.1s = 100ms
  Timer? _cronoTicker;
  Timer? _relojTicker;

  // ── Vueltas ──
  List<int> _vueltas = [];

  // ── Analógico toggle ──
  bool _mostrarAnalogico = false;

  @override
  void initState() {
    super.initState();
    _actualizarReloj();
    _relojTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _actualizarReloj();
    });
  }

  @override
  void dispose() {
    _cronoTicker?.cancel();
    _relojTicker?.cancel();
    super.dispose();
  }

  void _actualizarReloj() {
    final ahora = DateTime.now();
    final h = ahora.hour.toString().padLeft(2, '0');
    final m = ahora.minute.toString().padLeft(2, '0');
    final s = ahora.second.toString().padLeft(2, '0');
    setState(() {
      _horaActual = '$h:$m:$s';
      _fechaActual = _formatearFecha(ahora);
    });
  }

  String _formatearFecha(DateTime dt) {
    const dias = [
      'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
    ];
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${dias[dt.weekday]}, ${dt.day} de ${meses[dt.month - 1]}, ${dt.year}';
  }

  // ── Cronómetro ──

  void _iniciarCrono() {
    _cronoTicker?.cancel();
    setState(() => _cronoActivo = true);
    _cronoTicker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        _milisegundos += 100;
      });
    });
  }

  void _pausarCrono() {
    _cronoTicker?.cancel();
    setState(() => _cronoActivo = false);
  }

  void _toggleCrono() {
    if (_cronoActivo) {
      _pausarCrono();
    } else {
      _iniciarCrono();
    }
  }

  void _reiniciarCrono() {
    _cronoTicker?.cancel();
    setState(() {
      _milisegundos = 0;
      _cronoActivo = false;
      _vueltas = [];
    });
  }

  void _agregarVuelta() {
    setState(() {
      _vueltas.insert(0, _milisegundos);
    });
  }

  // ── Formatos ──

  String _formatoCrono(int ms) {
    final decimas = (ms % 1000) ~/ 100;
    final totalSeg = ms ~/ 1000;
    final min = (totalSeg ~/ 60) % 60;
    final seg = totalSeg % 60;
    return '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}.$decimas';
  }

  String get _displayCrono => _formatoCrono(_milisegundos);

  // ── Fase clínica ──

  String get _faseClinica {
    final seg = _milisegundos ~/ 1000;
    if (seg < 15) return 'PREPARADO';
    if (seg < 30) return '🩸 CICLO DE FRECUENCIA CARDÍACA RÁPIDA (15S)';
    if (seg < 60) return '💓 CICLO DE FRECUENCIA CARDÍACA (30S)';
    if (seg < 120) return '⏱️ CICLO COMPLETO DE RESPIRACIÓN (1 MIN)';
    return '🚨 CICLO RCP COMPLETO (2 MIN)';
  }

  String _sugerenciaClinica(int ms) {
    final seg = ms ~/ 1000;
    if (seg >= 14 && seg <= 16) return 'Multiplicar por 4 (FC 15s)';
    if (seg >= 28 && seg <= 32) return 'Multiplicar por 2 (FC 30s)';
    if (seg >= 58 && seg <= 62) return 'Frecuencia real 60s';
    return 'Parcial libre';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Reloj Digital ──
            _buildRelojDigital(cs),
            const SizedBox(height: 16),

            // ── Toggle analógico ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Reloj analógico',
                    style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13)),
                const SizedBox(width: 8),
                Switch(
                  value: _mostrarAnalogico,
                  onChanged: (v) => setState(() => _mostrarAnalogico = v),
                  activeColor: cs.primary,
                ),
              ],
            ),

            if (_mostrarAnalogico) ...[
              _buildRelojAnalogico(cs),
              const SizedBox(height: 16),
            ],

            // ── Display Cronómetro ──
            _buildCronoDisplay(cs),

            // ── Fase clínica ──
            const SizedBox(height: 8),
            _buildFaseClinica(cs),

            // ── Botones ──
            const SizedBox(height: 16),
            _buildBotones(cs),

            // ── Vueltas ──
            if (_vueltas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListaVueltas(cs),
            ],

            const SizedBox(height: 24),

            // ── Leyenda fases ──
            _buildLeyendaFases(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildRelojDigital(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            _horaActual,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: cs.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fechaActual,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelojAnalogico(ColorScheme cs) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _AnalogClockPainter(
          DateTime.now().hour % 12,
          DateTime.now().minute,
          DateTime.now().second,
          cs,
        ),
      ),
    );
  }

  Widget _buildCronoDisplay(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _cronoActivo
              ? cs.primary.withOpacity(0.5)
              : cs.onSurfaceVariant.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: [
          Text(
            _displayCrono,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: _cronoActivo ? cs.primary : cs.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaseClinica(ColorScheme cs) {
    final seg = _milisegundos ~/ 1000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getFaseColor(cs).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getFaseColor(cs).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getFaseColor(cs),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _faseClinica,
              style: TextStyle(
                color: _getFaseColor(cs),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${seg}s',
            style: TextStyle(
              color: _getFaseColor(cs).withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Color _getFaseColor(ColorScheme cs) {
    final seg = _milisegundos ~/ 1000;
    if (seg < 15) return cs.onSurfaceVariant;
    if (seg < 30) return cs.tertiary;
    if (seg < 60) return cs.primary;
    if (seg < 120) return cs.tertiary;
    return cs.error;
  }

  Widget _buildBotones(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lap
        IconButton.filledTonal(
          onPressed: _cronoActivo ? _agregarVuelta : null,
          icon: const Icon(Icons.flag),
          style: IconButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            foregroundColor: cs.primary,
          ),
        ),
        const SizedBox(width: 20),

        // Play / Pause
        SizedBox(
          width: 72,
          height: 72,
          child: IconButton.filled(
            onPressed: _toggleCrono,
            icon: Icon(_cronoActivo ? Icons.pause : Icons.play_arrow, size: 36),
            style: IconButton.styleFrom(
              backgroundColor: _cronoActivo
                  ? cs.tertiary
                  : cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Reset
        IconButton.filledTonal(
          onPressed: _milisegundos > 0 ? _reiniciarCrono : null,
          icon: const Icon(Icons.refresh),
          style: IconButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            foregroundColor: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildListaVueltas(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Vueltas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._vueltas.asMap().entries.map((entry) {
            final i = entry.key;
            final ms = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#${i + 1}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.38),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      _formatoCrono(ms),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _sugerenciaClinica(ms),
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeyendaFases(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fases clínicas del cronómetro:',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 4),
          _leyendaItem('0-14s', 'PREPARADO', cs.onSurfaceVariant, cs),
          _leyendaItem('15-29s', 'FC Rápida (x4)', cs.tertiary, cs),
          _leyendaItem('30-59s', 'FC Normal (x2)', cs.primary, cs),
          _leyendaItem('60-119s', 'Respiración (1min)', cs.tertiary, cs),
          _leyendaItem('120s+', 'RCP Completo (2min)', cs.error, cs),
        ],
      ),
    );
  }

  Widget _leyendaItem(String tiempo, String desc, Color color, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(tiempo,
                style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace')),
          ),
          Expanded(
            child: Text(desc,
                style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Analog Clock Painter ─────────────────────────────────────────

class _AnalogClockPainter extends CustomPainter {
  final int hours;
  final int minutes;
  final int seconds;
  final ColorScheme cs;

  _AnalogClockPainter(this.hours, this.minutes, this.seconds, this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;

    // Fondo
    final bgPaint = Paint()..color = cs.surfaceContainerHigh;
    canvas.drawCircle(center, radius + 4, bgPaint);

    // Borde
    final borderPaint = Paint()
      ..color = cs.primary.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // Marcas de hora
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 * pi / 180) - pi / 2;
      final isMain = i % 3 == 0;
      final inner = radius * (isMain ? 0.82 : 0.88);
      final outer = radius * (isMain ? 0.92 : 0.95);
      final p1 = Offset(center.dx + inner * cos(angle), center.dy + inner * sin(angle));
      final p2 = Offset(center.dx + outer * cos(angle), center.dy + outer * sin(angle));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = isMain ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.38)
          ..strokeWidth = isMain ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Manecilla hora
    final hrAngle = ((hours % 12) * 30 + minutes * 0.5) * pi / 180 - pi / 2;
    final hrLen = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(center.dx + hrLen * cos(hrAngle), center.dy + hrLen * sin(hrAngle)),
      Paint()
        ..color = cs.primary
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Manecilla minuto
    final minAngle = (minutes * 6 + seconds * 0.1) * pi / 180 - pi / 2;
    final minLen = radius * 0.7;
    canvas.drawLine(
      center,
      Offset(center.dx + minLen * cos(minAngle), center.dy + minLen * sin(minAngle)),
      Paint()
        ..color = cs.onSurface
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Manecilla segundo
    final secAngle = seconds * 6 * pi / 180 - pi / 2;
    final secLen = radius * 0.8;
    canvas.drawLine(
      center,
      Offset(center.dx + secLen * cos(secAngle), center.dy + secLen * sin(secAngle)),
      Paint()
        ..color = cs.error
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Centro
    canvas.drawCircle(
      center,
      4,
      Paint()..color = cs.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.hours != hours ||
        oldDelegate.minutes != minutes ||
        oldDelegate.seconds != seconds;
  }
}
