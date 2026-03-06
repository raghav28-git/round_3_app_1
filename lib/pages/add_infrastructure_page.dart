import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../models/infrastructure_model.dart';
import '../widgets/sidebar.dart';

class AddInfrastructurePage extends StatefulWidget {
  const AddInfrastructurePage({super.key});

  @override
  State<AddInfrastructurePage> createState() => _AddInfrastructurePageState();
}

class _AddInfrastructurePageState extends State<AddInfrastructurePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCollapsed = false;
  bool _isLoading = false;
  String? _selectedType;
  String? _selectedStatus;
  DateTime _lastInspectionDate = DateTime.now();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final asset = InfrastructureAsset(
        name: _nameController.text.trim(),
        type: _selectedType!,
        location: _locationController.text.trim(),
        status: _selectedStatus!,
        description: _descriptionController.text.trim(),
        lastInspectionDate: _lastInspectionDate,
        createdAt: DateTime.now(),
      );

      await _firebaseService.addAsset(asset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Asset added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(_slideController),
                            child: _buildForm(),
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
          const Text('Add New Asset', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.go('/infrastructure'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Asset Name',
              hint: 'Enter asset name',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildCustomDropdown(
                  label: 'Asset Type',
                  value: _selectedType,
                  items: InfrastructureAsset.types,
                  icon: Icons.category_outlined,
                  onChanged: (v) => setState(() => _selectedType = v),
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildCustomDropdown(
                  label: 'Status',
                  value: _selectedStatus,
                  items: InfrastructureAsset.statuses,
                  icon: Icons.flag_outlined,
                  onChanged: (v) => setState(() => _selectedStatus = v),
                )),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Location Details', Icons.location_on_outlined),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter location',
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Inspection Information', Icons.calendar_today_outlined),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 32),
            _buildSectionHeader('Additional Details', Icons.description_outlined),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter detailed description',
              icon: Icons.notes,
              maxLines: 5,
            ),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4A3D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF4A3D), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4A3D), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            hint: Text('Select $label', style: TextStyle(color: Colors.grey.shade600)),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getItemColor(item),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (v) => v == null ? 'Please select $label' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Inspection Date',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _lastInspectionDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Color(0xFFFF4A3D)),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _lastInspectionDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 16),
                Text(
                  '${_lastInspectionDate.day}/${_lastInspectionDate.month}/${_lastInspectionDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.go('/infrastructure'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAsset,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4A3D),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Save Asset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }

  Color _getItemColor(String item) {
    if (InfrastructureAsset.statuses.contains(item)) {
      switch (item) {
        case 'Good':
          return const Color(0xFF10B981);
        case 'Maintenance Required':
          return const Color(0xFFF59E0B);
        case 'Damaged':
          return const Color(0xFFEF4444);
        case 'Critical':
          return const Color(0xFFDC2626);
      }
    }
    return const Color(0xFFFF4A3D);
  }
}
