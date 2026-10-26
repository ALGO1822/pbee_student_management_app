import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pbee_collate/main.dart';
import 'package:pbee_collate/models/archived_profile.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = supabase;

  // Sign user in
  Future<AuthResponse?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase error signing in: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error signing in: $e');
      return null;
    }
  }

  // Signs user up
  Future<String?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String address,
    required String phone,
    required String course,
    String? notes,
    File? imageFile,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Sign-up failed. User object is null';
      }

      final String userId = response.user!.id;
      String? avatarUrl;

      if (imageFile != null) {
        try {
          final String path = '$userId/profile.jpg';
          await _supabase.storage
              .from('avatars')
              .upload(
                path,
                imageFile,
                fileOptions: const FileOptions(upsert: true),
              );
          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(path);
        } catch (e) {
          debugPrint('CRITICAL: Image upload failed: $e');
        }
      }

      await _supabase.from('profiles').insert({
        'user_id': userId,
        'first_name': firstname,
        'last_name': lastname,
        'email': email,
        'address': address,
        'phone': phone,
        'course': course,
        'notes': notes ?? '',
        'avatar_url': avatarUrl,
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Stream for the Current User Profile
  Stream<Profile> getCurrentUserProfileStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => Profile.fromMap(data.first));
  }

  // Future for Current User (Backup/Role Check)
  Future<Profile> getCurrentUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw 'No user logged in';
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .single();
    return Profile.fromMap(data);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // --- ADMIN ---

  // Future-based fetch for Admin Search functionality
  // Future-based fetch for Admin Search functionality
  Future<List<Profile>> getAllProfiles({String? query}) async {
    try {
      // 1. Start the base query
      var dbQuery = _supabase.from('profiles').select().neq('role', 'admin');

      // 2. Conditionally add the search filter
      if (query != null && query.isNotEmpty) {
        // Now we can search the new 'full_name' column!
        dbQuery = dbQuery.or(
          'full_name.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%,email.ilike.%$query%',
        );
      }

      // 3. Apply ordering LAST
      final data = await dbQuery.order('created_at', ascending: false);

      return (data as List).map((e) => Profile.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load profiles: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  // Stream-based fetch for Admin real-time list (if needed later)
  Stream<List<Profile>> getAllProfilesStream() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Profile.fromMap(e)).toList());
  }

  // Permanently delete user account
  Future<void> deleteUserProfile(String targetUserId) async {
    try {
      await _supabase.rpc(
        'delete_user_account',
        params: {'target_user_id': targetUserId},
      );
    } on PostgrestException catch (e) {
      throw 'Failed to delete user. ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> adminUpdatePayment(String targetUserId, double newAmount) async {
    try {
      await _supabase.rpc(
        'admin_update_payment',
        params: {'target_user_id': targetUserId, 'new_amount': newAmount},
      );
    } on PostgrestException catch (e) {
      debugPrint('Error updating payment: $e');
      throw 'Failed to update payment: ${e.message}';
    } catch (e) {
      debugPrint('Unexpected error updating payment: $e');
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> archiveUserProfile(String targetUserId) async {
    try {
      await _supabase.rpc(
        'archive_user_account',
        params: {'target_user_id': targetUserId},
      );
    } on PostgrestException catch (e) {
      throw 'Failed to archive user. ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<List<ArchivedProfile>> getArchivedUsers() async {
    try {
      final data = await _supabase
          .from('archived_users')
          .select()
          .order('archived_at', ascending: false);

      debugPrint('DEBUG: getArchivedUsers raw data: $data');
      return (data as List).map((e) => ArchivedProfile.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw 'Failed to load archives: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }
}
