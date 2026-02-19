import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/models/notification_model.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/services/domain/service/socket/user_order_socket.dart';

/// UserNotificationController - Manages notifications from API with real-time updates
class UserNotificationController extends GetxController {
  final NotificationRepository _notificationRepository = Get.find<NotificationRepository>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  
  int _offset = 0;
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _listenToSocketNotifications();
  }

  /// Listen for real-time notifications from socket
  void _listenToSocketNotifications() {
    try {
      // Try to get socket service if available
      if (Get.isRegistered<UserOrderSocket>()) {
        final userOrderSocket = Get.find<UserOrderSocket>();
        
        userOrderSocket.socketService.on('new_notification', (data) {
          debugPrint('📨 New notification received: $data');
          
          if (data != null) {
            final notification = NotificationModel.fromJson(
              Map<String, dynamic>.from(data),
            );
            
            // Add to beginning of list
            notifications.insert(0, notification);
            
            // Update unread count
            if (!notification.isRead) {
              unreadCount.value++;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error setting up notification socket: $e');
    }
  }

  /// Fetch notifications from API
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      hasMore.value = true;
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = true;

    try {
      final result = await _notificationRepository.getNotifications(
        limit: _limit,
        offset: _offset,
      );

      if (refresh) {
        notifications.assignAll(result.notifications);
      } else {
        notifications.addAll(result.notifications);
      }

      unreadCount.value = result.unreadCount;
      
      // Check if there are more notifications
      hasMore.value = result.notifications.length >= _limit;
      _offset += result.notifications.length;

      debugPrint('✅ Fetched ${result.notifications.length} notifications, total: ${notifications.length}');
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) {
      await fetchNotifications();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final success = await _notificationRepository.markAsRead(notificationId);
    
    if (success) {
      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = notifications[index];
        if (!notification.isRead) {
          // Create updated notification with isRead = true
          notifications[index] = NotificationModel(
            id: notification.id,
            userId: notification.userId,
            shipmentId: notification.shipmentId,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
          
          // Decrease unread count
          if (unreadCount.value > 0) {
            unreadCount.value--;
          }
        }
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final success = await _notificationRepository.markAllAsRead();
    
    if (success) {
      // Update all notifications locally
      notifications.value = notifications.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        shipmentId: n.shipmentId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
        updatedAt: DateTime.now(),
      )).toList();
      
      unreadCount.value = 0;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    final success = await _notificationRepository.deleteNotification(notificationId);
    
    if (success) {
      final notification = notifications.firstWhereOrNull((n) => n.id == notificationId);
      if (notification != null && !notification.isRead) {
        unreadCount.value = (unreadCount.value > 0) ? unreadCount.value - 1 : 0;
      }
      notifications.removeWhere((n) => n.id == notificationId);
    }
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    final success = await _notificationRepository.clearAllNotifications();
    
    if (success) {
      notifications.clear();
      unreadCount.value = 0;
    }
  }

  /// Get color for notification type
  Color getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.delivered:
        return Colors.green;
      case NotificationType.paymentPending:
        return Colors.red;
      case NotificationType.pickupOtp:
      case NotificationType.dropoffOtp:
        return Colors.blue;
      case NotificationType.pickedUp:
      case NotificationType.inTransit:
        return Colors.orange;
      case NotificationType.driverAssigned:
        return Colors.purple;
      case NotificationType.orderCreated:
        return Colors.teal;
      case NotificationType.cancelled:
        return Colors.red.shade700;
      case NotificationType.paymentSuccess:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }
}
