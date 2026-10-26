import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/providers/user_management_provider.dart';
import 'package:pbee_collate/screens/admin/archived_users_screen.dart';
import 'package:pbee_collate/widget/custom_input.dart';
import 'package:pbee_collate/widget/user_list_skeleton.dart';
import 'package:pbee_collate/widget/user_tile.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger initial fetch when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).init();
      Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes
    final userProvider = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchivedUsersScreen()));
          }, icon: const Icon(LucideIcons.archive)),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: CustomInput(
                controller: _searchController,
                hintText: 'Search by name or email...',
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                onChanged: (value) {
                  // Pass text changes to provider to trigger debounced search
                  userProvider.onSearchChanged(value);
                },
              ),
            ),

            // --- USER LIST ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: userProvider.fetchUsers,
                color: Colors.purple,
                child: Builder(
                  builder: (context) {
                    if (userProvider.isLoading) {
                      return const UserListSkeleton();
                    }

                    if (userProvider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              size: 48,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading users\n${userProvider.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: userProvider.fetchUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (userProvider.users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      itemCount: userProvider.users.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = userProvider.users[index];
                        return UserTile(user: user);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
