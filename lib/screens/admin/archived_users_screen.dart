import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/providers/archived_provider.dart';
import 'package:pbee_collate/screens/admin/archived_user_details.dart';
import 'package:pbee_collate/util/name_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ArchivedUsersScreen extends StatefulWidget {
  const ArchivedUsersScreen({super.key});

  @override
  State<ArchivedUsersScreen> createState() => _ArchivedUsersScreenState();
}

class _ArchivedUsersScreenState extends State<ArchivedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArchiveProvider>(context, listen: false).fetchArchives();
    });
  }

  @override
  Widget build(BuildContext context) {
    final archiveProvider = Provider.of<ArchiveProvider>(context);

    // --- ALUMNI THEME CONSTANTS ---
    final kBgColor = const Color(0xFFFAF8F0);
    final kCardColor = const Color(0xFFFFFDF5);
    final kPrimaryColor = const Color(0xFF5D4037);
    final kAccentColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: Text(
          'Archived Records',
          style: TextStyle(
            color: kPrimaryColor, 
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            letterSpacing: 1.0,
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
      body: Builder(
        builder: (context) {
          if (archiveProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: kAccentColor));
          }

          // --- FIX 1: Check for Error and Display It ---
          if (archiveProvider.error != null) {
             return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.alertTriangle, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Records',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      archiveProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kPrimaryColor.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        archiveProvider.fetchArchives();
                      },
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }
          // ---------------------------------------------

          if (archiveProvider.archives.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.archive, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No Archived Records Found',
                    style: TextStyle(
                      color: kPrimaryColor.withOpacity(0.5),
                      fontFamily: 'serif',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: archiveProvider.archives.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final user = archiveProvider.archives[index];
              return Container(
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0D8C0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D4037).withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kAccentColor, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: kAccentColor.withOpacity(0.1),
                      backgroundImage: (user.avatarUrl != null) 
                          ? NetworkImage(user.avatarUrl!) 
                          : null,
                      child: (user.avatarUrl == null)
                          ? Text(
                              user.firstName.isNotEmpty ? user.firstName[0] : '?',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                              ),
                            )
                          : null,
                    ),
                  ),
                  title: Text(
                    NameFormatter.formatFullName(user.firstName, user.lastName),
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'serif',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        user.course,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kPrimaryColor.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.history, size: 12, color: kAccentColor),
                          const SizedBox(width: 4),
                          Text(
                            'Archived: ${DateFormat('MMM d, yyyy').format(user.archivedAt)}',
                            style: TextStyle(
                              color: kPrimaryColor.withOpacity(0.5),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  trailing: Icon(LucideIcons.chevronRight, color: kAccentColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArchivedUserDetailsScreen(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}