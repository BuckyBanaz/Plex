part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class NotificationRepository {
  final NotificationApi notificationApi = Get.find<NotificationApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();

  /// Fetch all notifications for user
  Future<NotificationResult> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await notificationApi.getNotifications(
        limit: limit,
        offset: offset,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final notifications = data
            .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        return NotificationResult(
          notifications: notifications,
          total: response['total'] ?? 0,
          unreadCount: response['unreadCount'] ?? 0,
        );
      }

      return NotificationResult(notifications: [], total: 0, unreadCount: 0);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return NotificationResult(notifications: [], total: 0, unreadCount: 0);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await notificationApi.getUnreadCount();

      if (response['success'] == true) {
        return response['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await notificationApi.markAsRead(notificationId);
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await notificationApi.markAllAsRead();
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await notificationApi.deleteNotification(notificationId);
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final response = await notificationApi.clearAllNotifications();
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      return false;
    }
  }
}

/// Result class for notification fetch
class NotificationResult {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;

  NotificationResult({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });
}
