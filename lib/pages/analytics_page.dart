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

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _firebaseService = FirebaseService();
  bool _isCollapsed = false;

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
                  child: StreamBuilder<List<InfrastructureAsset>>(
                    stream: _firebaseService.getAssets(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final assets = snapshot.data ?? [];

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Infrastructure Analytics',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatsCards(assets),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 900) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildChartCard(
                                          'Assets by Type',
                                          AssetPieChart(assets: assets),
                                          _buildTypeLegend(assets),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildChartCard(
                                          'Assets by Status',
                                          AssetBarChart(assets: assets),
                                          null,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildChartCard(
                                      'Assets by Type',
                                      AssetPieChart(assets: assets),
                                      _buildTypeLegend(assets),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartCard(
                                      'Assets by Status',
                                      AssetBarChart(assets: assets),
                                      null,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildChartCard(
                              'Asset Growth Timeline',
                              AssetLineChart(assets: assets),
                              null,
                            ),
                            const SizedBox(height: 16),
                            _buildLocationStats(assets),
                          ],
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
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<InfrastructureAsset> assets) {
    final typeCount = <String, int>{};
    for (var asset in assets) {
      typeCount[asset.type] = (typeCount[asset.type] ?? 0) + 1;
    }

    final mostCommonType = typeCount.entries.isEmpty
        ? 'N/A'
        : typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('Total Assets', '${assets.length}', Icons.inventory, Colors.blue),
            ),
            Container(width: 1, height: 60, color: Colors.grey.shade300),
            Expanded(
              child: _buildStatItem('Asset Types', '${typeCount.length}', Icons.category, Colors.purple),
            ),
            Container(width: 1, height: 60, color: Colors.grey.shade300),
            Expanded(
              child: _buildStatItem('Most Common', mostCommonType, Icons.trending_up, Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart, Widget? legend) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
            if (legend != null) ...[
              const SizedBox(height: 16),
              legend,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeLegend(List<InfrastructureAsset> assets) {
    final typeCount = <String, int>{};
    for (var asset in assets) {
      typeCount[asset.type] = (typeCount[asset.type] ?? 0) + 1;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: typeCount.entries.map((e) {
        final index = typeCount.keys.toList().indexOf(e.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLocationStats(List<InfrastructureAsset> assets) {
    final locationCount = <String, int>{};
    for (var asset in assets) {
      locationCount[asset.location] = (locationCount[asset.location] ?? 0) + 1;
    }

    final sortedLocations = locationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assets by Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedLocations.take(10).map((e) {
              final percentage = (e.value / assets.length * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${e.value} ($percentage%)', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: e.value / assets.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
