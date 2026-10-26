import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbee_collate/main.dart';
import 'package:pbee_collate/models/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient _supabase = supabase;
  List<NotificationItem> _notifications = [];
  // Blacklist for locally deleted IDs
  final Set<String> _deletedIds = {};
  StreamSubscription<List<NotificationItem>>? _subscription;

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void init() {
    if (_subscription != null) return;
    _startListening();
  }

  void _startListening() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _subscription = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => NotificationItem.fromMap(e)).toList())
        .listen((items) {
          // Filter incoming items against our local blacklist
          _notifications = items.where((item) => !_deletedIds.contains(item.id)).toList();
          notifyListeners();
        }, onError: (error) {
          debugPrint("Error listening to notifications: $error");
        });
  }

  Future<void> markAsRead(String notificationId) async {
     await _supabase
      .from('notifications')
      .update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> deleteNotification(String notificationId) async {
     _deletedIds.add(notificationId);
     _notifications.removeWhere((n) => n.id == notificationId);
     notifyListeners();

     try {
       await _supabase.from('notifications').delete().eq('id', notificationId);
     } catch (e) {
       debugPrint("Error deleting notification: $e");
     }
  }

  // --- FIX IS HERE ---
  Future<void> clearAll() async {
     final userId = _supabase.auth.currentUser?.id;
     if (userId == null) return;

     // 1. Add ALL current IDs to blacklist immediately
     // This prevents them from ever reappearing in this session
     for (var n in _notifications) {
       _deletedIds.add(n.id);
     }
     
     // 2. Clear local list
     _notifications.clear();
     notifyListeners();
     
     // 3. Perform actual DB delete
     try {
       await _supabase.from('notifications').delete().eq('user_id', userId);
     } catch (e) {
       debugPrint("Error clearing notifications: $e");
       // Optional: if delete fails, you might want to clear _deletedIds 
       // so the user sees them again and can retry, but for now let's keep them hidden.
     }
  }
  // -------------------

  Future<bool> sendBroadcast({required String title, required String message}) async {
    try {
      await _supabase.rpc('broadcast_notification', params: {
        'title': title,
        'message': message,
      });
      return true;
    } catch (e) {
      debugPrint('Error sending broadcast: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}