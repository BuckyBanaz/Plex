
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/Toast/toast.dart';
import '../../../modules/controllers/location/location_permission_controller.dart';
import '../../widgets/helpers.dart';

enum DeliveryStage { toPickup, toDropoff, completed }

class DriverOrderTrackingController extends GetxController {
  late Map<String, dynamic> shipment;
  final Rx<DeliveryStage> stage = DeliveryStage.toPickup.obs;
  final RxInt etaMinutes = 5.obs;
  final RxBool isActionButtonEnabled = false.obs;
  final RxString actionButtonText = 'Start Pick Up'.obs;
  final RxDouble driverBearing = 0.0.obs; // For rotation

  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  late LatLng pickupLatLng;
  late LatLng dropoffLatLng;
  LatLng? currentLatLng;
  final double arrivalThreshold = 50;
  final String googleApiKey = "AIzaSyAoVauo0szWOaKCsNW6lqklZCXmZED-7ZU";
  late final PolylinePoints polylinePointsDecoder;

  // SVG Bitmaps
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? dropoffIcon;

  @override
  void onInit() async {
    super.onInit();
    polylinePointsDecoder = PolylinePoints(apiKey: googleApiKey);
    shipment = Get.arguments['shipment'] ?? {};
    await _loadCustomIcons();
    _initLocations();
    _listenToLocation();
    _requestInitialLocation();
  }

