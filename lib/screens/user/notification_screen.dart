import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pbee_collate/models/notification.dart';
import 'package:pbee_collate/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for changes
    final notifyProvider = Provider.of<NotificationProvider>(context);
    final notifications = notifyProvider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.black54),
              tooltip: 'Clear All',
              onPressed: () {
                 showDialog(context: context, builder: (ctx) => AlertDialog(
                   title: const Text('Clear All?'),
                   content: const Text('This will permanently delete all your notifications.'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                     TextButton(
                        onPressed: () {
                           Navigator.pop(ctx);
                           // Call the robust clearAll method
                           notifyProvider.clearAll();
                        }, 
                        child: const Text('Clear', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                     ),
                   ],
                 ));
              },
            ),
           const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationTile(context, item, notifyProvider);
              },
            ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationItem item,
      NotificationProvider provider) {
    return Dismissible(
      // Use ValueKey for better list tracking during deletions
      key: ValueKey(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(LucideIcons.trash2, color: Colors.red.shade700),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
         // Immediately tell provider to remove it.
         // The provider MUST remove it from its list synchronously for this to work without errors.
         provider.deleteNotification(item.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: item.isRead ? Colors.grey.shade200 : Colors.purple.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.isRead
                  ? Colors.grey.shade100
                  : Colors.purple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bell,
              size: 20,
              color: item.isRead ? Colors.grey : Colors.purple,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item.message, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, h:mm a').format(item.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          onTap: () {
            if (!item.isRead) {
              provider.markAsRead(item.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bellOff,
                size: 48, color: Colors.purple.shade200),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll let you know when\nimportant updates arrive.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}