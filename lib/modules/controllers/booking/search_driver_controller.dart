// search_driver_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



// driver_model.dart
class DriverModel {
  final String id;
  final String name;
  double lat;
  double lng;
  final String vehicle;
  final String avatarUrl;

  DriverModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.vehicle,
    this.avatarUrl = '',
  });
}



class SearchDriverController extends GetxController {
  var isSearching = true.obs;
  var found = false.obs;
  Rxn<DriverModel> foundDriver = Rxn<DriverModel>();
  var etaSeconds = 120.obs;

  Timer? _etaTimer;
  Timer? _simulateFoundTimer;

  @override
  void onInit() {
    super.onInit();
    startSearchSimulation();
  }

  void startSearchSimulation() {
    isSearching.value = true;
    found.value = false;
    // set ETA initial
    etaSeconds.value = 90;

    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(Duration(seconds: 1), (t) {
      if (etaSeconds.value > 0) etaSeconds.value--;
      else t.cancel();
    });

    // Simulate driver found after short delay.
    _simulateFoundTimer?.cancel();
    _simulateFoundTimer = Timer(Duration(seconds: 3), () {
      // <-- START POSITION: Hansi (approx)
      final driver = DriverModel(
        id: 'driver_1',
        name: 'Allan Smith',
        // Start from Hansi (user wanted driver ~8-10 km away)
        lat: 29.097262,
        lng: 75.963816,
        vehicle: 'Swift Dzire - KA01AB1234',
        avatarUrl: '',
      );
      foundDriver.value = driver;
      found.value = true;
      isSearching.value = false;
    });
  }

  void cancelSearch() {
    _etaTimer?.cancel();
    _simulateFoundTimer?.cancel();
    isSearching.value = false;
    found.value = false;
    foundDriver.value = null;
  }

  @override
  void onClose() {
    _etaTimer?.cancel();
    _simulateFoundTimer?.cancel();
    super.onClose();
  }
}
