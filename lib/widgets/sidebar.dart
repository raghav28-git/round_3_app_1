import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentRoute = '/dashboard';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    _currentRoute = currentPath;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1e3c72),
            const Color(0xFF2a5298),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Expanded(child: _buildNavItems()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isCollapsed ? 16 : 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4A3D), Color(0xFFFF6B5A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4A3D).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_city, color: Colors.white, size: 28),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SMART CITY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Infrastructure Portal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!widget.isCollapsed) const SizedBox(height: 20),
          if (!widget.isCollapsed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFFF4A3D),
                    child: Text(
                      AuthService().currentUser?.email?.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthService().currentUser?.displayName ?? 'Admin User',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Administrator',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItems() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 8 : 16, vertical: 8),
      children: [
        _NavItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          isCollapsed: widget.isCollapsed,
          isActive: _currentRoute == '/dashboard',
          onTap: () => context.go('/dashboard'),
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.account_tree_rounded,
          label: 'Infrastructure',
          isCollapsed: widget.isCollapsed,
          isActive: _currentRoute == '/infrastructure',
          onTap: () => context.go('/infrastructure'),
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.add_circle_rounded,
          label: 'Add Asset',
          isCollapsed: widget.isCollapsed,
          isActive: _currentRoute == '/add-asset',
          onTap: () => context.go('/add-asset'),
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.analytics_rounded,
          label: 'Analytics',
          isCollapsed: widget.isCollapsed,
          isActive: _currentRoute == '/analytics',
          onTap: () => context.go('/analytics'),
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.settings_rounded,
          label: 'Settings',
          isCollapsed: widget.isCollapsed,
          isActive: _currentRoute == '/settings',
          onTap: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 12 : 20),
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.white.withOpacity(0.3), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _NavItem(
          icon: Icons.logout_rounded,
          label: 'Logout',
          isCollapsed: widget.isCollapsed,
          isActive: false,
          onTap: () async {
            await AuthService().signOut();
            if (context.mounted) context.go('/');
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.reverse();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.forward();
      },
      child: ScaleTransition(
        scale: _scaleController,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 16 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              gradient: widget.isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4A3D), Color(0xFFFF6B5A)],
                    )
                  : _isHovered
                      ? LinearGradient(
                          colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.1)],
                        )
                      : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF4A3D).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (widget.isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
