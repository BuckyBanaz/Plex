import 'package:get/get_rx/src/rx_types/rx_types.dart';

enum OrderStatus {
  Pending,
  Accepted,
  Declined,
}


class OrderModel {
  final String id;
  final String customerName;
  final String orderNumber;
  final double amount;
  final bool isPaid;
  final String pickupAddressLine1;
  final String pickupAddressLine2;
  final String deliveryAddressLine1;
  final String deliveryAddressLine2;
  Rx<OrderStatus> status;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.orderNumber,
    required this.amount,
    required this.isPaid,
    required this.pickupAddressLine1,
    required this.pickupAddressLine2,
    required this.deliveryAddressLine1,
    required this.deliveryAddressLine2,
    required OrderStatus status,
  }) : status = status.obs;
}
