import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:get/get.dart' as gt;
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/constant/api_endpoint.dart';
import 'package:plex_user/routes/appRoutes.dart';

import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../common/Toast/toast.dart';
import '../../../../constant/error_string.dart';
import '../../../../core/app.dart';
import '../../../../main.dart';
import '../../../translations/locale_controller.dart';
import '../../repository/repository_imports.dart';


/// api service imports
part 'api_service.dart';
part 'dio_interceptors.dart';
part 'dio_exceptions.dart';

part 'authentication/auth_api.dart';
part 'user/user_api.dart';
part 'map/map_api.dart';
part 'shipment/shipment_api.dart';

// part 'user/user.dart';