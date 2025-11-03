import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../modules/controllers/notification/user_notification_controller.dart';

class UserNotification extends StatelessWidget {
  UserNotification({Key? key}) : super(key: key);

  final UserNotificationController controller = Get.put(UserNotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,

        title:  Text("nav_notification".tr),

        actions: [
          IconButton(
            tooltip: 'Clear (for testing empty state)',
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              controller.clearNotifications();
            },
          ),
        ],
      ),

      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _EmptyNotificationState(
            onRefresh: () => controller.fetchDummyData(),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        }
      }),
    );
  }

  /// Ye helper widget ek single notification card banata hai
  Widget _buildNotificationCard(UserNotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySwatch.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Dot (•)
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: BoxDecoration(
              color: controller.getColorForType(notification.type),
              shape: BoxShape.circle,
            ),
          ),

          // 2. Middle Text (Title & Subtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                _buildSubtitle(notification),
              ],
            ),
          ),

          // 3. Timestamp (Right side)
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notification.date,
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                notification.time,
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(UserNotificationModel notification) {
    if (notification.type == UserNotificationType.pendingPayment) {
      return Text(
        notification.subtitle,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      );
    }
    String subtitleText = notification.subtitle.replaceAll(r'\n', '\n');
    return Text(
      subtitleText,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      maxLines: 3,
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyNotificationState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/notification.png'),
              SizedBox(height: 10),
              Text(
                "No notifications yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "When you have notification, you will see them here",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: Text("Refresh")),
            ],
          ),
        ),
      ),
    );
  }
}
