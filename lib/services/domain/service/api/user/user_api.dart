part of 'package:plex_user/services/domain/service/api/api_import.dart';

class UserApi {
  final Dio dio;
  UserApi(this.dio);

  final basePath = '';

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double heading,
    required double speed,
    required String recordedAt, // ISO 8601 format string
    required int langKey,
    required String apiKey,
  }) async {

    final response = await dio.put(
      '$basePath${ApiEndpoint.location}',
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "heading": heading,
        "speed": speed,
        "recorded_at": recordedAt,
      },
      options: Options(
        headers: {
          'lang_id': langKey,
          'api_key': apiKey,
        },
      ),
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }


  Future<Map<String, dynamic>> createShipment({
    required String userId,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '$basePath/shipments/create',
        data: {
          "userId": userId,
          "originLat": originLat,
          "originLng": originLng,
          "destinationLat": destinationLat,
          "destinationLng": destinationLng,
          "weight": weight,
        },
      );

      return (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString()};
    } catch (e) {
      debugPrint('Error creating shipment: $e');
      return {'error': e.toString()};
    }
  }




  /// Create PaymentIntent on server
  Future<Map<String, dynamic>> createPaymentIntent({ required int amount, required String currency, String? orderId }) async {
    final resp = await dio.post('/payments/create-payment-intent', data: {
      'amount': amount,
      'currency': currency,
      'orderId': orderId,
    });
    return resp.data as Map<String, dynamic>;
  }

  /// Sends `payment_method` as snake_case if your backend expects that.
  Future<Map<String, dynamic>> confirmStripePayment({
    required String paymentIntentId,
    required String paymentMethod,
  }) async {
    try {
      final resp = await dio.post(
        '/shipments/confirm-stripe',
        data: {
          'paymentIntentId': paymentIntentId,
          'payment_method': paymentMethod,
          'return_url': "http://p2dev10.in/success",
        },
      );

      // If server returned a JSON object, cast it. Otherwise wrap into a map.
      if (resp.data is Map<String, dynamic>) {
        return resp.data as Map<String, dynamic>;
      } else if (resp.data is Map) {
        // defensive cast
        return Map<String, dynamic>.from(resp.data as Map);
      } else {
        // fallback: return the raw response under a key
        return {'response': resp.data};
      }
    } on DioError catch (e) {
      // Optionally inspect e.response?.data to return richer error info
      rethrow;
    }
  }
  //
  // /// (Optional) endpoint to confirm payment/update order after webhook
  // Future<Map<String, dynamic>> confirmPaymentOnServer(String paymentIntentId) async {
  //   final resp = await dio.post('/payments/confirm', data: {'paymentIntentId': paymentIntentId});
  //   return resp.data as Map<String, dynamic>;
  // }
  Future<Map<String, dynamic>> getAddress({
    required int langKey,
  }) async {

    final response = await dio.get(
      '$basePath${ApiEndpoint.userAddress}',
      options: Options(
        headers: {
          'lang_id': langKey,
        },
      ),
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  Future<Map<String, dynamic>> addAddress({
    required String address,
    required String addressAs,
    required String landmark,
    required String locality,
    required double latitude,
    required double longitude,
    required bool isDefault,
    required int langKey,
  }) async {

    final response = await dio.post(
      '$basePath${ApiEndpoint.userAddress}',
      data: {
        "address": address,
        "addressAs": addressAs,
        "landmark": landmark,
        "locality": locality,
        "latitude": latitude,
        "longitude": longitude,
        "isDefault": isDefault,
      },
      options: Options(
        headers: {
          'lang_id': langKey,
        },
      ),
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }


  /// DELETE /address/{id}
  Future<Map<String, dynamic>> deleteAddress({
    required int id,
    required int langKey,
  }) async {
    final response = await dio.delete(
      '$basePath${ApiEndpoint.userAddress}/$id',
      options: Options(
        headers: {
          'lang_id': langKey,
        },
      ),
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }


  Future<Map<String, dynamic>> updateStatus({
    required String userId,
    required bool isOnline,
  }) async {

    final response = await dio.put(
      '$basePath${ApiEndpoint.updateStatus}/$userId',
      data: {
        "isOnline": isOnline,
      },
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }


  Future<Map<String, dynamic>> updateFcm({
    required String userId,
    required String fcmToken,
  }) async {

    final response = await dio.put(
      '$basePath${ApiEndpoint.fcmToken}/$userId',
      data: {
        "fcmToken": fcmToken,
      },
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }
}