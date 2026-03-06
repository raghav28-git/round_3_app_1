import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  bool _isCollapsed = false;
  late AnimationController _fadeController;
  
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _weeklyReports = true;
  bool _darkMode = false;
  bool _autoBackup = true;
  String _language = 'English';
  String _timezone = 'UTC+0';
  
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController.forward();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? 'Admin User';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildMainSettings()),
                              const SizedBox(width: 24),
                              Expanded(child: _buildQuickActions()),
                            ],
                          ),
                        ],
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
          const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Text('Manage your account preferences and settings', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMainSettings() {
    return Column(
      children: [
        _buildProfileSection(),
        const SizedBox(height: 24),
        _buildSecuritySection(),
        const SizedBox(height: 24),
        _buildNotificationsSection(),
        const SizedBox(height: 24),
        _buildPreferencesSection(),
      ],
    );
  }

  Widget _buildProfileSection() {
    return _SettingsCard(
      title: 'Profile Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildTextField('Full Name', _nameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField('Email Address', _emailController, Icons.email, enabled: false),
          const SizedBox(height: 24),
          Row(
            children: [
              const Spacer(),
              _buildButton('Cancel', () {}, isOutlined: true),
              const SizedBox(width: 12),
              _buildButton('Save Changes', _saveProfile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return _SettingsCard(
      title: 'Security',
      icon: Icons.lock_outline,
      child: Column(
        children: [
          _buildTextField('Current Password', _currentPasswordController, Icons.lock, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField('New Password', _newPasswordController, Icons.lock_open, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField('Confirm Password', _confirmPasswordController, Icons.lock_reset, isPassword: true),
          const SizedBox(height: 24),
          Row(
            children: [
              const Spacer(),
              _buildButton('Update Password', _updatePassword),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return _SettingsCard(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      child: Column(
        children: [
          _buildSwitchTile('Email Notifications', 'Receive updates via email', _emailNotifications, (val) => setState(() => _emailNotifications = val)),
          _buildSwitchTile('Push Notifications', 'Get push notifications on your device', _pushNotifications, (val) => setState(() => _pushNotifications = val)),
          _buildSwitchTile('Weekly Reports', 'Receive weekly summary reports', _weeklyReports, (val) => setState(() => _weeklyReports = val)),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _SettingsCard(
      title: 'Preferences',
      icon: Icons.tune_outlined,
      child: Column(
        children: [
          _buildSwitchTile('Dark Mode', 'Enable dark theme', _darkMode, (val) => setState(() => _darkMode = val)),
          _buildSwitchTile('Auto Backup', 'Automatically backup data', _autoBackup, (val) => setState(() => _autoBackup = val)),
          const SizedBox(height: 16),
          _buildDropdownField('Language', _language, ['English', 'Spanish', 'French', 'German'], (val) => setState(() => _language = val!)),
          const SizedBox(height: 16),
          _buildDropdownField('Timezone', _timezone, ['UTC+0', 'UTC+1', 'UTC+2', 'UTC-5', 'UTC-8'], (val) => setState(() => _timezone = val!)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard('Export Data', 'Download all your data', Icons.download, const Color(0xFF6366F1), _exportData),
        const SizedBox(height: 16),
        _buildActionCard('Clear Cache', 'Free up storage space', Icons.cleaning_services, const Color(0xFF8B5CF6), _clearCache),
        const SizedBox(height: 16),
        _buildActionCard('Help & Support', 'Get help with your account', Icons.help_outline, const Color(0xFF10B981), _showHelp),
        const SizedBox(height: 16),
        _buildActionCard('Delete Account', 'Permanently delete account', Icons.delete_forever, const Color(0xFFEF4444), _deleteAccount),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFFF4A3D)),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF4A3D), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF4A3D),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {bool isOutlined = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : const Color(0xFFFF4A3D),
        foregroundColor: isOutlined ? Colors.grey.shade700 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: isOutlined ? BorderSide(color: Colors.grey.shade300) : BorderSide.none),
        elevation: isOutlined ? 0 : 2,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Color(0xFF10B981)),
    );
  }

  void _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(email: user!.email!, password: _currentPasswordController.text);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);
      
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...'), backgroundColor: Color(0xFF6366F1)),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully'), backgroundColor: Color(0xFF10B981)),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For assistance, please contact:\n\nEmail: support@smartcity.com\nPhone: +1 (555) 123-4567'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested'), backgroundColor: Color(0xFFEF4444)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4A3D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFFF4A3D), size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
