import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AppSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.location_city, color: Colors.white, size: 28),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SMART CITY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: Icons.list_alt,
                  label: 'Infrastructure',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/infrastructure'),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Add Asset',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/add-asset'),
                ),
                _NavItem(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/analytics'),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isCollapsed: isCollapsed,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Divider(color: Colors.white24, height: 1),
          _NavItem(
            icon: Icons.logout,
            label: 'Logout',
            isCollapsed: isCollapsed,
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: Colors.white),
          title: widget.isCollapsed
              ? null
              : Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white),
                ),
          onTap: widget.onTap,
          dense: true,
        ),
      ),
    );
  }
}
