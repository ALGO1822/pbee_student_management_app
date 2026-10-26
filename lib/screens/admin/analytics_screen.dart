import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/providers/analytics_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext c) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: AppBar(
            title: const Text(
              'Reports & Analytics',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: provider.isLoading && provider.kpiData.totalUsers == '0'
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: RefreshIndicator(
                      color: Colors.purple,
                      onRefresh: () => provider.fetchAnalytics(),
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          _buildKpiGrid(provider.kpiData),
                          const SizedBox(height: 32),
                          _buildSectionLabel('User Growth (Last 7 Days)'),
                          const SizedBox(height: 16),
                          _buildUserGrowthChart(provider.userGrowthData),
                          const SizedBox(height: 32),
                          _buildSectionLabel('Course Popularity'),
                          const SizedBox(height: 16),
                          _buildCoursePopularityList(provider.coursePopularity),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildKpiGrid(KpiData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
            'Total Users', data.totalUsers, LucideIcons.users, Colors.blueAccent),
        _buildStatCard('Total Revenue', data.totalRevenue, LucideIcons.badgeDollarSign,
            Colors.green),
        _buildStatCard('Outstanding', data.outstandingBalance,
            LucideIcons.alertTriangle, Colors.orange),
        _buildStatCard('New Users', data.newThisMonth, LucideIcons.userPlus,
            Colors.purpleAccent),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  // --- UPDATED CHART WIDGET ---
  Widget _buildUserGrowthChart(List<UserGrowthDataPoint> data) {
    final maxCount = data.map((e) => e.count).fold(0, (max, v) => v > max ? v : max);

    if (data.isEmpty) return _buildChartPlaceholder();

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount * 1.2).toDouble() + 1,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // Dark, modern tooltip
              getTooltipColor: (group) => Colors.grey,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${data[groupIndex].count} users',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.length) return const Text('');
                  final String day = DateFormat('E').format(data[index].day);
                  return Text(day,
                      style: const TextStyle(color: Colors.grey, fontSize: 12));
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() == 0 || value.toInt() == maxCount) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 12));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          barGroups: data
              .asMap()
              .map(
                (index, d) => MapEntry(
                  index,
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: d.count.toDouble(),
                        width: 16,
                        // Rounded corners for a "pill" look
                        borderRadius: BorderRadius.circular(4), 
                        // Modern gradient
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.purple.shade600,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.barChart2, color: Colors.purple.shade100, size: 48),
            const SizedBox(height: 16),
            Text(
              'No new user data for the last 7 days.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePopularityList(Map<String, int> popularity) {
    // Convert map to a sorted list
    final sortedList = popularity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedList.isEmpty) {
      return Container(
         height: 100,
         decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
         child: Center(
           child: Text(
            'No course enrollment data yet.',
             style: TextStyle(color: Colors.grey.shade500),
           ),
         ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: sortedList.map((entry) {
          return ListTile(
            leading: const Icon(LucideIcons.graduationCap, color: Colors.purple),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text(
              '${entry.value} Users',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }
}