
import 'dart:async';
import 'dart:io';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:plex_user/constant/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/Toast/toast.dart';
import '../../../../common/dialog/app_dialog.dart';
import '../../../../constant/preference_keys.dart';
import '../../../../models/common/device_info.dart';
import '../../../../models/user_models.dart';
import '../../../../screens/location/location_permission_screen.dart';
import '../../repository/initialize_repository.dart';
import '../api/api_import.dart';

part 'app_service.dart';
part 'database_service.dart';
part 'device_info_service.dart';
part 'location_service.dart';

