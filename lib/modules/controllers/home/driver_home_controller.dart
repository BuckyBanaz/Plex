import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';

import '../../../models/driver_order_model.dart';
import '../../../screens/driver/home/components/new_order_sheet.dart';

class DriverHomeController extends GetxController {

  final Map<String, dynamic> newOrder = {
    'earnings': '10.00',
    'isPaid': true,
    'pickupAddress': 'No 2, Balonny Close, Allen Avenue',
    'pickupDistance': '0.5 Km',
    'deliveryAddress': '87, South Lester Street, London Close Belgium',
    'deliveryDistance': '3.5 Km',
    'customerName': 'Vipin Jain',
    'customerPhone': '7878907890',
  };

  final RxList<Map<String, String>> recentHistory = <Map<String, String>>[
    {
      'name': 'Akhil Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'A',
    },
    {
      'name': 'Vipin Jain',
      'time': 'Today at 09:30 AM',
      'amount': '200',
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },

  ].obs;
  final RxList<OrderModel> orders = <OrderModel>[
    OrderModel(
      id: '1',
      customerName: 'Vipin Jain',
      orderNumber: '#1250',
      amount: 2300,
      isPaid: true,
      pickupAddressLine1: 'Ananta Stores, 204/C, Apts',
      pickupAddressLine2: 'Andheri East 400069',
      deliveryAddressLine1: '201/D, Ananta Apts, Near',
      deliveryAddressLine2: 'Jal Bhawan, Andheri 400069',
      status: OrderStatus.Pending,
    ),
    OrderModel(
      id: '2',
      customerName: 'Akhil Verma',
      orderNumber: '#1251',
      amount: 1500,
      isPaid: false,
      pickupAddressLine1: 'Reliance Mart, JVLR',
      pickupAddressLine2: 'Powai 400076',
      deliveryAddressLine1: 'Hiranandani Gardens',
      deliveryAddressLine2: 'Powai 400076',
      status: OrderStatus.Pending,
    ),
    OrderModel(
      id: '3',
      customerName: 'Parikshit Verma',
      orderNumber: '#1252',
      amount: 4100,
      isPaid: true,
      pickupAddressLine1: 'DB Mall, Goregaon',
      pickupAddressLine2: 'Goregaon West 400104',
      deliveryAddressLine1: 'Inorbit Mall, Malad',
      deliveryAddressLine2: 'Malad West 400064',
      status: OrderStatus.Accepted,
    ),
    OrderModel(
      id: '4',
      customerName: 'Bucky Banaz',
      orderNumber: '#1253',
      amount: 750,
      isPaid: false,
      pickupAddressLine1: 'CSMT Station',
      pickupAddressLine2: 'Fort 400001',
      deliveryAddressLine1: 'Gateway of India',
      deliveryAddressLine2: 'Colaba 400005',
      status: OrderStatus.Declined,
    ),
  ].obs;


  void acceptDeliveryOrder(String orderId) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status.value = OrderStatus.Accepted;
  }


  void declineDeliveryOOrder(String orderId) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status.value = OrderStatus.Declined;
  }
  @override
  void onInit() {
    super.onInit();


    Future.delayed(const Duration(milliseconds: 100), () {
      showNewOrderSheet();
    });
  }


  void showNewOrderSheet() {
    Get.bottomSheet(
      NewOrderSheet(orderData: newOrder),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }


  void rejectOrder() {
    Get.back();

  }

  void acceptOrder() {
    Get.back();
  }
}