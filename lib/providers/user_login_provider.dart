import 'package:flutter/material.dart';
import 'package:pbee_collate/screens/auth_gate.dart';
import 'package:pbee_collate/service/auth_service.dart';

class UserLoginProvider with ChangeNotifier {
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

    final response = await _authService.signInWithEmailPassword(email, password);

    _isLoading = false;
    notifyListeners();

    // Check if the widget is still on screen before using context
    if (!context.mounted) return;

    if (response != null && response.user != null) {
      // SUCCESS: Reset the entire app to AuthGate.
      // This ensures AuthGate is listening to the stream and routes correctly.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    } else {
      // FAILURE: Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}