import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<dynamic> _patients = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.listPatients();
      setState(() { _patients = data; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) { _loadPatients(); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.searchPatients(q.trim());
      setState(() { _patients = data; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _loadPatients(); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
              ),
              onSubmitted: _search,
              onChanged: (v) { setState(() {}); if (v.isEmpty) _loadPatients(); },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: cs.error)))
                    : _patients.isEmpty
                        ? Center(child: Text('Sin pacientes', style: TextStyle(color: cs.onSurfaceVariant)))
                        : RefreshIndicator(
                            onRefresh: _loadPatients,
                            child: ListView.builder(
                              itemCount: _patients.length,
                              itemBuilder: (ctx, i) {
                                final p = _patients[i] as Map<String, dynamic>;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: cs.primaryContainer,
                                      child: Text('${(p['full_name'] as String)[0]}', style: TextStyle(color: cs.onPrimaryContainer)),
                                    ),
                                    title: Text(p['full_name'] as String? ?? ''),
                                    subtitle: Text('Edad: ${p['age']}'),
                                    trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => PatientDetailScreen(patientId: p['id'] as int, patientName: p['full_name'] as String? ?? ''),
                                    )),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    String sex = 'M';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo Paciente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'Fecha nac. (YYYY-MM-DD)')),
            DropdownButtonFormField<String>(
              value: sex,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const [DropdownMenuItem(value: 'M', child: Text('Masculino')), DropdownMenuItem(value: 'F', child: Text('Femenino'))],
              onChanged: (v) { if (v != null) sex = v; },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          final parts = nameCtrl.text.trim().split(' ');
          if (parts.length < 2 || dobCtrl.text.trim().isEmpty) return;
          try {
            await ApiService.createPatient({
              'user_id': 1,
              'first_name': parts[0],
              'last_name': parts.sublist(1).join(' '),
              'date_of_birth': dobCtrl.text.trim(),
              'sex': sex,
            });
            Navigator.pop(ctx);
            _loadPatients();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }, child: const Text('Crear')),
      ],
    ));
  }
}

