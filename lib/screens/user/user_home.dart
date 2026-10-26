import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/providers/course_provider.dart';
import 'package:pbee_collate/providers/notification_provider.dart';
import 'package:pbee_collate/providers/sign_out_provider.dart';
import 'package:pbee_collate/screens/user/notification_screen.dart';
import 'package:pbee_collate/screens/user/user_dashboard_view.dart';
import 'package:pbee_collate/screens/user/user_entry.dart';
import 'package:pbee_collate/service/auth_service.dart';
import 'package:pbee_collate/widget/dashboard_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserHome extends StatefulWidget {
  final Profile? initialProfile;
  const UserHome({super.key, this.initialProfile});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final signOut = Provider.of<SignOutProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    // CHANGE: The Scaffold wraps the StreamBuilder. AppBar is here and constant.
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
        actions: [
          Badge(
            isLabelVisible: notificationProvider.unreadCount > 0,
            label: Text('${notificationProvider.unreadCount}'),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            offset: const Offset(-4, 4),
            child: IconButton(
              icon: const Icon(LucideIcons.bell, color: Colors.black87),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.black87),
            onPressed: () => signOut.handleSignOut(context, const UserEntry()),
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<Profile>(
        initialData: widget.initialProfile,
        stream: _authService.getCurrentUserProfileStream(),
        builder: (context, snapshot) {
          // 1. Show Skeleton Body
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const DashboardSkeleton();
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          final profile = snapshot.data!;

          // 2. Logic
          final bool isCourseValid = courseProvider.isCourseValid(
            profile.course,
          );

          final double tuitionFee = courseProvider.getPriceForTitle(
            profile.course,
          );
          final double amountPaid = profile.amountPaid;
          final double balanceDue = tuitionFee - amountPaid;

          final String formattedTuition = isCourseValid
              ? NumberFormat.currency(
                  symbol: '₦',
                  decimalDigits: 2,
                ).format(tuitionFee)
              : 'N/A';
          final String formattedPaid = NumberFormat.currency(
            symbol: '₦',
            decimalDigits: 2,
          ).format(amountPaid);
          final String formattedBalance = isCourseValid
              ? NumberFormat.currency(
                  symbol: '₦',
                  decimalDigits: 2,
                ).format(balanceDue)
              : 'N/A';

          // 3. Show Real Body
          return Skeletonizer(
            enabled: false,
            child: UserDashboardView(
              profile: profile,
              formattedTuition: formattedTuition,
              formattedPaid: formattedPaid,
              formattedBalance: formattedBalance,
              isCourseValid: isCourseValid,
            ),
          );
        },
      ),
    );
  }
}
