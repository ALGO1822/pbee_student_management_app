import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/service/auth_service.dart';

class UserManagementProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  List<Profile> _users = [];
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isUpdatingPayment = false;
  String? _error;
  String _searchQuery = '';
  Timer? _debounce;

  List<Profile> get users => _users;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  bool get isUpdatingPayment => _isUpdatingPayment;
  String? get error => _error;

  // Called when screen loads
  void init() {
    // Only fetch if we haven't already, or force a refresh if needed
    if (_users.isEmpty && _searchQuery.isEmpty) {
      fetchUsers();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // calls the updated getAllProfiles with optional query
      _users = await _authService.getAllProfiles(query: _searchQuery);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handles real-time typing with a 500ms delay
  void onSearchChanged(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;

    // Cancel previous timer if user is still typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchUsers();
    });
  }

  Future<bool> deleteUser(String userId) async {
    _isDeleting = true;
    notifyListeners();

    try {
      await _authService.deleteUserProfile(userId);
      _users.removeWhere((profile) => profile.userId == userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePayment(String userId, double amount) async {
    _isUpdatingPayment = true;
    notifyListeners();

    try {
      await _authService.adminUpdatePayment(userId, amount);

      // Instantly update the local list so the UI reflects the change
      int index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(amountPaid: amount);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdatingPayment = false;
      notifyListeners();
    }
  }

  Future<bool> archiveUser(String userId) async {
    notifyListeners();

    try {
      await _authService.archiveUserProfile(userId);
      // Remove from the local list of active users immediately
      _users.removeWhere((profile) => profile.userId == userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}