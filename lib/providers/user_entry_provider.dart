import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbee_collate/service/auth_service.dart';

class UserEntryProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  File? _selectedImage;

  bool get isLoading => _isLoading;
  File? get selectedImage => _selectedImage;

  void reset() {
    _selectedImage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 500,
    );

    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners();
    }
  }

  Future<String?> handleSignUp({
    required email,
    required password,
    required firstName,
    required lastName,
    required address,
    required phone,
    required course,
    String? notes,
    required formValid,
  }) async {
    if (!formValid) {
      return "Form is invalid.";
    }

    _isLoading = true;
    notifyListeners();

    String? errorMessage;
    try {
      errorMessage = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        firstname: firstName,
        lastname: lastName,
        address: address,
        phone: phone,
        course: course,
        notes: notes,
        imageFile: _selectedImage,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      // --- THIS IS THE FIX ---
      // Always reset loading state. On success, AuthGate will navigate
      // before this flicker is noticeable. On failure, it allows retry.
      _isLoading = false;
      notifyListeners();
    }

    return errorMessage;
  }
}