import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/archived_profile.dart';
import 'package:pbee_collate/util/name_formatter.dart';
import 'package:intl/intl.dart';

class ArchivedUserDetailsScreen extends StatelessWidget {
  final ArchivedProfile user;

  const ArchivedUserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // --- ALUMNI THEME CONSTANTS ---
    final kBgColor = const Color(0xFFFAF8F0);
    final kPrimaryColor = const Color(0xFF5D4037);
    final kAccentColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: Text(
          'Permanent Record',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- PROFILE HEADER (Classic Stamp Style) ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: kAccentColor, width: 2), // Double border effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryColor, width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: kPrimaryColor.withOpacity(0.05),
                      backgroundImage: (user.avatarUrl != null) 
                          ? NetworkImage(user.avatarUrl!) 
                          : null,
                      child: (user.avatarUrl == null)
                          ? Icon(LucideIcons.user, size: 40, color: kPrimaryColor)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NameFormatter.formatFullName(user.firstName, user.lastName),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ALUMNI / ARCHIVED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- DETAILS SECTION ---
            _buildLegacyTile(
              label: 'Original Enrollment',
              value: DateFormat('MMMM d, yyyy').format(user.originalCreatedAt),
              icon: LucideIcons.calendar,
              themeColor: kPrimaryColor,
            ),
             _buildLegacyTile(
              label: 'Date Archived',
              value: DateFormat('MMMM d, yyyy').format(user.archivedAt),
              icon: LucideIcons.archive,
              themeColor: kPrimaryColor,
            ),
            const Divider(height: 40, color: Color(0xFFE0D8C0)),
            
            _buildLegacyTile(
              label: 'Course Completed',
              value: user.course,
              icon: LucideIcons.bookOpen,
              themeColor: kPrimaryColor,
            ),
            _buildLegacyTile(
              label: 'Final Payment Record',
              value: NumberFormat.currency(symbol: '₦').format(user.amountPaid),
              icon: LucideIcons.badgeDollarSign,
              themeColor: kPrimaryColor,
            ),
             const Divider(height: 40, color: Color(0xFFE0D8C0)),

             _buildLegacyTile(
              label: 'Contact Email',
              value: user.email,
              icon: LucideIcons.mail,
              themeColor: kPrimaryColor,
            ),
             _buildLegacyTile(
              label: 'Phone Number',
              value: user.phone,
              icon: LucideIcons.phone,
              themeColor: kPrimaryColor,
            ),

            if (user.notes.isNotEmpty) ...[
               const SizedBox(height: 32),
               Align(
                 alignment: Alignment.centerLeft,
                 child: Text(
                   'ACADEMIC NOTES',
                   style: TextStyle(
                     color: kPrimaryColor.withOpacity(0.6),
                     fontSize: 12,
                     fontWeight: FontWeight.bold,
                     letterSpacing: 1.5,
                   ),
                 ),
               ),
               const SizedBox(height: 12),
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: const Color(0xFFFFFDF5),
                   borderRadius: BorderRadius.circular(4),
                   border: Border.all(color: const Color(0xFFE0D8C0)),
                 ),
                 child: Text(
                   user.notes,
                   style: TextStyle(
                     color: kPrimaryColor,
                     fontStyle: FontStyle.italic,
                     height: 1.6,
                     fontFamily: 'serif',
                   ),
                 ),
               ),
            ],
            const SizedBox(height: 40),
            Center(
              child: Icon(LucideIcons.award, color: kAccentColor.withOpacity(0.5), size: 48),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyTile({
    required String label, 
    required String value, 
    required IconData icon,
    required Color themeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD4AF37)), // Gold icons
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: themeColor.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'serif',
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