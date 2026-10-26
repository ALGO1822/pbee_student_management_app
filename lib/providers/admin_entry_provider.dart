import 'package:flutter/material.dart';
import 'package:pbee_collate/screens/admin/admin_dashboard.dart';
import 'package:pbee_collate/service/auth_service.dart';

class AdminEntryProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> handleLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _authService.signInWithEmailPassword(email, password);

      if (response != null && response.user != null) {
        // Login successful, now fetch profile to check role
        final profile = await _authService.getCurrentUserProfile();

        if (!context.mounted) return;

        if (profile.role == 'admin') {
          // SUCCESS: Is Admin
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
            (route) => false,
          );
        } else {
          // FAIL: Is User, not Admin
          await _authService.signOut();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access Denied: You do not have admin privileges.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Login failed at Supabase level (wrong email/pass)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Failed. Please check your credentials.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // CATCH ERRORS HERE (like missing profile)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // ALWAYS reset loading state, even if an error occurred
      _isLoading = false;
      notifyListeners();
    }
  }
}