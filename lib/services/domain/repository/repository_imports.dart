
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/models/corporate_register_model.dart';
import 'package:plex_user/models/driver_order_model.dart';
import 'package:plex_user/models/driver_user_model.dart';
import 'package:plex_user/models/kyc_model.dart';
import 'package:plex_user/models/user_models.dart';
import 'package:plex_user/models/notification_model.dart';
import 'package:plex_user/services/domain/service/api/api_import.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:plex_user/services/translations/locale_controller.dart';





part 'authentication/auth.dart';
part 'user/user_repo.dart';
part 'map/map_repo.dart';
part 'shipment/shipment_repo.dart';
part 'notification/notification_repo.dart';



// part 'File/file_repository.dart';

// part 'User/user_repository.dart';
// part 'Notification/notification_repository.dart';
// part 'Search/search_repository.dart';