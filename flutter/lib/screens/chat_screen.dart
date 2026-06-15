import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ModelOption {
  final String id;
  final String nombre;
  final String descripcion;
  final String badge;
  final String fuente;
  const ModelOption(this.id, this.nombre, this.descripcion, this.badge, this.fuente);
}

const List<ModelOption> _models = [
  ModelOption('phi4-mini', 'Phi-4 Mini', 'Modelo médico ligero local', 'Recomendado', 'Ollama'),
  ModelOption('llama3.2:3b', 'Llama 3.2 3B', 'Balance velocidad/calidad', 'Popular', 'Ollama'),
  ModelOption('mistral:7b', 'Mistral 7B', 'Mayor precisión', 'Preciso', 'Ollama'),
  ModelOption('llama3:8b', 'Llama 3 8B', 'Modelo general potente', 'Potente', 'Ollama'),
  ModelOption('medllama2', 'MedLlama2', 'Modelo médico especializado', 'Médico', 'Ollama'),
  ModelOption('hf-deepseek', 'DeepSeek Coder (HF)', 'IA via HuggingFace', 'HF', 'HuggingFace'),
  ModelOption('hf-mistral', 'Mistral HF', 'Mistral via HuggingFace', 'HF', 'HuggingFace'),
  ModelOption('hf-meditron', 'Meditron (HF)', 'Modelo médico HF', 'Médico HF', 'HuggingFace'),
];

