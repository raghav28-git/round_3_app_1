import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/infrastructure_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/charts.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with TickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  bool _isCollapsed = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String _selectedPeriod = 'This Month';

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
    _fadeController.dispose();
    _slideController.dispose();
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
                  child: StreamBuilder<List<InfrastructureAsset>>(
                    stream: _firebaseService.getAssets(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final assets = snapshot.data ?? [];
                      return FadeTransition(
                        opacity: _fadeController,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 32),
                              _buildMetricsGrid(assets),
                              const SizedBox(height: 32),
                              _buildChartsSection(assets),
                              const SizedBox(height: 32),
                              _buildInsightsSection(assets),
                            ],
                          ),
                        ),
                      );
                    },
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
          const Text('Analytics Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'This Year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF4A3D) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(_slideController),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Infrastructure Analytics',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive insights into your infrastructure assets',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(List<InfrastructureAsset> assets) {
    final typeCount = <String, int>{};
    for (var asset in assets) {
      typeCount[asset.type] = (typeCount[asset.type] ?? 0) + 1;
    }
    final mostCommon = typeCount.entries.isEmpty ? 'N/A' : typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 2 : 1;
        final cardWidth = (constraints.maxWidth - (24 * (crossAxisCount - 1))) / crossAxisCount;
        
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Total Assets',
                value: '${assets.length}',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF6366F1),
                trend: '+12.5%',
                delay: 0,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Asset Types',
                value: '${typeCount.length}',
                icon: Icons.category_outlined,
                color: const Color(0xFF8B5CF6),
                trend: '+2',
                delay: 100,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Most Common',
                value: mostCommon,
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
                trend: '${typeCount[mostCommon] ?? 0} assets',
                delay: 200,
                isText: true,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Locations',
                value: '${assets.map((a) => a.location).toSet().length}',
                icon: Icons.location_on_outlined,
                color: const Color(0xFFF59E0B),
                trend: '+3',
                delay: 300,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(List<InfrastructureAsset> assets) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildChartCard('Asset Distribution by Type', AssetPieChart(assets: assets), _buildTypeLegend(assets))),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: _buildChartCard('Status Overview', AssetBarChart(assets: assets), null)),
          ],
        ),
        const SizedBox(height: 20),
        _buildChartCard('Growth Timeline', AssetLineChart(assets: assets), null),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart, Widget? legend) {
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
                child: const Icon(Icons.bar_chart, color: Color(0xFFFF4A3D), size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(height: 280, child: chart),
          if (legend != null) ...[
            const SizedBox(height: 20),
            legend,
          ],
        ],
      ),
    );
  }

  Widget _buildTypeLegend(List<InfrastructureAsset> assets) {
    final typeCount = <String, int>{};
    for (var asset in assets) {
      typeCount[asset.type] = (typeCount[asset.type] ?? 0) + 1;
    }

    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
      const Color(0xFF6366F1),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: typeCount.entries.map((e) {
        final index = typeCount.keys.toList().indexOf(e.key);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors[index % colors.length].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightsSection(List<InfrastructureAsset> assets) {
    final locationCount = <String, int>{};
    for (var asset in assets) {
      locationCount[asset.location] = (locationCount[asset.location] ?? 0) + 1;
    }
    final sortedLocations = locationCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

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
                child: const Icon(Icons.insights, color: Color(0xFFFF4A3D), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Location Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          ...sortedLocations.take(8).map((e) {
            final percentage = (e.value / assets.length * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                      Text('${e.value} assets ($percentage%)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / assets.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final int delay;
  final bool isText;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.delay,
    this.isText = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.color.withOpacity(0.1), widget.color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: _isHovered ? widget.color.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.trend,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: widget.isText ? 22 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
