import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/infrastructure_model.dart';
import '../widgets/sidebar.dart';

class InfrastructureListPage extends StatefulWidget {
  const InfrastructureListPage({super.key});

  @override
  State<InfrastructureListPage> createState() => _InfrastructureListPageState();
}

class _InfrastructureListPageState extends State<InfrastructureListPage> with TickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  bool _isCollapsed = false;
  String? _filterType;
  String? _filterStatus;
  String _searchQuery = '';
  String _viewMode = 'grid'; // 'grid' or 'list'
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: _isCollapsed,
            onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                _buildFiltersBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
          const SizedBox(width: 16),
          const Text('Infrastructure Assets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 350,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search assets...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip('Type', _filterType, InfrastructureAsset.types, (v) => setState(() => _filterType = v)),
          const SizedBox(width: 12),
          _buildFilterChip('Status', _filterStatus, InfrastructureAsset.statuses, (v) => setState(() => _filterStatus = v)),
          const Spacer(),
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
        items: [
          DropdownMenuItem(value: null, child: Text('All $label')),
          ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildViewButton(Icons.grid_view, 'grid'),
          _buildViewButton(Icons.view_list, 'list'),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, String mode) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF4A3D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade700, size: 20),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<List<InfrastructureAsset>>(
      stream: _firebaseService.getAssets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var assets = snapshot.data ?? [];

        if (_searchQuery.isNotEmpty) {
          assets = assets.where((a) =>
              a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }
        if (_filterType != null) assets = assets.where((a) => a.type == _filterType).toList();
        if (_filterStatus != null) assets = assets.where((a) => a.status == _filterStatus).toList();

        if (assets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No assets found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeController,
          child: _viewMode == 'grid' ? _buildGridView(assets) : _buildListView(assets),
        );
      },
    );
  }

  Widget _buildGridView(List<InfrastructureAsset> assets) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4 : MediaQuery.of(context).size.width > 1000 ? 3 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) => _AssetCard(asset: assets[index], onDelete: () => _confirmDelete(assets[index])),
    );
  }

  Widget _buildListView(List<InfrastructureAsset> assets) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: assets.length,
      itemBuilder: (context, index) => _AssetListItem(asset: assets[index], onDelete: () => _confirmDelete(assets[index])),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/add-asset'),
      backgroundColor: const Color(0xFFFF4A3D),
      icon: const Icon(Icons.add),
      label: const Text('Add Asset'),
    );
  }

  Future<void> _confirmDelete(InfrastructureAsset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete "${asset.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _firebaseService.deleteAsset(asset.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Asset deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

class _AssetCard extends StatefulWidget {
  final InfrastructureAsset asset;
  final VoidCallback onDelete;

  const _AssetCard({required this.asset, required this.onDelete});

  @override
  State<_AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<_AssetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_getStatusColor(widget.asset.status).withOpacity(0.1), _getStatusColor(widget.asset.status).withOpacity(0.05)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.asset.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getTypeIcon(widget.asset.type), color: _getStatusColor(widget.asset.status), size: 24),
                    ),
                    const Spacer(),
                    _buildStatusBadge(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.asset.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.asset.location,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildActionButton(Icons.visibility_outlined, () => context.go('/asset-detail/${widget.asset.id}')),
                          _buildActionButton(Icons.edit_outlined, () => context.go('/edit-asset/${widget.asset.id}')),
                          _buildActionButton(Icons.delete_outline, widget.onDelete, isDelete: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.asset.status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.asset.status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(widget.asset.status)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Icon(icon, size: 18, color: isDelete ? Colors.red : Colors.grey.shade700),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Good':
        return const Color(0xFF10B981);
      case 'Maintenance Required':
        return const Color(0xFFF59E0B);
      case 'Damaged':
        return const Color(0xFFEF4444);
      case 'Critical':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Road':
        return Icons.route;
      case 'Bridge':
        return Icons.architecture;
      case 'Street Light':
        return Icons.lightbulb_outline;
      case 'Water Pipeline':
        return Icons.water_drop_outlined;
      case 'Drainage':
        return Icons.water;
      case 'Park':
        return Icons.park_outlined;
      case 'Bus Stop':
        return Icons.directions_bus_outlined;
      case 'Public Toilet':
        return Icons.wc;
      case 'Government Building':
        return Icons.account_balance;
      default:
        return Icons.location_city;
    }
  }
}

class _AssetListItem extends StatelessWidget {
  final InfrastructureAsset asset;
  final VoidCallback onDelete;

  const _AssetListItem({required this.asset, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(asset.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getTypeIcon(asset.type), color: _getStatusColor(asset.status)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${asset.type} • ${asset.location}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(asset.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              asset.status,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(asset.status)),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => context.go('/asset-detail/${asset.id}'),
            tooltip: 'View',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/edit-asset/${asset.id}'),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Good':
        return const Color(0xFF10B981);
      case 'Maintenance Required':
        return const Color(0xFFF59E0B);
      case 'Damaged':
        return const Color(0xFFEF4444);
      case 'Critical':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Road':
        return Icons.route;
      case 'Bridge':
        return Icons.architecture;
      case 'Street Light':
        return Icons.lightbulb_outline;
      case 'Water Pipeline':
        return Icons.water_drop_outlined;
      case 'Drainage':
        return Icons.water;
      case 'Park':
        return Icons.park_outlined;
      case 'Bus Stop':
        return Icons.directions_bus_outlined;
      case 'Public Toilet':
        return Icons.wc;
      case 'Government Building':
        return Icons.account_balance;
      default:
        return Icons.location_city;
    }
  }
}
