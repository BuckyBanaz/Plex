part of 'app_service_imports.dart';
//
// class GeolocationService {
//
//   Future<GeolocationService> init() async {
//     listener = Geolocator.getServiceStatusStream().listen(onStatusChanged);
//     debugPrint('Geolocation service is initialized');
//     return this;
//   }
//
//   @override
//   void onClose() {
//     listener?.cancel();
//   }
//
//   StreamSubscription<ServiceStatus>? listener;
//   // var userApi = sl.get<UserApi>();
//   var db = Get.find<DatabaseService>();
//
//   Future<Position?> determinePosition({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if(forceTurnOnLocation) {
//         AppDialog.alert(
//           title: const Text('Turn on Location'),
//           content: const Text('Please turn on the location services to go ahead.'),
//           confirmText: 'OK',
//           denyText: ''
//         ).then((value){
//           if(value ?? false) Geolocator.openLocationSettings();
//         });
//       }
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       if(forceGivePermission) {
//         AppDialog.alert(
//           title: const Text('Location Permission'),
//           content: const Text('Location permission is needed to use the app.'),
//           confirmText: 'OK',
//           denyText: ''
//         ).then((value){
//           if(value ?? false) Geolocator.openAppSettings();
//         });
//       }
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     try {
//       return await Geolocator.getCurrentPosition(
//           timeLimit: const Duration(seconds: 2),
//           desiredAccuracy: LocationAccuracy.best);
//     } catch (e) {
//       return await Geolocator.getLastKnownPosition();
//     }
//   }
//
//   Future<String> getLocationString({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
//     var position = await determinePosition(
//         forceTurnOnLocation: forceTurnOnLocation,
//         forceGivePermission: forceGivePermission);
//     if(position == null) return '';
//     var locationString = [position.latitude, position.longitude].join(',');
//     db.putLastKnownLocation(locationString);
//     return locationString;
//   }
//
//   Future<String> getLastKnownLocationString({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
//     try {
//       return await getLocationString(
//           forceTurnOnLocation: forceTurnOnLocation,
//           forceGivePermission: forceGivePermission);
//     } catch (e) {
//       return db.lastKnownLocation ?? '';
//     }
//   }
//
//   Future<bool> isPermissionGranted() async => await Geolocator.checkPermission() != LocationPermission.denied;
//
//   Future<bool> getPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if(permission == LocationPermission.deniedForever) {
//       Geolocator.openAppSettings();
//       return false;
//     }
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return false;
//     }
//     return permission != LocationPermission.denied;
//   }
//
//   void onStatusChanged(ServiceStatus status) {
//     if(status == ServiceStatus.enabled) {
//       sendLocation();
//     }
//   }
//
//   /// Updated sendLocation to print full Position details
//   void sendLocation() async {
//     try {
//       var position = await getLocationString(forceTurnOnLocation: false);
//       if (position.isNotEmpty) {
//         // Retrieve full Position object
//         var pos = await determinePosition(forceTurnOnLocation: false);
//         if (pos != null) {
//           debugPrint('--- Position Details ---');
//           debugPrint('Latitude: ${pos.latitude}');
//           debugPrint('Longitude: ${pos.longitude}');
//           debugPrint('Altitude: ${pos.altitude}');
//           debugPrint('Accuracy: ${pos.accuracy}');
//           debugPrint('Heading: ${pos.heading}');
//           debugPrint('Speed: ${pos.speed}');
//           debugPrint('Speed Accuracy: ${pos.speedAccuracy}');
//           debugPrint('Timestamp: ${pos.timestamp}');
//           debugPrint('------------------------');
//         }
//       }
//       // if(position.isNotEmpty) await userApi.userLocation(location: position);
//     } catch (e) {
//       debugPrint('Failed to get location: $e');
//     }
//   }
//
// }
//
//
// part of 'app_service_imports.dart';

class GeolocationService {

  StreamSubscription<ServiceStatus>? listener;
  var db = Get.find<DatabaseService>();

  Future<GeolocationService> init() async {
    listener = Geolocator.getServiceStatusStream().listen(onStatusChanged);
    debugPrint('Geolocation service is initialized');
    return this;
  }

  @override
  void onClose() {
    listener?.cancel();
  }

  Future<Position?> determinePosition({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if(forceTurnOnLocation) {
        // Show alert dialog to turn ON location
                AppDialog.alert(
          title: const Text('Turn on Location'),
          content: const Text('Please turn on the location services to go ahead.'),
          confirmText: 'OK',
          denyText: ''
        ).then((value){
          if(value ?? false) Geolocator.openLocationSettings();
        });
      }
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if(forceGivePermission) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Location Permission'),
            content: const Text('Location permission is needed to use the app.'),
            actions: [
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Get.back();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return Future.error('Location permissions are permanently denied.');
    }

    try {
      return await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 2),
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<String> getLocationString({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
    var position = await determinePosition(
        forceTurnOnLocation: forceTurnOnLocation,
        forceGivePermission: forceGivePermission);
    if(position == null) return '';
    var locationString = [position.latitude, position.longitude].join(',');
    db.putLastKnownLocation(locationString);
    return locationString;
  }

  Future<String> getLastKnownLocationString({bool forceTurnOnLocation = false, bool forceGivePermission = false}) async {
    try {
      return await getLocationString(
          forceTurnOnLocation: forceTurnOnLocation,
          forceGivePermission: forceGivePermission);
    } catch (e) {
      return db.lastKnownLocation ?? '';
    }
  }

  Future<bool> isPermissionGranted() async => await Geolocator.checkPermission() != LocationPermission.denied;

  Future<bool> getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.denied;
  }

  void onStatusChanged(ServiceStatus status) async {
    if(status == ServiceStatus.enabled) {
      await sendLocationWithApi();
    }
  }

  /// Sends location and calls API when position changes
  Future<void> sendLocationWithApi() async {
    try {
      var pos = await determinePosition(forceTurnOnLocation: true);
      if (pos != null) {
        debugPrint('--- Position Details ---');
        debugPrint('Latitude: ${pos.latitude}');
        debugPrint('Longitude: ${pos.longitude}');
        debugPrint('Altitude: ${pos.altitude}');
        debugPrint('Accuracy: ${pos.accuracy}');
        debugPrint('Heading: ${pos.heading}');
        debugPrint('Speed: ${pos.speed}');
        debugPrint('Speed Accuracy: ${pos.speedAccuracy}');
        debugPrint('Timestamp: ${pos.timestamp}');
        debugPrint('------------------------');

        // TODO: Call your API here
        // await userApi.userLocation(location: [pos.latitude, pos.longitude].join(','));
      }
    } catch (e) {
      debugPrint('Failed to get/send location: $e');
      // showToast(message: e.toString());
    }
  }
}
