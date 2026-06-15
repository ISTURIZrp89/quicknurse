import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlanesPaeScreen extends StatefulWidget {
  const PlanesPaeScreen({super.key});

  @override
  State<PlanesPaeScreen> createState() => _PlanesPaeScreenState();
}

class _PlanesPaeScreenState extends State<PlanesPaeScreen> {
  List<Map<String, dynamic>>? _planes;
  bool _loading = true;
  String _searchQuery = '';
  String _categoryFilter = 'Todos';
  final _searchCtrl = TextEditingController();

  static const Map<String, Map<String, String>> _templates = {
    // ─── Respiratorio ─────────────────────────────
    'Patrón Respiratorio Ineficaz': {
      'categoria': 'Respiratorio',
      'nanda': '00032 Patrón respiratorio ineficaz r/c fatiga muscular respiratoria, dolor torácico o secreciones m/p disnea, taquipnea (>24 rpm), uso de músculos accesorios, disminución de la expansión torácica',
      'noc': '• 0403 Estado respiratorio: ventilación — FR 12-20 rpm, SatO2 > 92%\n• 0410 Estado respiratorio: vía aérea permeable — Sin secreciones obstructivas\n• 0005 Tolerancia a la actividad — Mejora progresiva',
      'nic': '• 3350 Monitorización respiratoria — Valorar FR, SatO2, ruidos c/2h\n• 3320 Oxigenoterapia — Ajustar FiO2 según SatO2 objetivo\n• 3250 Fisioterapia respiratoria — Espirómetro incentivo c/1h\n• 3140 Manejo de la vía aérea — Aspirar secreciones PRN',
    },
    'Deterioro Intercambio Gases': {
      'categoria': 'Respiratorio',
      'nanda': '00030 Deterioro del intercambio de gases r/c desequilibrio V/Q, alteración de la membrana alveolo-capilar m/p hipoxemia (SatO2 < 90%), confusión, cianosis, gasometría alterada',
      'noc': '• 0402 Estado respiratorio: intercambio gaseoso — SatO2 > 92%, PaO2 > 80 mmHg\n• 0802 Signos vitales — FR, FC, PA dentro de parámetros\n• 0801 Estado neurológico — Glasgow 15, consciente orientado',
      'nic': '• 3320 Oxigenoterapia — Administrar O2 según prescripción\n• 3350 Monitorización respiratoria — Gasometría arterial, SatO2 continua\n• 0740 Posición — Fowler/Semifowler para mejorar expansión\n• 6680 Monitorización de SV — FC, PA, FR cada 15 min en crisis',
    },
    'Limpieza Vía Aérea': {
      'categoria': 'Respiratorio',
      'nanda': '00031 Limpieza ineficaz de la vía aérea r/c secreciones espesas, tos ineficaz, dolor torácico m/p sonidos respiratorios disminuidos, ortopnea, expectoración ineficaz',
      'noc': '• 0410 Estado respiratorio: vía aérea permeable — Ruidos pulmonares claros\n• 0408 Estado respiratorio: tos — Tos efectiva que moviliza secreciones\n• 0005 Tolerancia a la actividad — Sin disnea en reposo',
      'nic': '• 3140 Manejo de la vía aérea — Aspiración PRN\n• 3250 Fisioterapia respiratoria — Percusión, vibración, drenaje postural\n• 3230 Oxigenoterapia con humidificación — Licuar secreciones\n• 3260 Incentivador inspiratorio — c/2h mientras despierto',
    },
    // ─── Cardiovascular ───────────────────────────
    'Dolor Agudo': {
      'categoria': 'Cardiovascular',
      'nanda': '00132 Dolor agudo r/c lesión tisular, inflamación o isquemia m/p expresión verbal de dolor, escala EVA > 4, cambios en signos vitales (FC, PA, FR), posición antiálgica',
      'noc': '• 2102 Nivel del dolor — Mantener EVA < 3/10\n• 1605 Control del dolor — Demostrar técnicas no farmacológicas\n• 2002 Bienestar general — Expresa confort y alivio',
      'nic': '• 1400 Manejo del dolor — Valorar EVA cada 4h y PRN\n• 2210 Administración de analgesia — Según prescripción y escala\n• 1380 Aplicación de calor/frío — Local PRN\n• 6040 Terapia de relajación — Respiración profunda, distracción',
    },
    'Disminución GC': {
      'categoria': 'Cardiovascular',
      'nanda': '00029 Disminución del gasto cardíaco r/c alteración de la contractilidad miocárdica, sobrecarga de volumen o resistencia vascular m/p FC alterada, PA alterada, edema, fatiga, signos de hipoperfusión',
      'noc': '• 0400 Estado cardíaco: perfusión — PA dentro de rango, FC 60-100 lpm\n• 0601 Equilibrio hídrico — Balance neutro o negativo\n• 0802 Signos vitales estables — Sin ortostasis',
      'nic': '• 6680 Monitorización de SV — FC, PA, SatO2 cada hora\n• 4040 Manejo de líquidos — Restricción hídrica si precisa\n• 4250 Manejo del edema — Elevación extremidades, medias compresión\n• 4060 Cuidados cardíacos — Reposo, oxígeno, monitorizar arritmias',
    },
    'Perfusión Tisular': {
      'categoria': 'Cardiovascular',
      'nanda': '00204 Perfusión tisular periférica ineficaz r/c disminución del flujo arterial, venoso o capilar m/p pulsos débiles, piel fría, llenado capilar > 3s, cambios de coloración',
      'noc': '• 0407 Perfusión tisular periférica — Pulsos palpables, piel caliente\n• 0408 Perfusión tisular cutánea — Color rosado, llenado capilar < 2s\n• 0802 Signos vitales — PA media > 65 mmHg',
      'nic': '• 4064 Cuidados circulatorios — Valorar pulsos periféricos c/h\n• 4090 Manejo de la presión arterial — Ajustar fármacos vasoactivos\n• 3540 Prevención de úlceras — Cambios posturales, protección talones\n• 6680 Monitorización neurológica si MMSS/MMII',
    },
    // ─── Neurológico ──────────────────────────────
    'Confusión Aguda': {
      'categoria': 'Neurológico',
      'nanda': '00128 Confusión aguda r/c alteración metabólica, déficit de oxígeno, infección o fármacos m/p desorientación T/E/P, alucinaciones, agitación, fluctuación de conciencia',
      'noc': '• 0900 Estado cognitivo — Orientado en T, E, P\n• 1907 Conducta de seguridad — Sin autolesiones\n• 1200 Estado neurológico — Glasgow 15, sin deterioro',
      'nic': '• 6460 Manejo de la confusión — Reorientación frecuente\n• 6480 Manejo del ambiente — Entorno tranquilo, luces suaves\n• 4270 Prevención de caídas — Barandas, supervisión\n• 6610 Identificación de riesgos — Valorar causa subyacente',
    },
    'Deterioro Comunicación': {
      'categoria': 'Neurológico',
      'nanda': '00051 Deterioro de la comunicación verbal r/c alteración neurológica (ACV, TCE), deterioro cognitivo o barrera anatómica m/p dificultad para articular, expresar ideas o comprender mensajes',
      'noc': '• 0903 Comunicación: expresiva — Transmite necesidades básicas\n• 0904 Comunicación: receptiva — Comprende mensajes simples\n• 1200 Estado neurológico — Mejora progresiva del lenguaje',
      'nic': '• 4970 Manejo de la comunicación — Tablero de imágenes, gestos\n• 4720 Estimulación cognitiva — Ejercicios de lenguaje\n• 4200 Cuidados del paciente con ACV — Logopedia, familia\n• 5460 Contacto con logopeda — Derivación si precisa',
    },
    // ─── Digestivo ────────────────────────────────
    'Estreñimiento': {
      'categoria': 'Digestivo',
      'nanda': '00011 Estreñimiento r/c ingesta insuficiente de fibra, líquidos, inmovilidad o fármacos opiáceos m/p deposiciones < 3/semana, heces duras, esfuerzo defecatorio, distensión abdominal',
      'noc': '• 0501 Eliminación intestinal — Deposiciones regulares c/1-2 días\n• 0503 Estado gastrointestinal: función — Sin distensión ni dolor\n• 1008 Estado nutricional: ingesta — Aumentar fibra y agua',
      'nic': '• 0430 Manejo intestinal — Establecer rutina defecatoria\n• 1050 Alimentación rica en fibra — Frutas, verduras, granos integrales\n• 1240 Aumento de líquidos — 1500-2000 mL/día si tolera\n• 6040 Administración de laxantes — Según prescripción',
    },
    'Náuseas': {
      'categoria': 'Digestivo',
      'nanda': '00134 Náuseas r/c irritación gástrica, quimioterapia, cirugía o fármacos m/p sensación subjetiva de arcadas, aversión a alimentos, sialorrea, palidez',
      'noc': '• 2103 Severidad de las náuseas — Disminuir a < 2/10\n• 1008 Estado nutricional — Acepta alimentos vía oral\n• 0601 Equilibrio hídrico — Sin signos de deshidratación',
      'nic': '• 1450 Manejo de las náuseas — Valorar desencadenantes\n• 2210 Administración de antieméticos — 30 min antes de comidas\n• 1240 Dieta — Comidas pequeñas y frecuentes, evitar olores fuertes\n• 1380 Aplicación de frío — Compresa fría en frente',
    },
    'Deterioro Deglución': {
      'categoria': 'Digestivo',
      'nanda': '00103 Deterioro de la deglución r/c alteración neuromuscular, obstrucción mecánica o deterioro cognitivo m/p atragantamiento, tos al tragar, babeo, regurgitación nasal',
      'noc': '• 1010 Estado de la deglución — Deglute sin atragantamiento\n• 1011 Estado de la deglución: fase oral/faríngea — Sello labial adecuado\n• 1008 Estado nutricional — Mantiene peso corporal',
      'nic': '• 1860 Terapia de deglución — Ejercicios oromotores\n• 1800 Ayuda al autocuidado: alimentación — Supervisar comidas\n• 1240 Modificación de la consistencia — Dieta triturada/puré\n• 6650 Valoración de la deglución — Test de agua al ingreso',
    },
    // ─── Renal ────────────────────────────────────
    'Exceso Volumen Líquidos': {
      'categoria': 'Renal',
      'nanda': '00026 Exceso de volumen de líquidos r/c exceso de ingesta de sodio, disminución del GC o IRC m/p edema, peso elevado > 2 kg/día, ingesta > excreta, distensión venosa yugular',
      'noc': '• 0601 Equilibrio hídrico — Balance neutro o negativo\n• 0602 Pesada — Peso estable o -0.5 kg/día\n• 0603 Hidratación — Sin edema, sin estertores húmedos',
      'nic': '• 4120 Manejo de líquidos — Restricción según prescripción\n• 4130 Monitorización de líquidos — Balance cada 8h\n• 4150 Restricción de sodio — Dieta hiposódica\n• 4250 Manejo del edema — Fowler, elevación extremidades',
    },
    'Déficit Volumen Líquidos': {
      'categoria': 'Renal',
      'nanda': '00027 Déficit de volumen de líquidos r/c pérdidas activas (vómitos, diarrea, hemorragia) o ingesta insuficiente m/p disminución de la turgencia cutánea, mucosas secas, oliguria, sed, taquicardia',
      'noc': '• 0601 Equilibrio hídrico — Balance positivo previsto\n• 0602 Pesada — Aumento progresivo de peso\n• 0603 Hidratación — Mucosas húmedas, turgencia normal',
      'nic': '• 4120 Manejo de líquidos — Reposición VO/IV según prescripción\n• 4140 Rehidratación oral — Si tolera, SRO cada 15 min\n• 6680 Monitorización de SV — FC, PA, PVC\n• 4130 Monitorización de diuresis — Objetivo > 0.5 mL/kg/h',
    },
    // ─── Piel ─────────────────────────────────────
    'Integridad Cutánea': {
      'categoria': 'Piel',
      'nanda': '00046 Deterioro de la integridad cutánea r/c inmovilidad, humedad, presión o déficit nutricional m/p lesión cutánea, eritema, exudado, pérdida de continuidad de la epidermis/dermis',
      'noc': '• 1103 Curación de la herida — Granulación, epitelización progresiva\n• 1101 Integridad tisular — Piel intacta sin signos de infección\n• 1902 Prevención de UPP — Sin nuevas lesiones por presión',
      'nic': '• 3590 Cuidados de la piel — Hidratación, valoración diaria\n• 3580 Cuidados de las UPP — Curas según protocolo\n• 3540 Prevención de UPP — Cambios posturales c/2h\n• 4120 Nutrición — Dieta hiperproteica para cicatrización',
    },
    'Riesgo UPP': {
      'categoria': 'Piel',
      'nanda': '00047 Riesgo de deterioro de la integridad cutánea (UPP) r/c inmovilidad prolongada, humedad, fricción, déficit nutricional, edad avanzada, escala Braden < 16',
      'noc': '• 1902 Prevención de UPP — Braden > 18, piel intacta\n• 1101 Integridad tisular — Sin zonas de hiperemia\n• 1909 Conducta de prevención — Familia informada',
      'nic': '• 3540 Prevención de UPP — Valoración Braden al ingreso y c/24h\n• 3584 Cuidados de la piel — Mantener piel seca e hidratada\n• 0840 Cambios posturales — c/2h, proteger prominencias óseas\n• 3590 Superficies especiales — Colchón antiescaras',
    },
    // ─── Psicológico ──────────────────────────────
    'Ansiedad': {
      'categoria': 'Psicológico',
      'nanda': '00146 Ansiedad r/c cambio en el estado de salud, hospitalización, procedimientos invasivos o incertidumbre m/p nerviosismo, tensión, preocupación, taquicardia, hipervigilancia',
      'noc': '• 1211 Nivel de ansiedad — Disminuir a moderado/leve\n• 1402 Autocontrol de la ansiedad — Usa técnicas de relajación\n• 1300 Aceptación del estado de salud — Participa en decisiones',
      'nic': '• 5820 Disminución de la ansiedad — Escucha activa, empatía\n• 6040 Terapia de relajación — Respiración diafragmática\n• 5240 Consejería — Información sobre procedimientos\n• 5440 Aumento de la seguridad — Explicar plan de cuidados',
    },
    'Afrontamiento Ineficaz': {
      'categoria': 'Psicológico',
      'nanda': '00069 Afrontamiento ineficaz r/c crisis situacional, falta de apoyo social o recursos insuficientes m/p incapacidad para resolver problemas, conducta de evitación, verbalización de incapacidad',
      'noc': '• 1302 Afrontamiento de problemas — Identifica estrategias efectivas\n• 1308 Adaptación psicosocial — Participa en actividades\n• 1204 Estado emocional — Expresa emociones adecuadamente',
      'nic': '• 5240 Consejería — Apoyo emocional, validación\n• 5440 Aumento del afrontamiento — Identificar fortalezas\n• 4920 Escucha activa — Tiempo de calidad, presencia terapéutica\n• 7150 Terapia de grupo — Derivar si precisa',
    },
    'Trastorno Sueño': {
      'categoria': 'Psicológico',
      'nanda': '00198 Trastorno del patrón del sueño r/c dolor, ruido ambiental, ansiedad, medicamentos o cambios de rutina m/p dificultad para conciliar/ mantener el sueño, despertar precoz, fatiga diurna',
      'noc': '• 0004 Sueño — Duerme 6-8h continuas\n• 0005 Descanso — Refiere sensación de descanso al despertar\n• 1909 Conducta de salud — Adopta rutina de sueño',
      'nic': '• 6040 Terapia de relajación — Música suave, ambiente oscuro\n• 6480 Manejo ambiental — Reducir ruidos, luces apagadas\n• 5510 Educación sanitaria — Higiene del sueño\n• 2210 Administración de hipnóticos — Solo si prescrito',
    },
    // ─── Seguridad ────────────────────────────────
    'Riesgo Caídas': {
      'categoria': 'Seguridad',
      'nanda': '00155 Riesgo de caídas r/c entorno desconocido, alteración del equilibrio, deterioro muscular, medicación sedante o edad > 65 años, escala de Morse > 45',
      'noc': '• 1902 Prevención de caídas — Morse < 45, entorno seguro\n• 1909 Conducta de prevención — Usa llamador y calzado adecuado\n• 0211 Marcha — Deambula con dispositivo de ayuda',
      'nic': '• 6490 Prevención de caídas — Barandas arriba, cama baja\n• 1800 Ayuda al autocuidado — Acompañar deambulación\n• 6480 Manejo ambiental — Suelo libre de obstáculos\n• 6610 Identificación de riesgos — Revisar medicación sedante',
    },
    'Riesgo Infección': {
      'categoria': 'Seguridad',
      'nanda': '00004 Riesgo de infección r/c inmunosupresión, procedimientos invasivos, heridas quirúrgicas, desnutrición o extremos de edad',
      'noc': '• 0703 Estado infeccioso — Sin signos de infección\n• 1101 Integridad tisular — Herida sin signos inflamatorios\n• 1848 Conocimiento: prevención de infecciones — Cumple medidas',
      'nic': '• 6540 Control de infecciones — Lavado de manos, aislamiento\n• 6550 Protección contra infecciones — Neutropénico: evitar flores\n• 3584 Cuidados del sitio de inserción — Catéter: apósito estéril\n• 6650 Vigilancia — Temperatura, leucocitos, signos de infección',
    },
    'Riesgo Hemorragia': {
      'categoria': 'Seguridad',
      'nanda': '00206 Riesgo de hemorragia r/c tratamiento anticoagulante, coagulopatía, cirugía reciente o traumatismo',
      'noc': '• 0412 Estado de coagulación — INR dentro de rango, pruebas normales\n• 0802 Signos vitales — PA estable, FC normal\n• 0601 Equilibrio hídrico — Sin signos de hipovolemia',
      'nic': '• 6680 Monitorización de SV — PA, FC, signos de shock c/h\n• 6610 Identificación de riesgos — Valorar anticoagulación\n• 4010 Prevención de hemorragias — Evitar inyecciones IM\n• 3480 Manejo de transfusiones — Si precisa, según protocolo',
    },
    'Riesgo Aspiración': {
      'categoria': 'Seguridad',
      'nanda': '00039 Riesgo de aspiración r/c deterioro de la deglución, nivel de conciencia disminuido, sonda nasogástrica o vómitos',
      'noc': '• 0410 Estado respiratorio — Vía aérea permeable sin aspiración\n• 1910 Estado de seguridad — Sin episodios de aspiración\n• 1010 Deglución — Deglute sin dificultad',
      'nic': '• 3200 Precauciones contra aspiración — Cabecera elevada > 30°\n• 1860 Terapia de deglución — Valorar consistencia de alimentos\n• 6650 Vigilancia — Observar signos de atragantamiento\n• 3140 Manejo de la vía aérea — Aspiración de secreciones PRN',
    },
    // ─── Movilidad ────────────────────────────────
    'Deterioro Movilidad': {
      'categoria': 'Neurológico',
      'nanda': '00085 Deterioro de la movilidad física r/c dolor articular, deterioro musculoesquelético o neurológico m/p limitación de movimiento, dependencia para actividades, marcha inestable',
      'noc': '• 0200 Movilidad articular — Mejora rango de movimiento\n• 0201 Ambular — Deambula con ayuda mínima\n• 0300 Autocuidado: actividades de la vida diaria — Independencia progresiva',
      'nic': '• 0221 Terapia de ejercicios: movilidad articular — Pasivos y activos\n• 1803 Ayuda al autocuidado: vestido/higiene — Adaptaciones\n• 0840 Cambios posturales — c/2h, alinear correctamente\n• 5612 Enseñanza: actividad prescrita — Uso de dispositivos',
    },
    'Déficit Autocuidado': {
      'categoria': 'Neurológico',
      'nanda': '00108 Déficit de autocuidado: baño/higiene r/c deterioro neuromuscular, dolor o fatiga m/p incapacidad para lavar cuerpo, regular temperatura del agua o acceder al baño',
      'noc': '• 0301 Autocuidado: baño — Realiza higiene con ayuda parcial\n• 0305 Autocuidado: higiene — Mantiene higiene bucal adecuada\n• 0306 Autocuidado: vestido — Se viste con supervisión',
      'nic': '• 1801 Ayuda al autocuidado: baño/higiene — Proporcionar útiles\n• 1802 Ayuda al autocuidado: vestido — Adaptaciones, ropa fácil\n• 1804 Ayuda al autocuidado: aseo — Supervisar, animar independencia\n• 5610 Enseñanza: seguridad del baño — Antideslizante, temperatura',
    },
  };

