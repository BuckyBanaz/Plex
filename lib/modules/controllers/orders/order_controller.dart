
import 'package:get/get.dart';

import '../../../screens/individual/order/order_details_screen.dart';

enum OrderStatus { Complete, Pending, Cancelled }

class OrderModel {
  final String orderId;
  final String date;
  final String time;
  final String vehicleType;
  final OrderStatus status;
  final String pickupName;
  final String pickupPhone;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffPhone;
  final String dropoffAddress;

  final String deliverPartnerName;
  final String deliverPartnerRating;
  final String collectTime;
  final String weight;
  final String paymentMethod;
  final String fee;
  final List<String> pickupImageUrls;
  final List<String> deliveryImageUrls;
  final String deliverPartnerProfilePic;


  OrderModel({
    required this.orderId,
    required this.date,
    required this.time,
    required this.vehicleType,
    required this.status,
    required this.pickupName,
    required this.pickupPhone,
    required this.pickupAddress,
    required this.dropoffName,
    required this.dropoffPhone,
    required this.dropoffAddress,
    required this.deliverPartnerName,
    required this.deliverPartnerRating,
    required this.collectTime,
    required this.weight,
    required this.paymentMethod,
    required this.fee,
    required this.pickupImageUrls,
    required this.deliveryImageUrls,
    required this.deliverPartnerProfilePic,
  });
}

class UserOrderController extends GetxController {
  var groupedOrders = <String, List<OrderModel>>{}.obs;
  var selectedOrder = Rx<OrderModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  var selectedVehicleIndex = "Bike".obs;

  void loadDummyData() {
    // Dummy data list
    final List<OrderModel> todayOrders = [
      OrderModel(
        orderId: "PLEX 1240",
        date: "3-11-2025",
        time: "10:10 AM",
        vehicleType: 'Bike',
        status: OrderStatus.Complete,
        pickupName: "Vipin Jain",
        pickupPhone: "-7878907398",
        pickupAddress: "21b, Karimu Kotun Street, Lal Khoti, Jaipur...",
        dropoffName: "Vipin Jain",
        dropoffPhone: "-7878907398",
        dropoffAddress: "21b, Karimu Kotun Street, Lal Khoti, Jaipur...",
        // === NAYE DUMMY DATA ===
        deliverPartnerName: "Vipin Jain",
        deliverPartnerRating: "4.1",
        deliverPartnerProfilePic: "https://via.placeholder.com/150/FF8C00/FFFFFF?text=VJ", // Dummy image URL
        collectTime: "Immediate",
        weight: "20KG",
        paymentMethod: "Card",
        fee: "\$150",
        pickupImageUrls: [
          "https://via.placeholder.com/100/CCCCCC/FFFFFF?text=Pickup1",
          "https://via.placeholder.com/100/CCCCCC/FFFFFF?text=Pickup2"
        ],
        deliveryImageUrls: [
          "https://via.placeholder.com/100/CCCCCC/FFFFFF?text=Delivery1",
          "https://via.placeholder.com/100/CCCCCC/FFFFFF?text=Delivery2"
        ],
        // =======================
      ),
      OrderModel(
        orderId: "PLEX 1241",
        date: "3-11-2025",
        time: "09:30 AM",
        vehicleType: "Van",
        status: OrderStatus.Pending,
        pickupName: "Rohan Sharma",
        pickupPhone: "-9876543210",
        pickupAddress: "C-Scheme, Ashok Nagar, Jaipur...",
        dropoffName: "Amit Singh",
        dropoffPhone: "-1234567890",
        dropoffAddress: "Malviya Nagar, Jaipur...",
        // === NAYE DUMMY DATA ===
        deliverPartnerName: "Rohan Sharma",
        deliverPartnerRating: "3.8",
        deliverPartnerProfilePic: "https://via.placeholder.com/150/6A5ACD/FFFFFF?text=RS",
        collectTime: "30 Mins",
        weight: "50KG",
        paymentMethod: "Cash",
        fee: "\$200",
        pickupImageUrls: [],
        deliveryImageUrls: [],
        // =======================
      ),
      OrderModel(
        orderId: "PLEX 1242",
        date: "3-11-2025",
        time: "08:15 AM",
        vehicleType: "Car",
        status: OrderStatus.Cancelled,
        pickupName: "Priya Gupta",
        pickupPhone: "-1112223334",
        pickupAddress: "Vaishali Nagar, Jaipur...",
        dropoffName: "Sumit Kumar",
        dropoffPhone: "-5556667778",
        dropoffAddress: "Raja Park, Jaipur...",
        // === NAYE DUMMY DATA ===
        deliverPartnerName: "Priya Gupta",
        deliverPartnerRating: "4.5",
        deliverPartnerProfilePic: "https://via.placeholder.com/150/008080/FFFFFF?text=PG",
        collectTime: "1 Hour",
        weight: "15KG",
        paymentMethod: "Card",
        fee: "\$120",
        pickupImageUrls: [],
        deliveryImageUrls: [],
        // =======================
      ),
    ];

    final List<OrderModel> yesterdayOrders = [
      OrderModel(
        orderId: "PLEX 1239",
        date: "2-11-2025",
        time: "04:45 PM",
        vehicleType: "Bike",
        status: OrderStatus.Complete,
        pickupName: "Karan Verma",
        pickupPhone: "-7778889990",
        pickupAddress: "Jhotwara, Jaipur...",
        dropoffName: "Anjali Mehta",
        dropoffPhone: "-4445556667",
        dropoffAddress: "Bani Park, Jaipur...",
        // === NAYE DUMMY DATA ===
        deliverPartnerName: "Karan Verma",
        deliverPartnerRating: "4.0",
        deliverPartnerProfilePic: "https://via.placeholder.com/150/CD5C5C/FFFFFF?text=KV",
        collectTime: "Immediate",
        weight: "10KG",
        paymentMethod: "Cash",
        fee: "\$90",
        pickupImageUrls: [],
        deliveryImageUrls: [],
        // =======================
      ),
    ];


    groupedOrders.value = {
      "Today": todayOrders,
      "Yesterday": yesterdayOrders,
    };
  }

  void goToOrderDetails(OrderModel order) {
    selectedOrder.value = order;
    Get.to(() => const OrderDetailsScreen());
  }
}