class PatientDetailScreen extends StatefulWidget {
  final int patientId;
  final String patientName;
  const PatientDetailScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Map<String, dynamic>? _patient;
  List<dynamic> _vitals = [];
  List<dynamic> _episodes = [];
  List<dynamic> _prescriptions = [];
  List<dynamic> _notes = [];
  bool _loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; });
    try {
      final results = await Future.wait([
        ApiService.getPatient(widget.patientId),
        ApiService.getVitalsHistory(widget.patientId),
        ApiService.listEpisodes(widget.patientId),
        ApiService.listPrescriptions(widget.patientId),
      ]);
      setState(() {
        _patient = results[0] as Map<String, dynamic>;
        _vitals = results[1] as List<dynamic>;
        _episodes = results[2] as List<dynamic>;
        _prescriptions = results[3] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.patientName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
              ? Center(child: Text('Paciente no encontrado', style: TextStyle(color: cs.error)))
              : Column(
                  children: [
                    _buildPatientHeader(cs),
                    TabBar(
                      tabs: const [
                        Tab(text: 'Signos', icon: Icon(Icons.monitor_heart_outlined, size: 18)),
                        Tab(text: 'Episodios', icon: Icon(Icons.history, size: 18)),
                        Tab(text: 'Rx', icon: Icon(Icons.medication_outlined, size: 18)),
                      ],
                      onTap: (i) => setState(() => _selectedTab = i),
                      labelColor: cs.primary,
                      unselectedLabelColor: cs.onSurfaceVariant,
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTab,
                        children: [
                          _buildVitalsTab(cs),
                          _buildEpisodesTab(cs),
                          _buildPrescriptionsTab(cs),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPatientHeader(ColorScheme cs) {
    final p = _patient!;
    return Container(
      padding: const EdgeInsets.all(16),
      color: cs.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: cs.primaryContainer,
            child: Text('${(p['full_name'] as String)[0]}', style: TextStyle(fontSize: 22, color: cs.onPrimaryContainer))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p['full_name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                Text('${p['age']} años | ${p['sex']} | ${p['blood_type']}', style: TextStyle(color: cs.onSurfaceVariant)),
                if (p['phone'] != null) Text('${p['phone']}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.refresh, color: cs.onSurfaceVariant), onPressed: _loadAll),
        ],
      ),
    );
  }

  Widget _buildVitalsTab(ColorScheme cs) {
    if (_vitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_heart_outlined, size: 48, color: cs.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text('Sin signos vitales', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Registrar'),
              onPressed: () => _showAddVitalsDialog(context),
            ),
          ],
        ),
      );
    }
    final v = _vitals.last as Map<String, dynamic>;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _vitalTile(cs, 'PA', '${v['bp_systolic'] ?? "—"}/${v['bp_diastolic'] ?? "—"}', Icons.bloodtype),
                  _vitalTile(cs, 'FC', '${v['heart_rate'] ?? "—"}', Icons.favorite),
                  _vitalTile(cs, 'T°', v['temperature'] != null ? '${v['temperature']}°C' : '—', Icons.thermostat),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _vitalTile(cs, 'SpO2', '${v['spo2'] ?? "—"}%', Icons.air),
                  _vitalTile(cs, 'FR', '${v['respiratory_rate'] ?? "—"}', Icons.air),
                  _vitalTile(cs, 'IMC', v['bmi'] != null ? '${v['bmi']}' : '—', Icons.monitor_weight),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nuevos Signos'),
          onPressed: () => _showAddVitalsDialog(context),
        ),
        const SizedBox(height: 16),
        Text('Historial', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
        ..._vitals.reversed.take(10).map((v2) {
          final v = v2 as Map<String, dynamic>;
          return ListTile(
            dense: true,
            title: Text('${v['bp_systolic'] ?? "—"}/${v['bp_diastolic'] ?? "—"} | FC: ${v['heart_rate'] ?? "—"} | SpO2: ${v['spo2'] ?? "—"}%'),
            subtitle: Text('${v['measured_at'] ?? ""}'.substring(0, 16)),
          );
        }),
      ],
    );
  }

  Widget _vitalTile(ColorScheme cs, String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: cs.primary, size: 22),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
      Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
    ]);
  }

  Widget _buildEpisodesTab(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.tonalIcon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nuevo Episodio'),
          onPressed: () => _showCreateEpisodeDialog(context),
        ),
        const SizedBox(height: 8),
        if (_episodes.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Sin episodios', style: TextStyle(color: cs.onSurfaceVariant)),
          ))
        else
          ..._episodes.map((e) {
            final ep = e as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ep['is_open'] == true ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ep['is_open'] == true ? Icons.circle : Icons.check_circle_outline,
                    color: ep['is_open'] == true ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                ),
                title: Text(ep['chief_complaint'] as String? ?? ''),
                subtitle: Text('${ep['episode_type']} | ${ep['status']}'),
                trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                onTap: () => _showEpisodeDetail(context, ep),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPrescriptionsTab(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.tonalIcon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva Prescripción'),
          onPressed: () => _showCreatePrescriptionDialog(context),
        ),
        const SizedBox(height: 8),
        if (_prescriptions.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Sin prescripciones', style: TextStyle(color: cs.onSurfaceVariant)),
          ))
        else
          ..._prescriptions.map((rx) {
            final r = rx as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.tertiaryContainer,
                  child: Icon(Icons.medication, color: cs.onTertiaryContainer, size: 18),
                ),
                title: Text(r['medication_name'] as String? ?? ''),
                subtitle: Text('${r['dose']} | ${r['frequency']} | ${r['status']}'),
                trailing: r['days_remaining'] != null
                    ? Text('${r['days_remaining']}d', style: TextStyle(color: cs.onSurfaceVariant))
                    : null,
              ),
            );
          }),
      ],
    );
  }

  void _showAddVitalsDialog(BuildContext context) {
    final sysCtrl = TextEditingController();
    final diaCtrl = TextEditingController();
    final hrCtrl = TextEditingController();
    final spo2Ctrl = TextEditingController();
    final tempCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Signos Vitales'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sysCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PA Sistólica')),
            TextField(controller: diaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PA Diastólica')),
            TextField(controller: hrCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'FC')),
            TextField(controller: spo2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SpO2')),
            TextField(controller: tempCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Temperatura')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          try {
            await ApiService.addVitalSigns(widget.patientId, {
              if (sysCtrl.text.isNotEmpty) 'bp_systolic': int.parse(sysCtrl.text),
              if (diaCtrl.text.isNotEmpty) 'bp_diastolic': int.parse(diaCtrl.text),
              if (hrCtrl.text.isNotEmpty) 'heart_rate': int.parse(hrCtrl.text),
              if (spo2Ctrl.text.isNotEmpty) 'spo2': int.parse(spo2Ctrl.text),
              if (tempCtrl.text.isNotEmpty) 'temperature': double.parse(tempCtrl.text),
              'source': 'manual',
            });
            Navigator.pop(ctx);
            _loadAll();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }, child: const Text('Guardar')),
      ],
    ));
  }

  void _showCreateEpisodeDialog(BuildContext context) {
    final complaintCtrl = TextEditingController();
    String type = 'consultation';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo Episodio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: complaintCtrl, decoration: const InputDecoration(labelText: 'Motivo de consulta')),
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'consultation', child: Text('Consulta')),
              DropdownMenuItem(value: 'emergency', child: Text('Emergencia')),
              DropdownMenuItem(value: 'followup', child: Text('Seguimiento')),
              DropdownMenuItem(value: 'hospitalization', child: Text('Hospitalización')),
            ],
            onChanged: (v) { if (v != null) type = v; },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (complaintCtrl.text.trim().isEmpty) return;
          try {
            await ApiService.createEpisode(widget.patientId, {
              'chief_complaint': complaintCtrl.text.trim(),
              'episode_type': type,
            });
            Navigator.pop(ctx);
            _loadAll();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }, child: const Text('Crear')),
      ],
    ));
  }

  void _showCreatePrescriptionDialog(BuildContext context) {
    final medCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nueva Prescripción'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: medCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID Medicamento')),
            TextField(controller: doseCtrl, decoration: const InputDecoration(labelText: 'Dosis (ej: 500mg)')),
            TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Frecuencia (ej: cada 8h)')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (medCtrl.text.isEmpty || doseCtrl.text.isEmpty || freqCtrl.text.isEmpty || qtyCtrl.text.isEmpty) return;
          try {
            await ApiService.createPrescription(widget.patientId, {
              'medication_id': int.parse(medCtrl.text),
              'dose': doseCtrl.text.trim(),
              'frequency': freqCtrl.text.trim(),
              'quantity': int.parse(qtyCtrl.text),
            });
            Navigator.pop(ctx);
            _loadAll();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }, child: const Text('Crear')),
      ],
    ));
  }

  void _showEpisodeDetail(BuildContext context, Map<String, dynamic> episode) {
    final epId = episode['id'] as int;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _EpisodeDetailScreen(episodeId: epId, episode: episode),
    ));
  }
}

