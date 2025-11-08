
import 'dart:async';
import 'dart:io';



import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:plex_user/models/driver_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/dialog/app_dialog.dart';
import '../../../../constant/preference_keys.dart';
import '../../../../models/common/device_info.dart';
import '../../../../models/user_models.dart';
import '../../../translations/locale_controller.dart';
import '../../repository/initialize_repository.dart';
import '../api/api_import.dart';
import '../socket/socket_service.dart';

part 'app_service.dart';
part 'database_service.dart';
part 'device_info_service.dart';
part 'location_service.dart';
part 'messaging_service.dart';

