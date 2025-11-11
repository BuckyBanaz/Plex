
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:plex_user/models/driver_user_model.dart';


import '../../../common/Toast/toast.dart';
import '../../../models/corporate_register_model.dart';
import '../../../models/user_models.dart';
import '../../translations/locale_controller.dart';
import '../service/api/api_import.dart';
import '../service/app/app_service_imports.dart';



part 'authentication/auth.dart';
part 'user/user_repo.dart';
part 'map/map_repo.dart';
part 'shipment/shipment_repo.dart';



// part 'File/file_repository.dart';

// part 'User/user_repository.dart';
// part 'Notification/notification_repository.dart';
// part 'Search/search_repository.dart';