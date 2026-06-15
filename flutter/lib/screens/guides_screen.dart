import 'package:flutter/material.dart';
import '../services/api_service.dart';


class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  List<String>? _guides;
  String? _content;
  String? _currentGuide;
  bool _loading = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadList();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filteredGuides {
    if (_guides == null) return [];
    if (_searchQuery.isEmpty) return _guides!;
    final q = _searchQuery.toLowerCase();
    return _guides!.where((g) => g.toLowerCase().contains(q)).toList();
  }

  Future<void> _loadList() async {
    setState(() { _loading = true; _content = null; _currentGuide = null; });
    try {
      final g = await ApiService.getGuides();
      setState(() { _guides = g; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  final Map<String, String> _guideSources = {
    'pae_guia_basica.md': 'OMS • 2024 • Dominio público',
    'rcp_avanzado.md': 'American Heart Association • 2023',
    'farmacologia_urgencias.md': 'Ministerio de Salud España • 2023 • CC BY',
    'cuidados_intensivos.md': 'PubMed / NIH • 2024 • Open Access',
    'neonatologia.md': 'OMS / UNICEF • 2023 • Libre distribución',
    'salud_mental.md': 'APA • 2022 • Guías de práctica clínica',
  };

  Future<void> _loadContent(String name) async {
    setState(() { _loading = true; });
    try {
      final c = await ApiService.getGuideContent(name);
      setState(() { _content = c; _currentGuide = name; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _guideIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('pae') || n.contains('enfermer')) return '📋';
    if (n.contains('farmaco') || n.contains('medic')) return '💊';
    if (n.contains('cardio') || n.contains('corazon') || n.contains('ecg')) return '🫀';
    if (n.contains('respiratorio') || n.contains('pulmon') || n.contains('oxigen')) return '🫁';
    if (n.contains('pediatria') || n.contains('neonato') || n.contains('infantil')) return '👶';
    if (n.contains('cirugia') || n.contains('quirur')) return '🔪';
    if (n.contains('urgencia') || n.contains('emergencia') || n.contains('triage')) return '🚑';
    if (n.contains('nutricion') || n.contains('dieta')) return '🥗';
    if (n.contains('salud mental') || n.contains('psiquiatr')) return '🧠';
    return '📄';
  }

  Color _guideColor(String name, ColorScheme cs) {
    final n = name.toLowerCase();
    if (n.contains('pae') || n.contains('enfermer')) return cs.tertiary;
    if (n.contains('farmaco') || n.contains('medic')) return cs.error;
    if (n.contains('cardio')) return cs.primary;
    if (n.contains('respiratorio')) return cs.secondary;
    if (n.contains('pediatria') || n.contains('neonato')) return cs.primary;
    if (n.contains('urgencia') || n.contains('emergencia')) return cs.tertiary;
    if (n.contains('cirugia')) return cs.tertiary;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_content != null) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(_currentGuide?.replaceAll('.md', '').replaceAll('.txt', '') ?? ''),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source metadata
              if (_currentGuide != null && _guideSources.containsKey(_currentGuide))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.source_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fuente: ${_guideSources[_currentGuide]}',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              // Content
              _buildMarkdownContent(cs, _content!),
              // Disclaimer
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.tertiary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: cs.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Contenido educativo basado en fuentes abiertas (guías OMS, PubMed, Ministerio de Salud). '
                        'No infringe derechos de autor. No reemplaza la formación profesional.',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final guides = _filteredGuides;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guías Clínicas'),
        actions: [
          TextButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text('Subir'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar guías...',
                prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant),
                        onPressed: () { _searchCtrl.clear(); },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : guides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(_searchQuery.isNotEmpty ? 'Sin resultados' : 'No hay guías',
                                style: TextStyle(color: cs.onSurfaceVariant)),
                            if (guides.isEmpty && _searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Agrega guías desde "Subir"', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadList,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: guides.length,
                          itemBuilder: (_, i) {
                            final name = guides[i];
                            final display = name.replaceAll('.md', '').replaceAll('.txt', '');
                            final icon = _guideIcon(name);
                            final color = _guideColor(name, cs);
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: cs.outlineVariant),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _loadContent(name),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(icon, style: const TextStyle(fontSize: 22)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              display,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              name.endsWith('.md') ? 'Markdown' : 'Texto',
                                              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(ColorScheme cs, String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    final codeLines = <String>[];

    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(_codeBlock(cs, codeLines.join('\n')));
          codeLines.clear();
          inCodeBlock = false;
        } else {
          inCodeBlock = true;
        }
        continue;
      }
      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      // Header
      if (trimmed.startsWith('### ')) {
        widgets.add(Text(trimmed.substring(4), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.4)));
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        widgets.add(Text(trimmed.substring(3), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.3)));
        widgets.add(const SizedBox(height: 10));
        continue;
      }
      if (trimmed.startsWith('# ')) {
        widgets.add(Text(trimmed.substring(2), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cs.onSurface, height: 1.3)));
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Horizontal rule
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        widgets.add(Divider(color: cs.outlineVariant));
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Unordered list
      if (trimmed.startsWith('- ') || trimmed.startsWith('• ') || trimmed.startsWith('* ')) {
        final text = trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
              Expanded(child: _buildRichText(cs, text)),
            ],
          ),
        ));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Ordered list
      final orderedMatch = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(trimmed);
      if (orderedMatch != null) {
        final num = orderedMatch.group(1)!;
        final text = orderedMatch.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$num. ', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
              Expanded(child: _buildRichText(cs, text)),
            ],
          ),
        ));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Bold line (if entire line is bold)
      if (trimmed.startsWith('**') && trimmed.endsWith('**') && trimmed.length > 4) {
        widgets.add(Text(trimmed.substring(2, trimmed.length - 2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, height: 1.5)));
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Regular paragraph
      widgets.add(_buildRichText(cs, trimmed));
      widgets.add(const SizedBox(height: 6));
    }

    if (codeLines.isNotEmpty) {
      widgets.add(_codeBlock(cs, codeLines.join('\n')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichText(ColorScheme cs, String text) {
    final spans = <TextSpan>[];
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final italicRegex = RegExp(r'\*(.*?)\*');
    int lastEnd = 0;

    final boldMatches = boldRegex.allMatches(text).toList();
    if (boldMatches.isEmpty) {
      final italicMatches = italicRegex.allMatches(text).toList();
      if (italicMatches.isEmpty) {
        spans.add(TextSpan(text: text, style: TextStyle(fontSize: 14, color: cs.onSurface, height: 1.5)));
      } else {
        for (final m in italicMatches) {
          if (m.start > lastEnd) {
            spans.add(TextSpan(text: text.substring(lastEnd, m.start)));
          }
          spans.add(TextSpan(
            text: m.group(1),
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: cs.onSurface, height: 1.5),
          ));
          lastEnd = m.end;
        }
        if (lastEnd < text.length) {
          spans.add(TextSpan(text: text.substring(lastEnd)));
        }
      }
    } else {
      for (final m in boldMatches) {
        if (m.start > lastEnd) {
          final between = text.substring(lastEnd, m.start);
          final italicMatches = italicRegex.allMatches(between).toList();
          if (italicMatches.isNotEmpty) {
            int ilast = 0;
            for (final im in italicMatches) {
              if (im.start > ilast) spans.add(TextSpan(text: between.substring(ilast, im.start)));
              spans.add(TextSpan(text: im.group(1), style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: cs.onSurface, height: 1.5)));
              ilast = im.end;
            }
            if (ilast < between.length) spans.add(TextSpan(text: between.substring(ilast)));
          } else {
            spans.add(TextSpan(text: between));
          }
        }
        spans.add(TextSpan(
          text: m.group(1),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, height: 1.5),
        ));
        lastEnd = m.end;
      }
      if (lastEnd < text.length) {
        spans.add(TextSpan(text: text.substring(lastEnd)));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(fontSize: 14, color: cs.onSurface, height: 1.5),
      ),
    );
  }

  Widget _codeBlock(ColorScheme cs, String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SelectableText(
        code,
        style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: cs.onSurface, height: 1.4),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    final cs = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Subir Guía', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: cs.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Nombre del archivo',
                  hintText: 'ej: MiGuia.md',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 8,
                style: TextStyle(fontSize: 13, color: cs.onSurface, fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  labelText: 'Contenido Markdown',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.code_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () async {
            if (nameCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
            final name = nameCtrl.text.trim();
            final finalName = name.endsWith('.md') ? name : '$name.md';
            try {
              await ApiService.uploadGuide(finalName, contentCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadList();
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          }, child: const Text('Subir')),
        ],
      ),
    );
    nameCtrl.dispose();
    contentCtrl.dispose();
  }
}
