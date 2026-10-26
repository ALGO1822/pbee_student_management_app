import 'package:flutter/material.dart';
import 'package:pbee_collate/models/profile.dart'; //
import 'package:pbee_collate/screens/admin/admin_dashboard.dart';
import 'package:pbee_collate/screens/user/user_home.dart';
import 'package:pbee_collate/service/auth_service.dart';
import 'package:pbee_collate/widget/dashboard_skeleton.dart'; //

class RoleDirector extends StatefulWidget {
  const RoleDirector({super.key});

  @override
  State<RoleDirector> createState() => _RoleDirectorState();
}

class _RoleDirectorState extends State<RoleDirector> {
  bool? isUser; 

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkRoleAndRedirect();
  }

  Future<Profile> _fetchProfileWithRetry() async {
    int attempts = 0;
    while (attempts < 10) {
      try {
        final profile = await _authService.getCurrentUserProfile();
        return profile;
      } catch (e) {
        attempts++;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    throw 'Failed to fetch profile after multiple attempts.';
  }

  Future<void> _checkRoleAndRedirect() async {
    try {
      final Profile profile = await _fetchProfileWithRetry();
      if (!mounted) return;

      if (profile.role == 'admin') {
        setState(() {
          isUser = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        setState(() {
          isUser = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHome(initialProfile: profile),
          ),
        );
      }
    } catch (e) {
      debugPrint('RoleDirector Error: $e');
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isUser == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // --- FIX IS HERE: Wrap Skeleton in a Scaffold ---
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: isUser == true
            ? Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              )
            : null,
        centerTitle: false,
        actions: const [SizedBox(width: 48)],
      ),
      body: isUser == true ? const DashboardSkeleton() : const SizedBox.shrink(),
    );
  }
}
