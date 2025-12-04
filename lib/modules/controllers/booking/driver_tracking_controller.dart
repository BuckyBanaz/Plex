// driver_tracking_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:plex_user/modules/controllers/booking/search_driver_controller.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverTrackingController extends GetxController {
  Rxn<DriverModel> driver = Rxn<DriverModel>();
  var distanceMeters = 0.0.obs;
  var etaMinutes = 0.obs;
  Timer? _moveTimer;

  // control tick duration (2 seconds)
  final int tickSeconds = 1;

  // set driver model & start simulation toward userLocation
  void startTracking(DriverModel d, LatLng userLocation) {
    driver.value = d;
    _startMovingTowardsUser(userLocation);
  }

  void _startMovingTowardsUser(LatLng user) {
    _moveTimer?.cancel();

    // move every tickSeconds seconds
    _moveTimer = Timer.periodic(Duration(microseconds: tickSeconds), (t) {
      final d = driver.value;
      if (d == null) {
        t.cancel();
        return;
      }

      final lat1 = d.lat;
      final lng1 = d.lng;
      final lat2 = user.latitude;
      final lng2 = user.longitude;

      final dist = _haversineMeters(lat1, lng1, lat2, lng2);
      distanceMeters.value = dist;

      // assume avg speed variable — we can randomize a bit to seem realistic
      // avg 30 km/h => 8.33 m/s, but we multiply by tickSeconds
      final avgSpeedMs =
          8.5 + (Random().nextDouble() * 3 - 1.0); // 7.5 - 11.5 m/s random
      final secondsRemaining = (dist / avgSpeedMs).round();
      etaMinutes.value = (secondsRemaining / 60).ceil();

      if (dist < 10) {
        // reached
        t.cancel();
        distanceMeters.value = 0;
        etaMinutes.value = 0;
        return;
      }

      // step distance per tick: avgSpeedMs * tickSeconds
      final step = avgSpeedMs * tickSeconds;

      // but cap step so it doesn't jump too much
      final moveMeters = min(step, dist);

      final heading = _bearing(lat1, lng1, lat2, lng2);
      final newPos = _moveLatLng(lat1, lng1, moveMeters, heading);

      // driver.update((val) {
      //   if (val != null) {
      //     val.lat = newPos.latitude;
      //     val.lng = newPos.longitude;
      //   }
      // });
    });
  }

  void stopTracking() {
    _moveTimer?.cancel();
  }

  // Haversine formula
  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // metres
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dphi = (lat2 - lat1) * pi / 180;
    final dlambda = (lon2 - lon1) * pi / 180;
    final a =
        sin(dphi / 2) * sin(dphi / 2) +
        cos(phi1) * cos(phi2) * sin(dlambda / 2) * sin(dlambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Bearing in degrees
  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final lambda1 = lon1 * pi / 180;
    final lambda2 = lon2 * pi / 180;
    final y = sin(lambda2 - lambda1) * cos(phi2);
    final x =
        cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(lambda2 - lambda1);
    final brng = atan2(y, x) * 180 / pi;
    return (brng + 360) % 360;
  }

  // Move lat/lng by distance (meters) along bearing
  LatLng _moveLatLng(
    double lat,
    double lon,
    double meters,
    double bearingDegrees,
  ) {
    final R = 6371000.0;
    final bearing = bearingDegrees * pi / 180;
    final latRad = lat * pi / 180;
    final lonRad = lon * pi / 180;

    final newLat = asin(
      sin(latRad) * cos(meters / R) +
          cos(latRad) * sin(meters / R) * cos(bearing),
    );
    final newLon =
        lonRad +
        atan2(
          sin(bearing) * sin(meters / R) * cos(latRad),
          cos(meters / R) - sin(latRad) * sin(newLat),
        );

    return LatLng(newLat * 180 / pi, newLon * 180 / pi);
  }

  @override
  void onClose() {
    _moveTimer?.cancel();
    super.onClose();
  }
}