  Future<void> _loadCustomIcons() async {
    driverIcon = await _svgToBitmapDescriptor('assets/icons/driver.svg', size: 80);
    pickupIcon = await _svgToBitmapDescriptor('assets/icons/pickup_t.svg', size: 60);
    dropoffIcon = await _svgToBitmapDescriptor('assets/icons/dropoff.svg', size: 60);
    update(['map']);
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
  void _initLocations() {
    final pickup = shipment['pickup'];
    final dropoff = shipment['dropoff'];
    pickupLatLng = LatLng(
      (pickup['latitude'] as num).toDouble(),
      (pickup['longitude'] as num).toDouble(),
    );
    dropoffLatLng = LatLng(
      (dropoff['latitude'] as num).toDouble(),
      (dropoff['longitude'] as num).toDouble(),
    );

    // Only show pickup initially
    _addPickupMarker();
  }

  void _addPickupMarker() {
    markers.add(Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      infoWindow: InfoWindow(title: 'Pickup', snippet: shipment['pickup']['address'] ?? ''),
      icon: pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
  }

  void _addDropoffMarker() {
    markers.add(Marker(
      markerId: MarkerId('dropoff'),
      position: dropoffLatLng,
      infoWindow: InfoWindow(title: 'Dropoff', snippet: shipment['dropoff']['address'] ?? ''),
      icon: dropoffIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  void _updateCurrentMarker(LatLng pos) {
    markers.removeWhere((m) => m.markerId.value == 'current');
    markers.add(Marker(
      markerId: MarkerId('current'),
      position: pos,
      rotation: driverBearing.value,
      icon: driverIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
      flat: false,
      zIndex: 100,
    ));
  }
  void _requestInitialLocation() async {
    final locCtrl = Get.find<LocationController>();
    final position = await locCtrl.gl.determinePosition(
      forceGivePermission: true,
      forceTurnOnLocation: true,
    );
    if (position != null) {
      currentLatLng = LatLng(position.latitude, position.longitude);
      driverBearing.value = position.heading;
      _updateCurrentMarker(currentLatLng!);
      _checkArrival();
      _updateRoute();
      _fitCameraToIncludeCurrent();
      update();
    } else {
      showToast(message: 'Please enable location services');
    }
  }

  void _listenToLocation() {
    final locCtrl = Get.find<LocationController>();
    locCtrl.currentPosition.listen((value) {
      if (value == null) return;
      final LatLng converted = _toLatLng(value);
      final oldPos = currentLatLng;
      currentLatLng = converted;

      // Update bearing only if moving
      if (oldPos != null && Geolocator.distanceBetween(oldPos.latitude, oldPos.longitude, converted.latitude, converted.longitude) > 5) {
        driverBearing.value = _calculateBearing(oldPos, converted);
      }

      _updateCurrentMarker(converted);
      _checkArrival();
      _updateRoute();
      update();
    });
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final startLat = _toRadians(start.latitude);
    final startLng = _toRadians(start.longitude);
    final endLat = _toRadians(end.latitude);
    final endLng = _toRadians(end.longitude);

    final dLng = endLng - startLng;
    final y = math.sin(dLng) * math.cos(endLat);
    final x = math.cos(startLat) * math.sin(endLat) - math.sin(startLat) * math.cos(endLat) * math.cos(dLng);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  LatLng _toLatLng(dynamic v) {
    if (v is LatLng) return v;
    if (v is Position) return LatLng(v.latitude, v.longitude);
    try {
      final lat = (v.latitude ?? v['latitude']) as num;
      final lng = (v.longitude ?? v['longitude']) as num;
      return LatLng(lat.toDouble(), lng.toDouble());
    } catch (_) {
      throw Exception('Unsupported location type: ${v.runtimeType}');
    }
  }

  void _checkArrival() {
    if (currentLatLng == null) return;
    final target = stage.value == DeliveryStage.toPickup ? pickupLatLng : dropoffLatLng;
    final distance = Geolocator.distanceBetween(
      currentLatLng!.latitude,
      currentLatLng!.longitude,
      target.latitude,
      target.longitude,
    );
    final effectiveThreshold = arrivalThreshold + 5.0;
    isActionButtonEnabled.value = distance <= effectiveThreshold;
    debugPrint('Distance: ${distance.toStringAsFixed(1)}m → Enabled: ${isActionButtonEnabled.value}');
  }

  void onActionButtonPressed() async {
    if (!isActionButtonEnabled.value) return;

    if (stage.value == DeliveryStage.toPickup) {
      stage.value = DeliveryStage.toDropoff;
      actionButtonText.value = 'Confirm Delivery';
      etaMinutes.value = 20;

      // Pickup location becomes current
      currentLatLng = pickupLatLng;
      driverBearing.value = 0;
      _updateCurrentMarker(currentLatLng!);

      // Now show dropoff
      _addDropoffMarker();
      _checkArrival();
      _updateRoute();
      _fitCameraToIncludeCurrent();
    } else if (stage.value == DeliveryStage.toDropoff) {
      stage.value = DeliveryStage.completed;
      isActionButtonEnabled.value = false;


      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Congratulations!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          content: Text('You have successfully completed the delivery!'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text('OK', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    }
    update();
  }

  Future<void> _updateRoute() async {
    if (currentLatLng == null) return;
    final origin = currentLatLng!;
    final destination = stage.value == DeliveryStage.toPickup ? pickupLatLng : dropoffLatLng;

    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$googleApiKey'
          '&mode=driving';

      final response = await Dio().get(url);
      if (response.data['status'] != 'OK') return;

      final route = response.data['routes'][0];
      final polylineEncoded = route['overview_polyline']['points'];
      final leg = route['legs'][0];
      final durationText = leg['duration']['text'] as String? ?? '';
      int minutes = _parseDurationToMinutes(durationText);
      etaMinutes.value = minutes > 0 ? minutes : 5;

      final List<PointLatLng> decoded = PolylinePoints.decodePolyline(polylineEncoded);
      final List<LatLng> points = decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

      polylines.clear();
      polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 6,
      ));

      // Driver icon at start of polyline
      if (points.isNotEmpty) {
        currentLatLng = points[0];
        _updateCurrentMarker(points[0]);
        _fitCameraToRoute();
      }
    } catch (e) {
      debugPrint('Directions API error: $e');
    }
  }

  int _parseDurationToMinutes(String duration) {
    if (duration.isEmpty) return 0;
    final hourReg = RegExp(r'(\d+)\s*hour');
    final minReg = RegExp(r'(\d+)\s*min');
    int hours = int.tryParse(hourReg.firstMatch(duration)?.group(1) ?? '0') ?? 0;
    int mins = int.tryParse(minReg.firstMatch(duration)?.group(1) ?? '0') ?? 0;
    return hours * 60 + mins;
  }

  void _fitCameraToRoute() {
    if (polylines.isEmpty || mapController == null) return;
    final points = polylines.first.points;
    if (points.isEmpty) return;

    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
    try {
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      debugPrint('_fitCameraToRoute error: $e');
      if (currentLatLng != null) {
        try {
          mapController!.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
        } catch (e2) {
          debugPrint('_fitCameraToRoute fallback error: $e2');
        }
      }
    }
  }

  void _fitCameraToIncludeCurrent() {
    if (currentLatLng == null || mapController == null) return;
    try {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng!, 15));
    } catch (e) {
      debugPrint('_fitCameraToIncludeCurrent error: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLatLng != null) {
      _updateRoute();
      _fitCameraToIncludeCurrent();
    }
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
class DriverOrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverOrderTrackingController());
    ever(ctrl.polylines, (_) => ctrl.update(['map']));
    ever(ctrl.markers, (_) => ctrl.update(['map']));

    return Scaffold(
      body: Stack(
        children: [
          GetBuilder<DriverOrderTrackingController>(
            id: 'map',
            builder: (ctrl) => GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(28.6, 77.2), zoom: 14),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              markers: ctrl.markers,
              polylines: ctrl.polylines,
              onMapCreated: ctrl.onMapCreated,
              zoomControlsEnabled: false,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 22,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildCard(ctrl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(DriverOrderTrackingController ctrl) {
    final pickup = ctrl.shipment['pickup'] ?? {};
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
          '${ctrl.etaMinutes.value} minutes to ${ctrl.stage.value == DeliveryStage.toPickup ? 'Pick up' : 'delivery'}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 4),
        Text('Immediate', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primarySwatch.shade100,
              child: Text(
                _initials((pickup['name'] as String?) ?? 'PV'),
                style: TextStyle(color:AppColors.primarySwatch.shade800, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((pickup['name'] as String?) ?? 'Parikshit Verma', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Order id: ${ctrl.shipment['id'] ?? 'dc5a07-af3-4e7c-...'}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                  Row(
                    children: [
                      CircularIconButton(icon: IconlyBold.call, onTap: () {}),
                      SizedBox(width: 12),
                      CircularIconButton(icon: IconlyBold.chat, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: ctrl.isActionButtonEnabled.value ? ctrl.onActionButtonPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(ctrl.actionButtonText.value, style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        )),
      ],
    );
  }

  String _initials(String name) {
    return name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
  }
}








