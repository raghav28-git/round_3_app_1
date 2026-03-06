import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../models/infrastructure_model.dart';
import '../widgets/sidebar.dart';

class EditInfrastructurePage extends StatefulWidget {
  final String assetId;

  const EditInfrastructurePage({super.key, required this.assetId});

  @override
  State<EditInfrastructurePage> createState() => _EditInfrastructurePageState();
}

class _EditInfrastructurePageState extends State<EditInfrastructurePage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCollapsed = false;
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _selectedType;
  String? _selectedStatus;
  DateTime _lastInspectionDate = DateTime.now();
  InfrastructureAsset? _asset;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    final asset = await _firebaseService.getAsset(widget.assetId);
    if (asset != null && mounted) {
      setState(() {
        _asset = asset;
        _nameController.text = asset.name;
        _locationController.text = asset.location;
        _descriptionController.text = asset.description;
        _selectedType = asset.type;
        _selectedStatus = asset.status;
        _lastInspectionDate = asset.lastInspectionDate;
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final asset = InfrastructureAsset(
        id: widget.assetId,
        name: _nameController.text.trim(),
        type: _selectedType!,
        location: _locationController.text.trim(),
        status: _selectedStatus!,
        description: _descriptionController.text.trim(),
        lastInspectionDate: _lastInspectionDate,
        createdAt: _asset!.createdAt,
      );

      await _firebaseService.updateAsset(widget.assetId, asset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset updated successfully')),
        );
        context.go('/infrastructure');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                Expanded(
                  child: _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 800),
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit Infrastructure Asset',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 32),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Asset Name *',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        value: _selectedType,
                                        decoration: InputDecoration(
                                          labelText: 'Type *',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        items: InfrastructureAsset.types
                                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                            .toList(),
                                        onChanged: (value) => setState(() => _selectedType = value),
                                        validator: (v) => v == null ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _locationController,
                                        decoration: InputDecoration(
                                          labelText: 'Location *',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        value: _selectedStatus,
                                        decoration: InputDecoration(
                                          labelText: 'Status *',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        items: InfrastructureAsset.statuses
                                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                            .toList(),
                                        onChanged: (value) => setState(() => _selectedStatus = value),
                                        validator: (v) => v == null ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: _lastInspectionDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (date != null) {
                                            setState(() => _lastInspectionDate = date);
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Last Inspection Date *',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${_lastInspectionDate.day}/${_lastInspectionDate.month}/${_lastInspectionDate.year}'),
                                              const Icon(Icons.calendar_today),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Description *',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        maxLines: 4,
                                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isLoading ? null : () => context.go('/infrastructure'),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : _updateAsset,
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                backgroundColor: Colors.blue.shade700,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Text('Update Asset'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
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
            'Edit Infrastructure Asset',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
