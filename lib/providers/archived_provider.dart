import 'package:flutter/material.dart';
import 'package:pbee_collate/models/archived_profile.dart';
import 'package:pbee_collate/service/auth_service.dart';

class ArchiveProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  List<ArchivedProfile> _archives = [];
  bool _isLoading = false;
  String? _error;

  List<ArchivedProfile> get archives => _archives;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchArchives() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('DEBUG: Calling getArchivedUsers...');
      _archives = await _authService.getArchivedUsers();
      debugPrint('DEBUG: fetchArchives success, count: ${_archives.length}');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