class _EpisodeDetailScreen extends StatefulWidget {
  final int episodeId;
  final Map<String, dynamic> episode;
  const _EpisodeDetailScreen({required this.episodeId, required this.episode});

  @override
  State<_EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<_EpisodeDetailScreen> {
  List<dynamic> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await ApiService.listNotes(widget.episodeId);
      setState(() { _notes = notes; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ep = widget.episode;
    return Scaffold(
      appBar: AppBar(title: Text(ep['chief_complaint'] as String? ?? 'Episodio')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Chip(label: Text(ep['episode_type'] as String? ?? '')),
                    const SizedBox(width: 8),
                    Chip(label: Text(ep['status'] as String? ?? '')),
                  ]),
                  const SizedBox(height: 8),
                  Text('Motivo: ${ep['chief_complaint']}', style: TextStyle(color: cs.onSurface)),
                  if (ep['reason_for_visit'] != null) Text('${ep['reason_for_visit']}', style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Notas Clínicas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir'),
              onPressed: () => _showAddNoteDialog(context),
            ),
          ]),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_notes.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Sin notas', style: TextStyle(color: cs.onSurfaceVariant)),
            ))
          else
            ..._notes.map((n) {
              final note = n as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  title: Text(note['content'] as String? ?? ''),
                  subtitle: Text('${note['note_type']} | ${note['is_signed'] == true ? "Firmada" : "Borrador"}'),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final contentCtrl = TextEditingController();
    String type = 'progress';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nueva Nota'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'progress', child: Text('Evolución')),
              DropdownMenuItem(value: 'nursing', child: Text('Enfermería')),
              DropdownMenuItem(value: 'discharge', child: Text('Alta')),
            ],
            onChanged: (v) { if (v != null) type = v; },
          ),
          TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Contenido')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (contentCtrl.text.trim().isEmpty) return;
          try {
            await ApiService.createNote(widget.episodeId, {
              'content': contentCtrl.text.trim(),
              'note_type': type,
            });
            Navigator.pop(ctx);
            _loadNotes();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }, child: const Text('Guardar')),
      ],
    ));
  }
}
