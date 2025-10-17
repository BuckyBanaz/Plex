
import 'dart:async';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constant/preference_keys.dart';
import '../../../../models/common/device_info.dart';
import '../../../../models/user_models.dart';
import '../../repository/initialize_repository.dart';
import '../api/api_import.dart';

part 'app_service.dart';
part 'database_service.dart';
part 'device_info_service.dart';

