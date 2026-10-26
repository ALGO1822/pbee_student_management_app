import 'package:flutter/material.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/screens/user/user_dashboard_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Create dummy data
    final dummyProfile = Profile(
      id: '0',
      userId: '0',
      firstName: 'Jonathan',
      lastName: 'Doe-Smith',
      email: 'jonathan.doe.smith@example.com',
      address: '1234 Main Street, Apt 101, Springfield, IL 62704',
      phone: '+234 800 000 0000',
      course: 'Bachelor of Science in Computer Science',
      notes:
          'These are some sample notes to show the skeleton loading state for the notes section.',
      role: 'user',
      amountPaid: 0,
      createdAt: DateTime.now(),
    );

    // 2. Return Skeletonizer wrapping the view directly
    return Skeletonizer(
      enabled: true,
      child: UserDashboardView(
        profile: dummyProfile,
        formattedTuition: '₦000,000.00',
        formattedPaid: '₦000,000.00',
        formattedBalance: '₦000,000.00',
        isCourseValid: true,
      ),
    );
  }
}
