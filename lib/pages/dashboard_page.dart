import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/infrastructure_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/charts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
                      final goodCount = assets.where((a) => a.status == 'Good').length;
                      final maintenanceCount = assets.where((a) => a.status == 'Maintenance Required').length;
                      final criticalCount = assets.where((a) => a.status == 'Critical').length;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard Overview',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 2 : 1;
                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                  children: [
                                    DashboardCard(
                                      title: 'Total Assets',
                                      value: '${assets.length}',
                                      icon: Icons.account_tree,
                                      color: Colors.blue,
                                    ),
                                    DashboardCard(
                                      title: 'Good Condition',
                                      value: '$goodCount',
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    DashboardCard(
                                      title: 'Under Maintenance',
                                      value: '$maintenanceCount',
                                      icon: Icons.build,
                                      color: Colors.orange,
                                    ),
                                    DashboardCard(
                                      title: 'Critical',
                                      value: '$criticalCount',
                                      icon: Icons.warning,
                                      color: Colors.red,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 900) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildChartCard('Asset Distribution', AssetPieChart(assets: assets))),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildChartCard('Status Overview', AssetBarChart(assets: assets))),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _buildChartCard('Asset Distribution', AssetPieChart(assets: assets)),
                                    const SizedBox(height: 16),
                                    _buildChartCard('Status Overview', AssetBarChart(assets: assets)),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildChartCard('Assets Added Over Time', AssetLineChart(assets: assets)),
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
            'Smart City Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
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
          ],
        ),
      ),
    );
  }
}
