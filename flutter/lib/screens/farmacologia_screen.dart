import 'package:flutter/material.dart';
import '../services/api_service.dart';


class FarmacologiaScreen extends StatefulWidget {
  const FarmacologiaScreen({super.key});

  @override
  State<FarmacologiaScreen> createState() => _FarmacologiaScreenState();
}

class _FarmacologiaScreenState extends State<FarmacologiaScreen> {
  List<String> _categorias = [];
  String? _selectedCategoria;
  List<Map<String, dynamic>> _medicamentos = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final Set<int> _expanded = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await ApiService.getFarmacologiaCategorias();
      setState(() {
        _categorias = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar categorías: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMedicamentos({bool reset = true}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _loading = true;
        _error = null;
        _medicamentos = [];
        _expanded.clear();
      });
    }
    try {
      final data = await ApiService.getFarmacologia(
        categoria: _selectedCategoria,
        page: _page,
        perPage: 20,
      );
      setState(() {
        _medicamentos = [..._medicamentos, ...List<Map<String, dynamic>>.from(data['resultados'])];
        _total = data['total'] as int;
        _totalPages = data['total_pages'] as int;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar: $e';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _selectCategoria(String? cat) {
    setState(() {
      _selectedCategoria = cat;
      _isSearching = false;
      _searchCtrl.clear();
    });
    _loadMedicamentos();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty && _isSearching) {
      setState(() => _isSearching = false);
      if (_selectedCategoria != null) {
        _loadMedicamentos();
      } else {
        setState(() {
          _medicamentos = [];
          _total = 0;
        });
      }
    }
  }

  Future<void> _buscar(String q) async {
    if (q.isEmpty) return;
    setState(() {
      _isSearching = true;
      _loading = true;
      _selectedCategoria = null;
      _error = null;
    });
    try {
      final data = await ApiService.buscarFarmacologia(q);
      setState(() {
        _medicamentos = List<Map<String, dynamic>>.from(data['resultados']);
        _total = data['total'] as int;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error en búsqueda: $e';
        _loading = false;
      });
    }
  }

  void _loadMore() {
    if (_loadingMore || _page >= _totalPages) return;
    setState(() {
      _page++;
      _loadingMore = true;
    });
    _loadMedicamentos(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmacología'),
        actions: [
          if (_total > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text('$_total fármacos', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(cs),
          _buildCategoryChips(cs),
          Expanded(child: _buildContent(cs)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, categoría o indicación...',
          hintStyle: TextStyle(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    _searchFocus.unfocus();
                    if (_isSearching) {
                      setState(() => _isSearching = false);
                      if (_selectedCategoria != null) _loadMedicamentos();
                    }
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _buscar,
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme cs) {
    if (_loading && _categorias.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _categorias.length + 1,
        itemBuilder: (_, i) {
          final sel = i == 0 ? _selectedCategoria == null : _categorias[i - 1] == _selectedCategoria;
          final label = i == 0 ? 'Todas' : _categorias[i - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: sel,
              label: Text(label, style: TextStyle(fontSize: 12)),
              onSelected: (_) => _selectCategoria(i == 0 ? null : _categorias[i - 1]),
              visualDensity: VisualDensity.compact,
              selectedColor: cs.primary.withValues(alpha: 0.15),
              checkmarkColor: cs.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: cs.error)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadCategorias,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_medicamentos.isEmpty) {
      final hasQuery = _selectedCategoria != null || _isSearching;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'Sin resultados' : 'Explora la farmacología',
              style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              hasQuery
                  ? 'No hay fármacos que coincidan con los criterios seleccionados'
                  : 'Selecciona una categoría o busca un medicamento para comenzar',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: _medicamentos.length + (_page < _totalPages ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= _medicamentos.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _loadingMore
                  ? const CircularProgressIndicator()
                  : TextButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text('Cargar más (${_medicamentos.length}/$_total)'),
                    ),
            ),
          );
        }
        return _buildDrugCard(_medicamentos[i], i, cs);
      },
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> m, int i, ColorScheme cs) {
    final id = m['id'] as int? ?? i;
    final nombre = (m['nombre_generico'] ?? 'Desconocido') as String;
    final categoria = (m['categoria'] ?? '') as String;
    final alerta = (m['alerta'] ?? '') as String;
    final isExpanded = _expanded.contains(id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: alerta.isNotEmpty
            ? BorderSide(color: cs.error, width: 0.5)
            : BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isExpanded) { _expanded.remove(id); } else { _expanded.add(id); }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    alerta.isNotEmpty ? Icons.warning_amber_rounded : Icons.medication_rounded,
                    color: alerta.isNotEmpty ? cs.error : cs.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        if (categoria.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(categoria, style: TextStyle(fontSize: 10, color: cs.primary)),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              if (alerta.isNotEmpty && !isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, color: cs.error, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            alerta.length > 80 ? '${alerta.substring(0, 80)}...' : alerta,
                            style: TextStyle(color: cs.error, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isExpanded) ...[
                const Divider(height: 20),
                _infoRow('Indicación', m['indicacion'], cs),
                _infoRow('Dosis adulto', m['dosis_adulto'], cs),
                _infoRow('Dosis pediátrica', m['dosis_pediatrica'], cs),
                _infoRow('Vía', m['via'], cs),
                _infoRow('Presentación', m['presentacion'], cs),
                _infoRow('Contraindicaciones', m['contraindicaciones'], cs),
                _infoRow('Interacciones', m['interacciones'], cs),
                _infoRow('Efectos adversos', m['efectos_adversos'], cs),
                _infoRow('Embarazo / Lactancia', m['embarazo_lactancia'], cs),
                _infoRow('Mecanismo de acción', m['mecanismo_accion'], cs),
                _infoRow('Precauciones', m['precauciones'], cs),
                if (alerta.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_rounded, color: cs.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(alerta, style: TextStyle(color: cs.error, fontWeight: FontWeight.w500, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value, ColorScheme cs) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
          ),
          Expanded(
            child: Text(value.toString(), style: TextStyle(fontSize: 12, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
