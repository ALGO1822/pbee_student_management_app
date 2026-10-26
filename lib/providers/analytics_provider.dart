import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbee_collate/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for KPI cards (Key Performance Indicators)
class KpiData {
  // ... (existing code) ...
  final String totalUsers;
  final String totalRevenue;
  final String outstandingBalance;
  final String newThisMonth;

  KpiData({
    this.totalUsers = '0',
    this.totalRevenue = '₦0',
    this.outstandingBalance = '₦0',
    this.newThisMonth = '0',
  });
}

// --- NEW: Model for our bar chart data points ---
class UserGrowthDataPoint {
  final DateTime day;
  final int count;
  UserGrowthDataPoint({required this.day, required this.count});
}
// ------------------------------------------------

class AnalyticsProvider with ChangeNotifier {
  final SupabaseClient _supabase = supabase;

  KpiData _kpiData = KpiData();
  Map<String, int> _coursePopularity = {};
  List<UserGrowthDataPoint> _userGrowthData = []; // --- NEW ---
  bool _isLoading = false;

  KpiData get kpiData => _kpiData;
  Map<String, int> get coursePopularity => _coursePopularity;
  List<UserGrowthDataPoint> get userGrowthData => _userGrowthData; // --- NEW ---
  bool get isLoading => _isLoading;

  final _currencyFormat =
      NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Run all 3 functions in parallel for speed
      final kpiFuture = _supabase.rpc('get_kpi_analytics');
      final courseFuture = _supabase.rpc('get_course_popularity');
      final chartFuture = _supabase.rpc('get_user_growth_chart_data'); // --- NEW ---

      // Wait for all to finish
      final results = await Future.wait([kpiFuture, courseFuture, chartFuture]);

      // --- Process KPI Data ---
      final kpiJson = results[0] as Map<String, dynamic>;
      _kpiData = KpiData(
        totalUsers: (kpiJson['total_users'] ?? 0).toString(),
        totalRevenue:
            _currencyFormat.format(kpiJson['total_revenue'] ?? 0),
        outstandingBalance:
            _currencyFormat.format(kpiJson['outstanding_balance'] ?? 0),
        newThisMonth: (kpiJson['new_this_month'] ?? 0).toString(),
      );

      // --- Process Course Popularity Data ---
      final courseList = results[1] as List<dynamic>;
      _coursePopularity = Map.fromEntries(
        courseList.map(
          (item) => MapEntry(
            item['title'] as String,
            (item['count'] as int?) ?? 0,
          ),
        ),
      );

      // --- NEW: Process Chart Data ---
      final chartList = results[2] as List<dynamic>? ?? [];
      _userGrowthData = chartList.map((item) {
        return UserGrowthDataPoint(
          day: DateTime.parse(item['day']).toLocal(),
          count: (item['count'] as int?) ?? 0,
        );
      }).toList();
      // -----------------------------

    } catch (e) {
      debugPrint("Error fetching analytics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}