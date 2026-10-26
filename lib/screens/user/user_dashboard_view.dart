import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/profile.dart'; //
import 'package:pbee_collate/util/name_formatter.dart'; //
import 'package:pbee_collate/widget/modern_info_tile.dart'; //

class UserDashboardView extends StatelessWidget {
  final Profile profile;
  final String formattedTuition;
  final String formattedPaid;
  final String formattedBalance;
  final bool isCourseValid;

  // REMOVED: onLogout, onNotificationTap, unreadNotifications
  // These belong to the UserHome AppBar now.

  const UserDashboardView({
    super.key,
    required this.profile,
    required this.formattedTuition,
    required this.formattedPaid,
    required this.formattedBalance,
    required this.isCourseValid,
  });

  @override
  Widget build(BuildContext context) {
    // Determine balance colors
    final bool hasBalance =
        formattedBalance.contains(RegExp(r'[1-9]')); // Simple check if not zero

    // CHANGE: No Scaffold, No AppBar. Just the list.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildModernProfileHeader(profile),
        const SizedBox(height: 32),
        _buildSectionLabel('Payment Status'),
        const SizedBox(height: 16),
        ModernInfoTile(
          icon: LucideIcons.banknote,
          title: 'Total Tuition Fee',
          value: formattedTuition,
          iconColor: Colors.grey,
        ),
        const SizedBox(height: 12),
        ModernInfoTile(
          icon: LucideIcons.receipt,
          title: 'Amount Paid',
          value: formattedPaid,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
        ModernInfoTile(
          icon: LucideIcons.alertCircle,
          title: 'Balance Due',
          value: formattedBalance,
          iconColor: hasBalance ? Colors.redAccent : Colors.green,
          textColor: hasBalance ? Colors.redAccent : Colors.green,
        ),
        const SizedBox(height: 32),
        _buildSectionLabel('Academics'),
        const SizedBox(height: 16),
        ModernInfoTile(
          icon: LucideIcons.graduationCap,
          title: 'Enrolled Course',
          value: isCourseValid ? profile.course : 'Course Unavailable',
          iconColor: isCourseValid ? Colors.blueAccent : Colors.red,
          textColor: isCourseValid ? Colors.black87 : Colors.red,
        ),
        const SizedBox(height: 32),
        _buildSectionLabel('Personal Details'),
        const SizedBox(height: 16),
        ModernInfoTile(
          icon: LucideIcons.mail,
          title: 'Email Address',
          value: profile.email,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        ModernInfoTile(
          icon: LucideIcons.phone,
          title: 'Phone Number',
          value: profile.phone.isNotEmpty ? profile.phone : 'N/A',
          iconColor: Colors.teal,
        ),
        const SizedBox(height: 12),
        ModernInfoTile(
          icon: LucideIcons.mapPin,
          title: 'Home Address',
          value: profile.address.isNotEmpty ? profile.address : 'N/A',
          iconColor: Colors.redAccent,
        ),
        if (profile.notes.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSectionLabel('Additional Notes'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              profile.notes,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildModernProfileHeader(Profile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.purple.shade50,
              backgroundImage:
                  (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
              child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                  ? Text(
                      '${profile.firstName[0]}${profile.lastName[0]}'
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NameFormatter.formatFullName(
                      profile.firstName, profile.lastName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}