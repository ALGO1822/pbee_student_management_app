import 'package:flutter/material.dart';
import 'package:pbee_collate/providers/user_entry_provider.dart'; // <-- IMPORT
import 'package:pbee_collate/service/auth_service.dart';
import 'package:provider/provider.dart'; // <-- IMPORT

class SignOutProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  void handleSignOut(BuildContext context, Widget destination) async {
    // --- THIS IS THE FIX ---
    // Get the UserEntryProvider and reset its state before logging out.
    // 'listen: false' is crucial because we are in a method, not a widget.
    Provider.of<UserEntryProvider>(context, listen: false).reset();
    // -----------------------

    await _authService.signOut();
    
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (route) => false, // This predicate removes all routes
    );
  }
}