  List<String> get _templateKeys => _templates.keys.toList();

  List<Map<String, dynamic>> get _filteredPlanes {
    if (_planes == null) return [];
    var result = _planes!;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return (p['paciente'] ?? '').toString().toLowerCase().contains(q) ||
            (p['diagnostico_nanda'] ?? '').toString().toLowerCase().contains(q) ||
            (p['valoracion'] ?? '').toString().toLowerCase().contains(q);
      }).toList();
    }
    if (_categoryFilter != 'Todos') {
      result = result.where((p) {
        final val = (p['valoracion'] ?? '').toString();
        final matchingTemplate = _templates.entries.firstWhere(
          (e) => val.toLowerCase().contains(e.key.toLowerCase()),
          orElse: () => MapEntry('', const {}),
        );
        return matchingTemplate.value['categoria'] == _categoryFilter;
      }).toList();
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ApiService.getPlanesPae();
      setState(() {
        _planes = p;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _sintomaColor(ColorScheme cs, String? valoracion) {
    if (valoracion == null) return cs.primary;
    final key = _templates.keys.firstWhere(
      (k) => valoracion.toLowerCase().contains(k.toLowerCase()),
      orElse: () => '',
    );
    if (key.isEmpty) return cs.primary;
    final cat = _templates[key]?['categoria'];
    switch (cat) {
      case 'Respiratorio': return cs.primary;
      case 'Cardiovascular': return cs.error;
      case 'Neurológico': return cs.primary;
      case 'Digestivo': return cs.tertiary;
      case 'Renal': return cs.primary;
      case 'Piel': return cs.tertiary;
      case 'Psicológico': return cs.primary;
      case 'Seguridad': return cs.secondary;
      default: return cs.primary;
    }
  }

  IconData _categoryIcon(String? cat) {
    switch (cat) {
      case 'Respiratorio': return Icons.air_rounded;
      case 'Cardiovascular': return Icons.favorite_rounded;
      case 'Neurológico': return Icons.psychology_rounded;
      case 'Digestivo': return Icons.restaurant_rounded;
      case 'Renal': return Icons.water_drop_rounded;
      case 'Piel': return Icons.face_rounded;
      case 'Psicológico': return Icons.mood_rounded;
      case 'Seguridad': return Icons.shield_rounded;
      default: return Icons.assignment_rounded;
    }
  }

  String _getCategory(String? valoracion) {
    if (valoracion == null) return 'General';
    final key = _templates.keys.firstWhere(
      (k) => valoracion.toLowerCase().contains(k.toLowerCase()),
      orElse: () => '',
    );
    return _templates[key]?['categoria'] ?? 'General';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final planes = _filteredPlanes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes PAE'),
        actions: [
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Recargar'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsRow(cs, planes.length, _planes?.length ?? 0),
          _buildSearchBar(cs),
          _buildCategoryChips(cs),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : planes.isEmpty
                    ? _buildEmptyState(cs)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 88),
                          itemCount: planes.length,
                          itemBuilder: (_, i) => _buildPlanCard(cs, planes[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWizard(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo PAE'),
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme cs, int filtered, int total) {
    final active = _planes?.where((p) => (p['evaluacion'] ?? '').toString().contains('"estado":"activo"')).length ?? 0;
    final completed = _planes?.where((p) => (p['evaluacion'] ?? '').toString().contains('"estado":"completado"')).length ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _statChip(cs, Icons.assignment_rounded, '$total total', cs.primary),
          const SizedBox(width: 8),
          _statChip(cs, Icons.play_circle_rounded, '$active activos', cs.secondary),
          const SizedBox(width: 8),
          _statChip(cs, Icons.check_circle_rounded, '$completed completados', cs.tertiary),
        ],
      ),
    );
  }

  Widget _statChip(ColorScheme cs, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Buscar por paciente, diagnóstico...',
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme cs) {
    final labels = <String>{'Todos'};
    for (final t in _templates.values) {
      labels.add(t['categoria'] ?? 'Otros');
    }
    final sorted = labels.toList()..sort();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: sorted.map((cat) {
          final selected = _categoryFilter == cat;
          final icon = _categoryIcon2(cat);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: selected,
              label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              avatar: Icon(icon, size: 16),
              onSelected: (_) => setState(() => _categoryFilter = cat),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _categoryIcon2(String? cat) {
    switch (cat) {
      case 'Respiratorio': return Icons.air_rounded;
      case 'Cardiovascular': return Icons.favorite_rounded;
      case 'Neurológico': return Icons.psychology_rounded;
      case 'Digestivo': return Icons.restaurant_rounded;
      case 'Renal': return Icons.water_drop_rounded;
      case 'Piel': return Icons.face_rounded;
      case 'Psicológico': return Icons.mood_rounded;
      case 'Seguridad': return Icons.shield_rounded;
      default: return Icons.grid_view_rounded;
    }
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_task_rounded, size: 48, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text('Sin planes de cuidados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('Crea tu primer plan con 25+ plantillas NANDA-NIC-NOC',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateWizard(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primer plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(ColorScheme cs, Map<String, dynamic> p) {
    final sintoma = p['valoracion'] as String? ?? '';
    final color = _sintomaColor(cs, sintoma);
    final cat = _getCategory(sintoma);
    final estado = _getEstado(p['evaluacion']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPlanDetail(context, p),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categoryIcon(cat), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['paciente'] ?? 'Paciente',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: cs.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sintoma.isNotEmpty ? sintoma : 'Sin valoración',
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _estadoColor(cs, estado).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _estadoColor(cs, estado)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p['diagnostico_nanda'] ?? '',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _actionChip(cs, Icons.edit_rounded, 'Editar', cs.primary, () => _showCreateWizard(context, editar: p)),
                  const SizedBox(width: 6),
                  _actionChip(cs, Icons.delete_rounded, 'Eliminar', cs.error, () async {
                    await ApiService.eliminarPlanPae(p['id'] as int);
                    _load();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionChip(ColorScheme cs, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  String _getEstado(String? evaluacion) {
    if (evaluacion == null || evaluacion.isEmpty) return 'activo';
    try {
      if (evaluacion.contains('"estado"')) {
        final parts = evaluacion.split('"estado":"');
        if (parts.length > 1) return parts[1].split('"')[0];
      }
    } catch (_) {}
    return 'activo';
  }

  Color _estadoColor(ColorScheme cs, String estado) {
    switch (estado.toLowerCase()) {
      case 'activo': return cs.secondary;
      case 'completado': return cs.tertiary;
      case 'en_progreso': return cs.primary;
      default: return cs.onSurfaceVariant;
    }
  }

  void _showPlanDetail(BuildContext context, Map<String, dynamic> plan) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Plan de Cuidados', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(plan['paciente'] ?? '', style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
              _detailSection(cs, 'Valoración', plan['valoracion'] ?? ''),
              _detailSection(cs, 'Diagnóstico NANDA', plan['diagnostico_nanda'] ?? ''),
              _detailSection(cs, 'Objetivos NOC', plan['objetivos_noc'] ?? ''),
              _detailSection(cs, 'Intervenciones NIC', plan['intervenciones_nic'] ?? ''),
              if ((plan['evaluacion'] ?? '').isNotEmpty)
                _detailSection(cs, 'Evaluación', plan['evaluacion']),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCreateWizard(context, editar: plan);
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Editar plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(ColorScheme cs, String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(content, style: TextStyle(fontSize: 14, color: cs.onSurface, height: 1.4)),
        ],
      ),
    );
  }

  Future<void> _showCreateWizard(BuildContext context, {Map<String, dynamic>? editar}) async {
    final cs = Theme.of(context).colorScheme;
    final pacCtrl = TextEditingController(text: editar?['paciente'] ?? '');
    final valCtrl = TextEditingController(text: editar?['valoracion'] ?? '');
    final ndaCtrl = TextEditingController(text: editar?['diagnostico_nanda'] ?? '');
    final nocCtrl = TextEditingController(text: editar?['objetivos_noc'] ?? '');
    final nicCtrl = TextEditingController(text: editar?['intervenciones_nic'] ?? '');
    final evalCtrl = TextEditingController(text: editar?['evaluacion'] ?? '');

    String selectedTemplate = '';
    String? filterTemplateCat;
    int step = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ListView(
              controller: scrollCtrl,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        editar != null ? 'Editar Plan PAE' : 'Nuevo Plan PAE',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final data = {
                          'paciente': pacCtrl.text,
                          'valoracion': valCtrl.text,
                          'diagnostico_nanda': ndaCtrl.text,
                          'objetivos_noc': nocCtrl.text,
                          'intervenciones_nic': nicCtrl.text,
                          'evaluacion': '{"estado":"activo","notas":""}',
                        };
                        if (editar != null) data['id'] = editar['id'];
                        await ApiService.crearPlanPae(data);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _load();
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),

                // Stepper indicator
                const SizedBox(height: 12),
                _buildStepper(cs, step, setDialogState),

                const SizedBox(height: 16),

                // Step content
                if (step == 0) _buildStepPaciente(cs, pacCtrl, () => setDialogState(() => step = 1)),
                if (step == 1) _buildStepTemplate(cs, filterTemplateCat, setDialogState, selectedTemplate, valCtrl, ndaCtrl, nocCtrl, nicCtrl, () => setDialogState(() => step = 0), () => setDialogState(() => step = 2)),
                if (step == 2) _buildStepNANDA(cs, ndaCtrl, () => setDialogState(() => step = 1), () => setDialogState(() => step = 3)),
                if (step == 3) _buildStepNOC(cs, nocCtrl, () => setDialogState(() => step = 2), () => setDialogState(() => step = 4)),
                if (step == 4) _buildStepNIC(cs, nicCtrl, () => setDialogState(() => step = 3), () => setDialogState(() => step = 5)),
                if (step == 5) _buildStepEvaluacion(cs, valCtrl, evalCtrl, setDialogState, () => setDialogState(() => step = 4), () async {
                  final data = {
                    'paciente': pacCtrl.text,
                    'valoracion': valCtrl.text,
                    'diagnostico_nanda': ndaCtrl.text,
                    'objetivos_noc': nocCtrl.text,
                    'intervenciones_nic': nicCtrl.text,
                    'evaluacion': evalCtrl.text.isNotEmpty ? evalCtrl.text : '{"estado":"activo","notas":""}',
                  };
                  if (editar != null) data['id'] = editar['id'];
                  await ApiService.crearPlanPae(data);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _load();
                  }
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(ColorScheme cs, int step, StateSetter setDialogState) {
    final steps = ['Paciente', 'Plantilla', 'NANDA', 'NOC', 'NIC', 'Evaluación'];
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i == step;
        final done = i < step;
        return Expanded(
          child: GestureDetector(
            onTap: () => setDialogState(() => step = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? cs.primary : active ? cs.primary : cs.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: done
                        ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                        : Text('${i + 1}', style: TextStyle(fontSize: 12, color: active ? cs.onPrimary : cs.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(steps[i], style: TextStyle(fontSize: 9, color: active ? cs.primary : cs.onSurfaceVariant)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepPaciente(ColorScheme cs, TextEditingController pacCtrl, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 1: Identificación del Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: pacCtrl,
          style: TextStyle(color: cs.onSurface),
          decoration: const InputDecoration(
            labelText: 'Nombre del paciente',
            prefixIcon: Icon(Icons.person_rounded),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Siguiente: Plantilla'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTemplate(ColorScheme cs, String? filterCat, StateSetter setDialogState, String selectedTemplate, TextEditingController valCtrl, TextEditingController ndaCtrl, TextEditingController nocCtrl, TextEditingController nicCtrl, VoidCallback onPrev, VoidCallback onNext) {
    final keys = _templateKeys;
    var filtered = keys;
    if (filterCat != null) {
      filtered = keys.where((k) => (_templates[k]?['categoria'] ?? '') == filterCat).toList();
    }

    final cats = filtered.map((k) => _templates[k]?['categoria'] ?? 'General').toSet().toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 2: Seleccionar Plantilla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('Elige un diagnóstico o escribe tu propio NANDA', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),

        // Category filters
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ChoiceChip(
                  label: const Text('Todas', style: TextStyle(fontSize: 12)),
                  selected: filterCat == null,
                  onSelected: (_) => setDialogState(() => filterCat = null),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              ...cats.map((c) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ChoiceChip(
                  label: Text(c, style: const TextStyle(fontSize: 12)),
                  selected: filterCat == c,
                  onSelected: (_) => setDialogState(() => filterCat = c),
                  visualDensity: VisualDensity.compact,
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Template list
        ...filtered.map((key) {
          final t = _templates[key]!;
          final isSelected = selectedTemplate == key;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setDialogState(() {
                  selectedTemplate = key;
                  valCtrl.text = key;
                  ndaCtrl.text = t['nanda']!;
                  nocCtrl.text = t['noc']!;
                  nicCtrl.text = t['nic']!;
                });
              },
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.primary, width: 2),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: isSelected ? cs.primary : Colors.transparent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(key, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: cs.onSurface)),
                            Text(t['categoria'] ?? '', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Siguiente: NANDA'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNANDA(ColorScheme cs, TextEditingController ctrl, VoidCallback onPrev, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 3: Diagnóstico NANDA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('Redacta el diagnóstico enfermero con formato NANDA (r/c... m/p...)', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          maxLines: 5,
          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Icon(Icons.assignment_rounded, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Siguiente: NOC'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNOC(ColorScheme cs, TextEditingController ctrl, VoidCallback onPrev, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 4: Objetivos NOC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('Define los criterios de resultado esperados con código NOC', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          maxLines: 5,
          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Icon(Icons.flag_rounded, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Siguiente: NIC'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNIC(ColorScheme cs, TextEditingController ctrl, VoidCallback onPrev, VoidCallback onNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 5: Intervenciones NIC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('Describe las intervenciones de enfermería con código NIC', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          maxLines: 5,
          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Icon(Icons.playlist_add_check_rounded, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Siguiente: Evaluación'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepEvaluacion(ColorScheme cs, TextEditingController valCtrl, TextEditingController evalCtrl, StateSetter setDialogState, VoidCallback onPrev, VoidCallback onSave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 6: Evaluación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('Documenta la valoración inicial y el plan de evaluación', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: valCtrl,
          maxLines: 2,
          style: TextStyle(color: cs.onSurface),
          decoration: const InputDecoration(
            labelText: 'Valoración / Síntoma principal',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: evalCtrl,
          maxLines: 3,
          style: TextStyle(color: cs.onSurface),
          decoration: const InputDecoration(
            labelText: 'Evaluación / Notas',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _estadoSelector(cs, 'Activo', cs.secondary, setDialogState, evalCtrl),
            const SizedBox(width: 8),
            _estadoSelector(cs, 'En Progreso', cs.primary, setDialogState, evalCtrl),
            const SizedBox(width: 8),
            _estadoSelector(cs, 'Completado', cs.tertiary, setDialogState, evalCtrl),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Finalizar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _estadoSelector(ColorScheme cs, String label, Color color, StateSetter setDialogState, TextEditingController evalCtrl) {
    final current = _getEstado(evalCtrl.text);
    final active = current.toLowerCase() == label.toLowerCase().replaceAll(' ', '_');
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: active ? cs.onPrimary : color)),
      selected: active,
      selectedColor: color,
      onSelected: (_) {
        setDialogState(() {
          evalCtrl.text = '{"estado":"${label.toLowerCase().replaceAll(' ', '_')}","notas":""}';
        });
      },
      visualDensity: VisualDensity.compact,
    );
  }


}

