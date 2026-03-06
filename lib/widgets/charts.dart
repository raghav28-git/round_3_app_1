import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/infrastructure_model.dart';

class AssetPieChart extends StatelessWidget {
  final List<InfrastructureAsset> assets;

  const AssetPieChart({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
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

    return PieChart(
      PieChartData(
        sections: typeCount.entries.map((e) {
          final index = typeCount.keys.toList().indexOf(e.key);
          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${e.value}',
            color: colors[index % colors.length],
            radius: 60,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class AssetBarChart extends StatelessWidget {
  final List<InfrastructureAsset> assets;

  const AssetBarChart({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    final statusCount = <String, int>{};
    for (var asset in assets) {
      statusCount[asset.status] = (statusCount[asset.status] ?? 0) + 1;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (statusCount.values.isEmpty ? 10 : statusCount.values.reduce((a, b) => a > b ? a : b)).toDouble() + 5,
        barGroups: statusCount.entries.map((e) {
          final index = statusCount.keys.toList().indexOf(e.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: _getStatusColor(e.key),
                width: 40,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final statuses = statusCount.keys.toList();
                if (value.toInt() >= statuses.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    statuses[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Good':
        return Colors.green;
      case 'Maintenance Required':
        return Colors.orange;
      case 'Damaged':
        return Colors.red.shade300;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class AssetLineChart extends StatelessWidget {
  final List<InfrastructureAsset> assets;

  const AssetLineChart({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    final sortedAssets = List<InfrastructureAsset>.from(assets)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final monthCount = <String, int>{};
    for (var asset in sortedAssets) {
      final key = '${asset.createdAt.month}/${asset.createdAt.year}';
      monthCount[key] = (monthCount[key] ?? 0) + 1;
    }

    final spots = monthCount.entries.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    if (spots.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
