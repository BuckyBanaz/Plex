// file: lib/modules/controllers/booking/shipment_tracking_controller.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:plex_user/services/domain/service/socket/socket_service.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_order_model.dart';
import '../../../services/domain/service/socket/user_order_socket.dart';

class ShipmentTrackingController extends GetxController {
  final UserOrderSocket userOrderSocket = Get.put(UserOrderSocket());
  final Rxn<OrderModel> order = Rxn<OrderModel>();
final SocketService socketService  = Get.find<SocketService>();
final DatabaseService db = Get.find<DatabaseService>();
  final Rxn<LatLng> driverLocation = Rxn<LatLng>();
  final RxDouble driverBearing = 0.0.obs;
  final RxInt etaMinutes = 0.obs;
  final RxDouble distanceMeters = 0.0.obs;

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  StreamSubscription? _liveLocSub;
  StreamSubscription? _activeOrderSub;

  late final PolylinePoints polylinePoints;

  final String googleApiKey = "AIzaSyAoVauo0szWOaKCsNW6lqklZCXmZED-7ZU";

  BitmapDescriptor? driverIcon;
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? dropoffIcon;

  final RxBool iconsReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    polylinePoints = PolylinePoints(apiKey: googleApiKey);
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadMarkerIcons();
    iconsReady.value = true;
    _startLiveLocationListener();
  }
  Future<BitmapDescriptor> _svgToBitmapDescriptor(
      String asset, {
        required int size,
        Color? tintColor,
      }) async {
    try {
      final pictureInfo = await vg.loadPicture(SvgAssetLoader(asset), null);
      final scale = ui.window.devicePixelRatio;
      final width = (size * scale).toInt();
      final height = (size * scale).toInt();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Background (optional)
      canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = Colors.transparent);

      // Tint if needed
      if (tintColor != null) {
        canvas.saveLayer(null, Paint()..colorFilter = ColorFilter.mode(tintColor, BlendMode.srcIn));
      }

      // Scale SVG to fit exactly
      final svgWidth = pictureInfo.size.width;
      final svgHeight = pictureInfo.size.height;
      final scaleX = width / svgWidth;
      final scaleY = height / svgHeight;
      final scaleFactor = math.min(scaleX, scaleY);

      canvas.translate((width - svgWidth * scaleFactor) / 2, (height - svgHeight * scaleFactor) / 2);
      canvas.scale(scaleFactor, scaleFactor);
      canvas.drawPicture(pictureInfo.picture);

      if (tintColor != null) canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      pictureInfo.picture.dispose();
      picture.dispose();

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint("SVG Error: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }
  Future<BitmapDescriptor?> _tryFromAsset(String asset, {int width = 64}) async {
    try {
      final data = await rootBundle.load(asset);
      if (data.lengthInBytes == 0) throw Exception('empty asset: $asset');

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null || pngBytes.lengthInBytes == 0) throw Exception('failed to convert to png: $asset');

      return BitmapDescriptor.fromBytes(pngBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('Marker load failed for $asset: $e');
      return null;
    }
  }

  Future<void> _loadMarkerIcons() async {
    driverIcon = await _svgToBitmapDescriptor('assets/icons/driver.svg', size: 80);
    pickupIcon = await _svgToBitmapDescriptor('assets/icons/pickup_t.svg', size: 60);
    dropoffIcon = await _svgToBitmapDescriptor('assets/icons/dropoff.svg', size: 60);
    update(['map']);
  }

  void startTracking(OrderModel o) {
    final token = db.accessToken ?? '';
    final id = db.user!.id;
    if (token.isEmpty || id == null) {
      debugPrint('Shipment Controller: cannot connect - missing token or driver');
      // isOnline.value = false; // revert
      return;
    }

    // Connect low-level socket
    socketService.connect(token, id);

    _liveLocSub?.cancel();
    order.value = o;

    try {
      userOrderSocket.startTracking(o);
    } catch (e) {
      debugPrint('UserOrderSocket.startTracking error: $e');
    }

    _ensurePickupDropMarkers();
    _subscribeToLiveLocationForOrder(o.id);
  }

  void startTrackingWithDriver(OrderModel driver, LatLng driverLoc) {
    _liveLocSub?.cancel();

    driverLocation.value = driverLoc;
    _ensurePickupDropMarkers();
    _updateDriverMarker(driverLoc, prev: null);

    final target = _determineTargetLatLng();
    if (target != null) {
      _updateRoute(driverLoc, target);
      _updateDistanceEta(driverLoc, target);
    }

    update();
  }

  void stopTracking() {
    try {
      userOrderSocket.stopTracking();
    } catch (_) {}
    order.value = null;
    driverLocation.value = null;
    markers.clear();
    polylines.clear();
    etaMinutes.value = 0;
    distanceMeters.value = 0.0;
    _liveLocSub?.cancel();
  }

  void _ensurePickupDropMarkers() {
    final o = order.value;
    if (o == null) return;

    if (o.pickup.latitude == null || o.pickup.longitude == null) return;
    if (o.dropoff.latitude == null || o.dropoff.longitude == null) return;

    final pickupLat = LatLng(o.pickup.latitude!, o.pickup.longitude!);
    final dropLat = LatLng(o.dropoff.latitude!, o.dropoff.longitude!);

    markers.removeWhere((m) => m.markerId.value == 'pickup' || m.markerId.value == 'dropoff');

    final pIcon = iconsReady.value ? pickupIcon : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    final dIcon = iconsReady.value ? dropoffIcon : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLat,
      icon: pIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: 'Pickup', snippet: o.pickup.address),
      zIndex: 10,
    ));

    markers.add(Marker(
      markerId: const MarkerId('dropoff'),
      position: dropLat,
      icon: dIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: 'Dropoff', snippet: o.dropoff.address),
      zIndex: 9,
    ));

    markers.refresh();
    update();
  }

  void _subscribeToLiveLocationForOrder(String shipmentId) {
    _liveLocSub?.cancel();

    _liveLocSub = userOrderSocket.liveLocations.listen((map) {
      if (order.value == null) return;
      final id = order.value!.id;
      final entry = map[id];
      if (entry == null) {
        // if the order has liveLocation inside model payload, seed it
        final modelLive = order.value!.liveLocation;
        if (modelLive != null && modelLive['lat'] != null && modelLive['lng'] != null) {
          final newLatLng = LatLng((modelLive['lat'] as num).toDouble(), (modelLive['lng'] as num).toDouble());
          _updateDriverLocation(newLatLng);
        }
        return;
      }

      final lat = (entry['lat'] is num) ? (entry['lat'] as num).toDouble() : double.tryParse(entry['lat'].toString());
      final lng = (entry['lng'] is num) ? (entry['lng'] as num).toDouble() : double.tryParse(entry['lng'].toString());
      if (lat == null || lng == null) return;

      final newLatLng = LatLng(lat, lng);
      _updateDriverLocation(newLatLng);
    }, onError: (e) {
      debugPrint('ShipmentTrackingController: liveLocations listen error: $e');
    });
  }

  void _updateDriverLocation(LatLng newLoc) {
    final prev = driverLocation.value;
    driverLocation.value = newLoc;

    _updateDriverMarker(newLoc, prev: prev);

    final target = _determineTargetLatLng();
    if (target != null) {
      _updateDistanceEta(newLoc, target);
      _updateRoute(newLoc, target);
    }

    update();
  }

  void _updateDriverMarker(LatLng pos, {LatLng? prev}) {
    final iconToUse = iconsReady.value ? (driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)) : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

    markers.removeWhere((m) => m.markerId.value == 'driver');
    final bearing = prev == null ? 0.0 : _computeBearing(prev, pos);
    markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: pos,
      rotation: bearing,
      icon: iconToUse,
      anchor: const Offset(0.5, 0.5),
      zIndex: 100,
    ));

    markers.refresh();
  }

  void _updateDistanceEta(LatLng from, LatLng to) {
    final dist = _haversineMeters(from.latitude, from.longitude, to.latitude, to.longitude);
    distanceMeters.value = dist;
    final avgSpeedMs = 8.3; // ~30 km/h
    final secondsRemaining = (dist / avgSpeedMs).round();
    etaMinutes.value = (secondsRemaining / 60).ceil();
  }

  LatLng? _determineTargetLatLng() {
    final o = order.value;
    if (o == null) return null;
    final status = o.status.value;
    if (status == OrderStatus.InTransit) {
      if (o.dropoff.latitude == null || o.dropoff.longitude == null) return null;
      return LatLng(o.dropoff.latitude!, o.dropoff.longitude!);
    }
    if (status == OrderStatus.Created || status == OrderStatus.Assigned || status == OrderStatus.Accepted) {
      if (o.pickup.latitude == null || o.pickup.longitude == null) return null;
      return LatLng(o.pickup.latitude!, o.pickup.longitude!);
    }
    if (o.dropoff.latitude == null || o.dropoff.longitude == null) return null;
    return LatLng(o.dropoff.latitude!, o.dropoff.longitude!);
  }

  double _computeBearing(LatLng? from, LatLng to) {
    if (from == null) return 0.0;
    final fromLat = _toRadians(from.latitude);
    final fromLng = _toRadians(from.longitude);
    final toLat = _toRadians(to.latitude);
    final toLng = _toRadians(to.longitude);
    final dLng = toLng - fromLng;
    final y = math.sin(dLng) * math.cos(toLat);
    final x = math.cos(fromLat) * math.sin(toLat) - math.sin(fromLat) * math.cos(toLat) * math.cos(dLng);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double deg) => deg * math.pi / 180;

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dphi = (lat2 - lat1) * math.pi / 180;
    final dlambda = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dphi / 2) * math.sin(dphi / 2) + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) * math.sin(dlambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  Future<void> _updateRoute(LatLng origin, LatLng destination) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$googleApiKey'
          '&mode=driving';
      final res = await Dio().get(url);
      if (res.data['status'] != 'OK') {
        debugPrint('Directions API status: ${res.data['status']}');
        polylines.clear();
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: [origin, destination],
          width: 6,
          color: AppColors.primary,
        ));
        polylines.refresh();
        update();
        return;
      }

      final routes = res.data['routes'] as List<dynamic>;
      if (routes.isEmpty) return;
      final encoded = routes[0]['overview_polyline']['points'] as String;
      final decoded = PolylinePoints.decodePolyline(encoded);
      final points = decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

      polylines.clear();
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        width: 6,
        color: AppColors.primary,
      ));
      polylines.refresh();
      update();
    } catch (e) {
      debugPrint('Error updating route: $e');
      polylines.clear();
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [origin, destination],
        width: 6,
        color: AppColors.primary,
      ));
      polylines.refresh();
      update();
    }
  }

  void _startLiveLocationListener() {
    _activeOrderSub?.cancel();

    _activeOrderSub = userOrderSocket.activeTrackingOrder.listen((OrderModel? o) {
      if (o == null) {
        _liveLocSub?.cancel();
        return;
      }
      if (order.value == null || order.value!.id != o.id) {
        startTracking(o);
      }
    }, onError: (e) {
      debugPrint('_startLiveLocationListener error: $e');
    });
  }

  @override
  void onClose() {
    _liveLocSub?.cancel();
    _activeOrderSub?.cancel();
    super.onClose();
  }
}