const List<Map<String, String>> _quickActions = [
  {'icon': '💊', 'text': 'Dosis de Heparina'},
  {'icon': '🩸', 'text': 'Tubos de Laboratorio'},
  {'icon': '🚑', 'text': 'Medicamentos Urgencias'},
  {'icon': '🫀', 'text': 'Signos de Alarma'},
  {'icon': '🧪', 'text': 'Interpretación Gases'},
  {'icon': '📋', 'text': 'PAE Dolor Agudo'},
  {'icon': '📚', 'text': 'Buscar en Guías'},
  {'icon': '🩺', 'text': 'Resumen Clínico'},
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  int _selectedModelIndex = 0;
  bool _useRag = false;
  bool _useWeb = false;
  bool _showSources = true;
  List<String> _availableDocs = [];
  Set<String> _selectedDocs = {};

  static final List<Map<String, dynamic>> _sessionHistory = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_sessionHistory);
    _loadAvailableDocs();
  }

  Future<void> _loadAvailableDocs() async {
    try {
      final docs = await ApiService.getGuides();
      if (mounted) {
        setState(() => _availableDocs = docs);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _currentModelId => _models[_selectedModelIndex].id;
  String get _currentModelName => _models[_selectedModelIndex].nombre;
  String get _currentModelFuente => _models[_selectedModelIndex].fuente;

  void _sendMessage({String? text}) {
    final msg = text ?? _controller.text.trim();
    if (msg.isEmpty) return;

    final userMsg = {'role': 'user', 'text': msg, 'time': DateTime.now().millisecondsSinceEpoch};
    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    _sessionHistory.add(userMsg);
    _controller.clear();
    _scrollToBottom();
    _getResponse(msg);
  }

  Future<void> _getResponse(String mensaje) async {
    try {
      final res = await ApiService.enviarMensajeChat(
        mensaje,
        modelo: _currentModelId,
        useRag: _useRag,
        useWeb: _useWeb,
      );
      final respuesta = res['respuesta'] ?? res['response'] ?? res['message'] ?? 'Sin respuesta';
      final fuentes = res['fuentes'] ?? res['sources'] as List? ?? [];
      final modeloUsado = res['modelo_usado'] as String? ?? _currentModelName;
      final webResults = res['web_results'] as List? ?? [];

      final assistantMsg = {
        'role': 'assistant',
        'text': respuesta.toString(),
        'time': DateTime.now().millisecondsSinceEpoch,
        'modelo': modeloUsado,
        'fuentes': fuentes is List ? List<String>.from(fuentes) : <String>[],
        'web_results': webResults is List ? List<Map<String, dynamic>>.from(webResults) : <Map<String, dynamic>>[],
        'fuente_origen': _currentModelFuente,
        'web_searched': _useWeb,
      };
      setState(() {
        _messages.add(assistantMsg);
      });
      _sessionHistory.add(assistantMsg);
    } catch (e) {
      final errorMsg = {
        'role': 'assistant',
        'text': '⚠️ Error de conexión. Verifica que Ollama esté corriendo o la configuración de HuggingFace.',
        'time': DateTime.now().millisecondsSinceEpoch,
        'error': true,
        'fuentes': <String>[],
      };
      setState(() {
        _messages.add(errorMsg);
      });
      _sessionHistory.add(errorMsg);
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() => _messages.clear());
    _sessionHistory.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado al portapapeles'), duration: Duration(seconds: 1)),
    );
  }

  void _showSaveDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar conversación'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Título de la conversación',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveConversation(
                controller.text.trim().isEmpty
                    ? 'Chat ${DateTime.now().millisecond}'
                    : controller.text.trim(),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConversation(String titulo) async {
    try {
      await ApiService.guardarConversacion({
        'titulo': titulo,
        'modelo': _currentModelId,
        'mensajes': _messages,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversación guardada'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHf = _currentModelFuente == 'HuggingFace';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(isHf ? Icons.cloud_rounded : Icons.smart_toy_rounded, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asistente Clínico'),
                Text(
                  '$_currentModelName • $_currentModelFuente',
                  style: TextStyle(fontSize: 10, color: cs.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: _showSaveDialog,
              icon: const Icon(Icons.bookmark_rounded),
              tooltip: 'Guardar conversación',
            ),
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: _clearChat,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Limpiar chat',
            ),
        ],
      ),
      body: Column(
        children: [
          // Model selector + RAG toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.5),
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_models.length, (i) {
                      final selected = i == _selectedModelIndex;
                      final model = _models[i];
                      final isHfModel = model.fuente == 'HuggingFace';
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedModelIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: selected ? cs.primary.withOpacity(0.12) : cs.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? cs.primary : cs.outlineVariant,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isHfModel ? Icons.cloud_outlined : Icons.memory_outlined, size: 12, color: selected ? cs.primary : cs.onSurfaceVariant),
                                const SizedBox(width: 3),
                                Text(
                                  model.badge,
                                  style: TextStyle(fontSize: 8, color: selected ? cs.primary : cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  model.nombre,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected ? cs.primary : cs.onSurfaceVariant,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: _useRag ? cs.tertiary : cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('RAG', style: TextStyle(fontSize: 11, color: _useRag ? cs.tertiary : cs.onSurfaceVariant, fontWeight: _useRag ? FontWeight.w600 : FontWeight.normal)),
                    Switch(
                      value: _useRag,
                      onChanged: (v) => setState(() => _useRag = v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (_useRag)
                      Text('(guías)', style: TextStyle(fontSize: 10, color: cs.tertiary)),
                    const SizedBox(width: 8),
                    Icon(Icons.language_rounded, size: 14, color: _useWeb ? cs.tertiary : cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Web', style: TextStyle(fontSize: 11, color: _useWeb ? cs.tertiary : cs.onSurfaceVariant, fontWeight: _useWeb ? FontWeight.w600 : FontWeight.normal)),
                    Switch(
                      value: _useWeb,
                      onChanged: (v) => setState(() => _useWeb = v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Spacer(),
                    Icon(Icons.source_rounded, size: 14, color: _showSources ? cs.primary : cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Fuentes', style: TextStyle(fontSize: 11, color: _showSources ? cs.primary : cs.onSurfaceVariant)),
                    Switch(
                      value: _showSources,
                      onChanged: (v) => setState(() => _showSources = v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                if (_useRag && _availableDocs.isNotEmpty)
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _availableDocs.map((doc) {
                        final selected = _selectedDocs.contains(doc);
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: FilterChip(
                            label: Text(doc.replaceAll('.md', '').replaceAll('.txt', ''), style: const TextStyle(fontSize: 10)),
                            selected: selected,
                            onSelected: (v) {
                              setState(() {
                                if (v) { _selectedDocs.add(doc); } else { _selectedDocs.remove(doc); }
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState(cs) : _buildMessagesList(cs),
          ),

          // Loading
          if (_loading) _buildLoadingIndicator(cs),

          // Input
          _buildInputBar(cs),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: cs.primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              'Pregunta al asistente clínico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: cs.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Consultas sobre fármacos, procedimientos y más',
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _useRag ? cs.tertiary.withOpacity(0.1) : cs.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _useRag && _useWeb
                    ? '🔍 RAG + Web activados'
                    : _useRag
                        ? '🔍 RAG activado — respuestas basadas en guías'
                        : _useWeb
                            ? '🌐 Web activada — búsqueda en internet'
                            : '💬 Modo conversación libre',
                style: TextStyle(fontSize: 11, color: (_useRag || _useWeb) ? cs.tertiary : cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _quickActions.map((a) {
                return ActionChip(
                  avatar: Text(a['icon']!, style: const TextStyle(fontSize: 16)),
                  label: Text(a['text']!, style: const TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage(text: a['text']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ColorScheme cs) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        final isError = msg['error'] == true;
        final fuentes = msg['fuentes'] as List<String>? ?? [];
        final webResults = msg['web_results'] as List<Map<String, dynamic>>? ?? [];
        return Column(
          children: [
            _buildBubble(msg['text'] as String, isUser, isError, cs),
            if (!isUser && _showSources && fuentes.isNotEmpty)
              _buildSources(cs, fuentes),
            if (!isUser && _showSources && webResults.isNotEmpty)
              _buildWebResults(cs, webResults, msg),
            if (!isUser && _showSources && webResults.isEmpty && msg['web_searched'] == true)
              _buildNoWebResults(cs),
          ],
        );
      },
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  Widget _buildNoWebResults(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, top: 4, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.language_rounded, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '🌐 Sin resultados web',
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildWebResults(ColorScheme cs, List<Map<String, dynamic>> webResults, Map<String, dynamic> msg) {
    final expandedAll = msg['web_expanded'] == true;
    final displayResults = expandedAll ? webResults : webResults.take(3).toList();
    return Padding(
      padding: const EdgeInsets.only(left: 44, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.language_rounded, size: 12, color: cs.tertiary),
                const SizedBox(width: 4),
                Text(
                  '🌐 ${webResults.length} resultado(s) web',
                  style: TextStyle(fontSize: 10, color: cs.tertiary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...displayResults.map((r) {
            final title = r['title'] as String? ?? '';
            final snippet = r['snippet'] as String? ?? '';
            final url = r['url'] as String? ?? '';
            final domain = _extractDomain(url);
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snippet,
                    style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.link_rounded, size: 9, color: cs.primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          domain,
                          style: TextStyle(fontSize: 9, color: cs.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          if (webResults.length > 3)
            GestureDetector(
              onTap: () {
                setState(() {
                  msg['web_expanded'] = !expandedAll;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  expandedAll ? 'Mostrar menos' : '+ ${webResults.length - 3} más',
                  style: TextStyle(fontSize: 9, color: cs.primary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSources(ColorScheme cs, List<String> fuentes) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, top: 2, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.source_rounded, size: 10, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Fuentes: ${fuentes.join(', ')}',
              style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser, bool isError, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  child: Icon(Icons.smart_toy_rounded, color: cs.primary, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? cs.primary : cs.surfaceVariant.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: isUser ? cs.onPrimary : (isError ? cs.error : cs.onSurface),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primary,
                  child: Icon(Icons.person_rounded, color: cs.onPrimary, size: 16),
                ),
              ],
            ],
          ),
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 4),
              child: GestureDetector(
                onTap: () => _copyMessage(text),
                child: Text('Copiar respuesta', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme cs) {
    final labels = <String>[];
    if (_useWeb) labels.add('🌐 web');
    if (_useRag) labels.add('📚 guías');
    final suffix = labels.isEmpty ? '' : ' (${labels.join(' + ')})';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: cs.primary.withOpacity(0.12),
            child: Icon(Icons.smart_toy_rounded, color: cs.primary, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                ),
                const SizedBox(width: 8),
                Text('Pensando$suffix...', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: _loading ? null : (_) => _sendMessage(),
                minLines: 1,
                maxLines: 4,
                style: TextStyle(color: cs.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Escribe tu consulta clínica...',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6), fontSize: 14),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _loading ? cs.onSurfaceVariant.withOpacity(0.2) : cs.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                onPressed: _loading ? null : _sendMessage,
                icon: Icon(_loading ? Icons.hourglass_top : Icons.send_rounded, size: 20),
                color: _loading ? cs.onSurfaceVariant : cs.onPrimary,
                tooltip: 'Enviar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
