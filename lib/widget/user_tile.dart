import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/screens/admin/specific_user_details.dart';
import 'package:pbee_collate/util/name_formatter.dart';

class UserTile extends StatelessWidget {
  final Profile user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade50,
          backgroundImage:
              (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? Text(
                  '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade300,
                  ),
                )
              : null,
        ),
        title: Text(
          NameFormatter.formatFullName(user.firstName, user.lastName),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Icon(
          LucideIcons.chevronRight,
          size: 20,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(profile: user),
            ),
          );
        },
      ),
    );
  }
}
