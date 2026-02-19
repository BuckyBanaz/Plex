part of 'package:plex_user/services/domain/service/api/api_import.dart';

class NotificationApi {
  final Dio dio;
  NotificationApi(this.dio);

  final basePath = '';

  /// GET /notifications - Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await dio.get(
      '$basePath${ApiEndpoint.notifications}',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  /// GET /notifications/unread-count - Get unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await dio.get(
      '$basePath${ApiEndpoint.notificationUnreadCount}',
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  /// PUT /notifications/:id/read - Mark as read
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    final response = await dio.put(
      '$basePath${ApiEndpoint.notifications}/$notificationId/read',
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  /// PUT /notifications/mark-all-read - Mark all as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await dio.put(
      '$basePath${ApiEndpoint.notificationMarkAllRead}',
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  /// DELETE /notifications/:id - Delete notification
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    final response = await dio.delete(
      '$basePath${ApiEndpoint.notifications}/$notificationId',
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  /// DELETE /notifications/clear-all - Clear all notifications
  Future<Map<String, dynamic>> clearAllNotifications() async {
    final response = await dio.delete(
      '$basePath${ApiEndpoint.notificationClearAll}',
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }
}
