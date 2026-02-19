/// Notification type enum
enum NotificationType {
  orderCreated,
  driverAssigned,
  pickupOtp,
  pickedUp,
  inTransit,
  dropoffOtp,
  delivered,
  cancelled,
  paymentPending,
  paymentSuccess,
  general,
}

/// Notification model for API response
class NotificationModel {
  final int id;
  final int userId;
  final int? shipmentId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.shipmentId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      shipmentId: json['shipmentId'],
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shipmentId': shipmentId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get notification type enum from string
  NotificationType get notificationType {
    switch (type) {
      case 'order_created':
        return NotificationType.orderCreated;
      case 'driver_assigned':
        return NotificationType.driverAssigned;
      case 'pickup_otp':
        return NotificationType.pickupOtp;
      case 'picked_up':
        return NotificationType.pickedUp;
      case 'in_transit':
        return NotificationType.inTransit;
      case 'dropoff_otp':
        return NotificationType.dropoffOtp;
      case 'delivered':
        return NotificationType.delivered;
      case 'cancelled':
        return NotificationType.cancelled;
      case 'payment_pending':
        return NotificationType.paymentPending;
      case 'payment_success':
        return NotificationType.paymentSuccess;
      default:
        return NotificationType.general;
    }
  }

  /// Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Format time for display
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
