import 'package:flutter/material.dart';
import 'package:pbee_collate/main.dart';
import 'package:pbee_collate/screens/role_director.dart';
import 'package:pbee_collate/screens/user/user_entry.dart';
import 'package:pbee_collate/widget/dashboard_skeleton.dart'; //
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // --- FIX IS HERE: Wrap Skeleton in a Scaffold ---
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              centerTitle: false,
              // We add a dummy empty box so the title aligns perfectly with UserHome
              actions: const [SizedBox(width: 48)],
            ),
            body: const DashboardSkeleton(),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const RoleDirector();
        } else {
          return const UserEntry();
        }
      },
    );
  }
}