import 'package:flutter/material.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/widget/user_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserListSkeleton extends StatelessWidget {
  const UserListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a list of dummy profiles for the skeleton
    final dummyProfiles = List.generate(
      8,
      (index) => Profile(
        id: '0',
        userId: '0',
        firstName: 'Jonathan',
        lastName: 'Doe-Smith',
        email: 'jonathan.doe.smith@example.com',
        address: '1234 Main Street, Apt 101, Springfield, IL 62704',
        phone: '+234 800 000 0000',
        course: 'Bachelor of Science in Computer Science',
        notes: 'Loading notes...',
        role: 'user',
        amountPaid: 0,
        createdAt: DateTime.now(),
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        itemCount: dummyProfiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return UserTile(user: dummyProfiles[index]);
        },
      ),
    );
  }
}
