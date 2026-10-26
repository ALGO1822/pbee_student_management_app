import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/profile.dart';
import 'package:pbee_collate/providers/course_provider.dart';
import 'package:pbee_collate/providers/user_management_provider.dart';
import 'package:pbee_collate/util/name_formatter.dart';
import 'package:pbee_collate/widget/custom_button.dart';
import 'package:pbee_collate/widget/custom_input.dart';
import 'package:pbee_collate/widget/modern_info_tile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatelessWidget {
  final Profile profile;

  const UserDetailsScreen({super.key, required this.profile});

  // --- Dialog to update payment ---
  void _showPaymentDialog(
    BuildContext context,
    UserManagementProvider provider,
  ) {
    // Find the most current profile data from the provider's list
    final liveProfile = provider.users.firstWhere(
      (u) => u.userId == profile.userId,
      orElse: () => profile, // Fallback to the initial profile data
    );

    final priceController = TextEditingController(
      text: liveProfile.amountPaid.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Use Consumer so only the button rebuilds with loading state
        return Consumer<UserManagementProvider>(
          builder: (context, paymentProvider, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Payment for ${profile.firstName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomInput(
                    controller: priceController,
                    hintText: 'Amount Paid',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(LucideIcons.badgeDollarSign),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Save Payment',
                      isLoading: paymentProvider.isUpdatingPayment,
                      onPressed: () async {
                        final double? amount = double.tryParse(
                          priceController.text.trim(),
                        );
                        if (amount == null) return;

                        final success = await paymentProvider.updatePayment(
                          profile.userId,
                          amount,
                        );
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx); // Close bottom sheet
                        }
                      },
                      backgroundColor: Colors.purple,
                      icon: LucideIcons.check,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Ban user functionality ---
  Future<void> _handleDeleteUser(BuildContext context) async {
    final provider = Provider.of<UserManagementProvider>(
      context,
      listen: false,
    );

    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ban'),
        content: Text('Are you sure you want to Ban ${profile.firstName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ban',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await provider.deleteUser(profile.userId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to delete user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleArchiveUser(BuildContext context) async {
    final provider = Provider.of<UserManagementProvider>(
      context,
      listen: false,
    );

    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Archive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to Archive ${profile.firstName}?'),
            const SizedBox(height: 8),
            const Text(
              '• The user will NO LONGER be able to login.\n'
              '• Their data will be moved to the "Archived Users" databank.\n'
              '• They will be removed from the active users list.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Archive',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await provider.archiveUser(profile.userId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User archived successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context); // Go back to the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to archive user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both providers
    final userProvider = Provider.of<UserManagementProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    // Find the most up-to-date profile from the list
    final liveProfile = userProvider.users.firstWhere(
      (u) => u.userId == profile.userId,
      orElse: () => profile, // Fallback to initial data if not in list yet
    );

    // Get tuition fee
    final double tuitionFee = courseProvider.getPriceForTitle(
      liveProfile.course,
    );
    final String formattedTuition = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 2,
    ).format(tuitionFee);

    // Get amount paid
    final double amountPaid = liveProfile.amountPaid;
    final String formattedPaid = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 2,
    ).format(amountPaid);

    // Calculate balance
    final double balanceDue = tuitionFee - amountPaid;
    final String formattedBalance = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 2,
    ).format(balanceDue);

    final formattedDate = DateFormat(
      'MMM d, yyyy h:mm a',
    ).format(liveProfile.createdAt.toLocal());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildProfileHeader(liveProfile),
                const SizedBox(height: 32),
                _buildSectionLabel('Payment Status'),
                const SizedBox(height: 16),
                ModernInfoTile(
                  icon: LucideIcons.banknote,
                  title: 'Total Tuition Fee',
                  value: (tuitionFee > 0) ? formattedTuition : 'N/A',
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
                  value: (tuitionFee > 0) ? formattedBalance : 'N/A',
                  iconColor: balanceDue > 0 ? Colors.redAccent : Colors.green,
                  textColor: balanceDue > 0 ? Colors.redAccent : Colors.green,
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('Account Info'),
                const SizedBox(height: 16),
                ModernInfoTile(
                  icon: LucideIcons.calendar,
                  title: 'Joined On',
                  value: formattedDate,
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 12),
                ModernInfoTile(
                  icon: LucideIcons.shield,
                  title: 'Role',
                  value: liveProfile.role.toUpperCase(),
                  iconColor: Colors.grey,
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('Academics'),
                const SizedBox(height: 16),
                ModernInfoTile(
                  icon: LucideIcons.graduationCap,
                  title: 'Enrolled Course',
                  value: liveProfile.course.isNotEmpty
                      ? liveProfile.course
                      : 'Not Enrolled',
                  iconColor: Colors.blueAccent,
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('Contact Details'),
                const SizedBox(height: 16),
                ModernInfoTile(
                  icon: LucideIcons.mail,
                  title: 'Email',
                  value: liveProfile.email,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 12),
                ModernInfoTile(
                  icon: LucideIcons.phone,
                  title: 'Phone',
                  value: liveProfile.phone.isNotEmpty
                      ? liveProfile.phone
                      : 'N/A',
                  iconColor: Colors.teal,
                ),
                const SizedBox(height: 12),
                ModernInfoTile(
                  icon: LucideIcons.mapPin,
                  title: 'Address',
                  value: liveProfile.address.isNotEmpty
                      ? liveProfile.address
                      : 'N/A',
                  iconColor: Colors.redAccent,
                ),
                if (liveProfile.notes.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionLabel('Notes'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      liveProfile.notes,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Update Payment',
                    icon: LucideIcons.edit,
                    backgroundColor: Colors.purple.shade50,
                    textColor: Colors.purple,
                    borderColor: Colors.purple.shade100,
                    isLoading: userProvider.isUpdatingPayment,
                    onPressed: () => _showPaymentDialog(context, userProvider),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Ban User',
                        icon: LucideIcons.trash2,
                        backgroundColor: Colors.red.shade50,
                        textColor: Colors.red,
                        borderColor: Colors.red.shade100,
                        isLoading: userProvider.isDeleting,
                        onPressed: () => _handleDeleteUser(context),
                      ),
                    ),
                    SizedBox(width: 12), // spacing between the buttons
                    Expanded(
                      child: CustomButton(
                        text: 'Archive User',
                        icon: LucideIcons.lock,
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.black,
                        borderColor: Colors.black12,
                        isLoading: userProvider.isDeleting,
                        onPressed: () => _handleArchiveUser(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 50,
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
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          NameFormatter.formatFullName(profile.firstName, profile.lastName),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
