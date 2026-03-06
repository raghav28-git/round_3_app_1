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

class _InfrastructureListPageState extends State<InfrastructureListPage> {
  final _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  bool _isCollapsed = false;
  String? _filterType;
  String? _filterStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _buildFilters(),
                Expanded(child: _buildTable()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
          const SizedBox(width: 16),
          Text(
            'Infrastructure Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _filterType,
            hint: const Text('Filter by Type'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ...InfrastructureAsset.types.map((type) => DropdownMenuItem(value: type, child: Text(type))),
            ],
            onChanged: (value) => setState(() => _filterType = value),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _filterStatus,
            hint: const Text('Filter by Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Status')),
              ...InfrastructureAsset.statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))),
            ],
            onChanged: (value) => setState(() => _filterStatus = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return StreamBuilder<List<InfrastructureAsset>>(
      stream: _firebaseService.getAssets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var assets = snapshot.data ?? [];

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          assets = assets.where((a) =>
              a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }
        if (_filterType != null) {
          assets = assets.where((a) => a.type == _filterType).toList();
        }
        if (_filterStatus != null) {
          assets = assets.where((a) => a.status == _filterStatus).toList();
        }

        if (assets.isEmpty) {
          return const Center(child: Text('No assets found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('Asset Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Last Inspection', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: assets.map((asset) {
                  return DataRow(
                    cells: [
                      DataCell(Text(asset.name)),
                      DataCell(Text(asset.type)),
                      DataCell(Text(asset.location)),
                      DataCell(_buildStatusChip(asset.status)),
                      DataCell(Text(DateFormat('MMM dd, yyyy').format(asset.lastInspectionDate))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () => context.go('/asset-detail/${asset.id}'),
                              tooltip: 'View',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => context.go('/edit-asset/${asset.id}'),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(asset),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Good':
        color = Colors.green;
        break;
      case 'Maintenance Required':
        color = Colors.orange;
        break;
      case 'Damaged':
        color = Colors.red.shade300;
        break;
      case 'Critical':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Future<void> _confirmDelete(InfrastructureAsset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
          const SnackBar(content: Text('Asset deleted successfully')),
        );
      }
    }
  }
}
