import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Enum taaki hum notification type ko aasani se pehchaan sakein
enum UserNotificationType {
  delivered,
  pendingPayment,
  readyForPickup,
  readyToDeliver,
  scheduled
}

/// Notification data ke liye ek model class
class UserNotificationModel {
  final String id;
  final UserNotificationType type;
  final String title;
  final String subtitle;
  final String date;
  final String time;

  UserNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
  });
}

/// Humara GetX Controller
class UserNotificationController extends GetxController {


  final RxList<UserNotificationModel> notifications = <UserNotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDummyData(); // Controller start hote hi data load karega
  }

  // Dummy data jo aapne pucha tha (exact image ke hisaab se)
  void fetchDummyData() {
    var dummyList = [
      UserNotificationModel(
        id: '1',
        type: UserNotificationType.delivered,
        title: 'PLEX#: 004-12092283 Delivered',
        subtitle: 'Thank you for your order',
        date: 'Today',
        time: '6:30 PM',
      ),
      UserNotificationModel(
        id: '2',
        type: UserNotificationType.pendingPayment,
        title: 'Pending payment',
        subtitle: 'Pay \$20 here', // '$' sign ke liye '\' use kiya hai
        date: 'Today',
        time: '6:30 PM',
      ),
      UserNotificationModel(
        id: '3',
        type: UserNotificationType.readyForPickup,
        title: 'Order ready to pickup',
        subtitle: 'Arrives between in 5:50 PM - 6:10 AM',
        date: 'Today',
        time: '6:30 PM',
      ),
      UserNotificationModel(
        id: '4',
        type: UserNotificationType.readyToDeliver,
        title: 'Order ready to Delivered',
        subtitle: 'Will be delivered in 20 min',
        date: 'Today',
        time: '6:30 PM',
      ),
      UserNotificationModel(
        id: '5',
        type: UserNotificationType.scheduled,
        title: 'Order Scheduled',
        // Newline ke liye '\n' use kiya hai
        subtitle: 'For Mon 1, Nov Arriving at\n11:51 PM - 12:30 AM',
        date: 'Today',
        time: '6:30 PM',
      ),
    ];

    // List ko update kar rahe hain
    notifications.assignAll(dummyList);
  }
  /// Testing ke liye notifications clear karne ka function
  void clearNotifications() {
    notifications.clear();
  }
  /// Helper function jo type ke hisaab se dot (•) ka color return karega
  Color getColorForType(UserNotificationType type) {
    switch (type) {
      case UserNotificationType.delivered:
        return Colors.green; // Color(0xFF34C759)
      case UserNotificationType.pendingPayment:
        return Colors.red; // Color(0xFFFF3B30)
      case UserNotificationType.readyForPickup:
        return Colors.blue; // Color(0xFF007AFF)
      case UserNotificationType.readyToDeliver:
        return Colors.orange; // Color(0xFFFF9500)
      case UserNotificationType.scheduled:
        return Colors.purple; // Color(0xFFAF52DE)
    }
  }
}