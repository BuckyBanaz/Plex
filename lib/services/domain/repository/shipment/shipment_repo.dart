part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class ShipmentRepository {
  final ShipmentApi shipmentApi = Get.find<ShipmentApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();

  Future<Map<String, dynamic>> estimateShipment({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
  }) async {
    try {
      // Fetch userId and token from database service
      final userId = databaseService.user!.id.toString();

      final result = await shipmentApi.estimateShipment(
        userId: userId,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        weight: weight,
      );

      debugPrint("Shipment estimation get successfully: $result");
      return result;
    } catch (e) {
      debugPrint("Error in repository while estimation of shipment: $e");
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createShipment({
    required String vehicleType,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
    required String weightUnit,
    required String notes,
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    // required String paymentMethod,
    required String collectType, // "immediate" or "scheduled"
    DateTime? scheduledAt, // optional
    List<String>? imageUrls, // optional
  }) async {
    try {
      // Fetch userId from database (local storage or firebase)
      final userId = databaseService.user!.id.toString();

      final result = await shipmentApi.createShipment(
        userId: userId,
        vehicleType: vehicleType,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        weight: weight,
        weightUnit: weightUnit,
        notes: notes,
        pickup: pickup,
        dropoff: dropoff,
        paymentMethod: "stripe",
        collectType: collectType,
        scheduledAt: scheduledAt,
        imageUrls: imageUrls,
      );

      debugPrint("✅ Shipment created successfully: $result");
      return result;
    } catch (e) {
      debugPrint("❌ Error in repository while creating shipment: $e");
      return {'error': e.toString()};
    }
  }

}
