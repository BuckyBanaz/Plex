// file: models/order_model.dart
import 'dart:convert';

import 'package:get/get.dart';

enum OrderStatus {
  Pending,
  Created,
  Assigned,
  Accepted,
  InTransit,
  Delivered,
  Declined,
  Cancelled,
}

class CollectTime {
  final String type;
  final DateTime? scheduledAt;

  CollectTime({required this.type, this.scheduledAt});

  factory CollectTime.fromJson(dynamic json) {
    if (json == null) return CollectTime(type: 'unknown');
    try {
      if (json is String) {
        // sometimes backend gives stringified JSON
        final parsed = jsonDecode(json);
        return CollectTime.fromJson(parsed);
      }
      final type = (json['type'] ?? 'unknown').toString();
      DateTime? dt;
      try {
        if (json['scheduledAt'] != null) dt = DateTime.parse(json['scheduledAt'].toString());
      } catch (_) {
        dt = null;
      }
      return CollectTime(type: type, scheduledAt: dt);
    } catch (_) {
      return CollectTime(type: 'unknown');
    }
  }
}

class LocationInfo {
  final String name;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;

  LocationInfo({
    required this.name,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory LocationInfo.fromJson(dynamic json) {
    if (json == null) {
      return LocationInfo(name: 'N/A', phone: 'N/A', address: 'Unknown');
    }
    try {
      if (json is String) {
        final parsed = jsonDecode(json);
        return LocationInfo.fromJson(parsed);
      }
      double? _lat;
      double? _lng;
      try {
        if (json['latitude'] != null) _lat = (json['latitude'] as num).toDouble();
      } catch (_) {
        _lat = null;
      }
      try {
        if (json['longitude'] != null) _lng = (json['longitude'] as num).toDouble();
      } catch (_) {
        _lng = null;
      }

      return LocationInfo(
        name: (json['name'] ?? 'N/A').toString(),
        phone: (json['phone'] ?? 'N/A').toString(),
        address: (json['address'] ?? 'Unknown').toString(),
        latitude: _lat,
        longitude: _lng,
      );
    } catch (_) {
      return LocationInfo(name: 'N/A', phone: 'N/A', address: 'Unknown');
    }
  }
}

class PriceBreakdown {
  final double tax;
  final double baseFare;
  final double distanceFare;

  PriceBreakdown({required this.tax, required this.baseFare, required this.distanceFare});

  factory PriceBreakdown.fromJson(dynamic json) {
    if (json == null) return PriceBreakdown(tax: 0.0, baseFare: 0.0, distanceFare: 0.0);
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    try {
      if (json is String) {
        final parsed = jsonDecode(json);
        return PriceBreakdown.fromJson(parsed);
      }
      return PriceBreakdown(
        tax: _toDouble(json['tax']),
        baseFare: _toDouble(json['baseFare']),
        distanceFare: _toDouble(json['distanceFare']),
      );
    } catch (_) {
      return PriceBreakdown(tax: 0.0, baseFare: 0.0, distanceFare: 0.0);
    }
  }
}

class Pricing {
  final double amount;
  final String currency;
  final int? distanceMeters;
  final PriceBreakdown? priceBreakdown;

  Pricing({required this.amount, required this.currency, this.distanceMeters, this.priceBreakdown});

  factory Pricing.fromJson(dynamic json) {
    if (json == null) return Pricing(amount: 0.0, currency: 'INR', distanceMeters: null, priceBreakdown: null);
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    try {
      if (json is String) {
        final parsed = jsonDecode(json);
        return Pricing.fromJson(parsed);
      }

      final amt = _toDouble(json['amount'] ?? json['estimatedCost'] ?? 0.0);
      final currency = (json['currency'] ?? 'INR').toString();
      int? distanceMeters;
      try {
        if (json['distanceMeters'] != null) distanceMeters = int.tryParse(json['distanceMeters'].toString());
      } catch (_) {
        distanceMeters = null;
      }

      return Pricing(
        amount: amt,
        currency: currency,
        distanceMeters: distanceMeters,
        priceBreakdown: PriceBreakdown.fromJson(json['priceBreakdown']),
      );
    } catch (_) {
      return Pricing(amount: 0.0, currency: 'INR', distanceMeters: null, priceBreakdown: null);
    }
  }
}

class Estimate {
  final double estimatedCostINR;
  final double estimatedCostUSD;
  final double distanceKm;
  final String durationText;
  final String currency;

  Estimate({
    required this.estimatedCostINR,
    required this.estimatedCostUSD,
    required this.distanceKm,
    required this.durationText,
    required this.currency,
  });

  factory Estimate.fromJson(dynamic json) {
    if (json == null) return Estimate(estimatedCostINR: 0.0, estimatedCostUSD: 0.0, distanceKm: 0.0, durationText: '', currency: 'INR');
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    try {
      if (json is String) {
        final parsed = jsonDecode(json);
        return Estimate.fromJson(parsed);
      }

      return Estimate(
        estimatedCostINR: _toDouble(json['estimatedCostINR'] ?? json['estimatedCost'] ?? 0.0),
        estimatedCostUSD: _toDouble(json['estimatedCostUSD'] ?? 0.0),
        distanceKm: _toDouble(json['distanceKm'] ?? 0.0),
        durationText: (json['durationText'] ?? '').toString(),
        currency: (json['currency'] ?? 'INR').toString(),
      );
    } catch (_) {
      return Estimate(estimatedCostINR: 0.0, estimatedCostUSD: 0.0, distanceKm: 0.0, durationText: '', currency: 'INR');
    }
  }
}

class OrderModel {
  final String id; // backend numeric id converted to string
  final String orderId; // UUID-like orderId from backend
  final int? userId;
  final String vehicleType;
  final List<dynamic> images;
  final CollectTime collectTime;
  final LocationInfo pickup;
  final LocationInfo dropoff;
  final String weight;
  final String notes;
  final Estimate? estimate;
  final String invoiceNumber;
  final Rx<OrderStatus> status; // observable status
  final String paymentStatus;
  final String paymentMethod;
  final double estimatedCost;
  final Pricing? pricing;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? reference;
  final int? driverId;
  final int? vehicleId;
  final Map<String, dynamic>? driverDetails;
  final String? stripePaymentIntentId;
  final String? clientSecret;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.orderId,
    this.userId,
    required this.vehicleType,
    required this.images,
    required this.collectTime,
    required this.pickup,
    required this.dropoff,
    required this.weight,
    required this.notes,
    this.estimate,
    required this.invoiceNumber,
    required OrderStatus initialStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.estimatedCost,
    this.pricing,
    this.updatedAt,
    this.createdAt,
    this.reference,
    this.driverId,
    this.vehicleId,
    this.driverDetails,
    this.stripePaymentIntentId,
    this.clientSecret,
    this.deliveredAt,
  }) : status = initialStatus.obs;

  // Primary factory — accepts many possible shapes
  factory OrderModel.fromJson(dynamic rawJson) {
    // normalize input
    try {
      Map<String, dynamic> json;
      if (rawJson is String) {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        } else {
          json = {};
        }
      } else if (rawJson is Map) {
        json = Map<String, dynamic>.from(rawJson as Map);
      } else {
        json = {};
      }

      // If payload contains "shipments": [ ... ] — pick first element (useful for list endpoints)
      if (json.containsKey('shipments') && json['shipments'] is List && (json['shipments'] as List).isNotEmpty) {
        final first = (json['shipments'] as List).first;
        if (first is Map) json = Map<String, dynamic>.from(first);
      }

      // If the payload is wrapped as { "shipment": { ... } } then unwrap it
      if (json.containsKey('shipment') && json['shipment'] is Map) {
        json = Map<String, dynamic>.from(json['shipment']);
      }

      // Helper parsing functions
      DateTime? _parseDate(dynamic v) {
        if (v == null) return null;
        try {
          return DateTime.parse(v.toString());
        } catch (_) {
          return null;
        }
      }

      double _toDouble(dynamic v) {
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      // id could be numeric or string
      final idVal = json['id'] ?? json['shipmentId'] ?? json['orderId'] ?? '';
      final idStr = idVal == null ? '' : idVal.toString();

      // orderId prefer explicit orderId field
      final orderIdVal = json['orderId'] ?? json['order_id'] ?? idStr;

      // userId
      int? parseInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        return int.tryParse(v.toString());
      }

      final userId = parseInt(json['userId'] ?? json['user_id']);
      final driverId = parseInt(json['driverId'] ?? json['driver_id']);
      final vehicleId = parseInt(json['vehicleId'] ?? json['vehicle_id']);

      final vehicleType = (json['vehicleType'] ?? json['vehicle_type'] ?? '').toString();

      final images = (json['images'] is List) ? List<dynamic>.from(json['images'] as List) : <dynamic>[];

      final collectTime = CollectTime.fromJson(json['collectTime'] ?? json['collect_time']);

      final pickup = LocationInfo.fromJson(json['pickup']);
      final dropoff = LocationInfo.fromJson(json['dropoff']);

      final weight = (json['weight'] ?? '').toString();
      final notes = (json['notes'] ?? '').toString();

      final estimate = Estimate.fromJson(json['estimate']);

      final invoiceNumber = (json['invoiceNumber'] ?? json['invoice_number'] ?? 'N/A').toString();

      final statusStr = (json['status'] ?? 'pending').toString();
      final initialStatus = parseStatus(statusStr);

      final paymentStatus = (json['paymentStatus'] ?? json['payment_status'] ?? 'pending').toString();
      final paymentMethod = (json['paymentMethod'] ?? json['payment_method'] ?? '').toString();

      final estimatedCost = _toDouble(json['estimatedCost'] ?? json['estimated_cost'] ?? (json['pricing']?['amount'] ?? 0.0));

      final pricing = Pricing.fromJson(json['pricing']);

      final updatedAt = _parseDate(json['updatedAt'] ?? json['updated_at']);
      final createdAt = _parseDate(json['createdAt'] ?? json['created_at']);
      final deliveredAt = _parseDate(json['deliveredAt'] ?? json['delivered_at']);

      final driverDetails = (json['driverDetails'] ?? json['driver_details']) is Map ? Map<String, dynamic>.from(json['driverDetails'] ?? json['driver_details']) : null;

      final stripePaymentIntentId = (json['stripePaymentIntentId'] ?? json['stripe_payment_intent_id'])?.toString();
      final clientSecret = (json['clientSecret'] ?? json['client_secret'])?.toString();

      final reference = (json['reference'] ?? '').toString();

      return OrderModel(
        id: idStr,
        orderId: orderIdVal?.toString() ?? '',
        userId: userId,
        vehicleType: vehicleType,
        images: images,
        collectTime: collectTime,
        pickup: pickup,
        dropoff: dropoff,
        weight: weight,
        notes: notes,
        estimate: estimate,
        invoiceNumber: invoiceNumber,
        initialStatus: initialStatus,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        estimatedCost: estimatedCost,
        pricing: pricing,
        updatedAt: updatedAt,
        createdAt: createdAt,
        reference: reference.isEmpty ? null : reference,
        driverId: driverId,
        vehicleId: vehicleId,
        driverDetails: driverDetails,
        stripePaymentIntentId: stripePaymentIntentId,
        clientSecret: clientSecret,
        deliveredAt: deliveredAt,
      );
    } catch (e) {
      // If anything goes wrong, return a minimal safe OrderModel
      return OrderModel(
        id: '',
        orderId: '',
        userId: null,
        vehicleType: '',
        images: <dynamic>[],
        collectTime: CollectTime(type: 'unknown'),
        pickup: LocationInfo(name: 'N/A', phone: 'N/A', address: 'Unknown'),
        dropoff: LocationInfo(name: 'N/A', phone: 'N/A', address: 'Unknown'),
        weight: '',
        notes: '',
        estimate: null,
        invoiceNumber: 'N/A',
        initialStatus: OrderStatus.Pending,
        paymentStatus: 'pending',
        paymentMethod: '',
        estimatedCost: 0.0,
      );
    }


  }

  // Helper to parse a list response (handles { "shipments": [ ... ] } or List payloads)
  static List<OrderModel> listFromApi(dynamic raw) {
    try {
      if (raw == null) return <OrderModel>[];

      if (raw is String) {
        final decoded = jsonDecode(raw);
        return OrderModel.listFromApi(decoded);
      }

      if (raw is Map && raw.containsKey('shipments') && raw['shipments'] is List) {
        final list = raw['shipments'] as List;
        return list.map((e) => OrderModel.fromJson(e)).toList();
      }

      if (raw is List) {
        return (raw as List).map((e) => OrderModel.fromJson(e)).toList();
      }

      // fallback: if it's a single shipment-like map
      if (raw is Map) {
        return [OrderModel.fromJson(raw)];
      }

      return <OrderModel>[];
    } catch (e) {
      return <OrderModel>[];
    }
  }

  static OrderStatus parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return OrderStatus.Created;
      case 'assigned':
        return OrderStatus.Assigned;
      case 'accepted':
        return OrderStatus.Accepted;
      case 'in_transit':
      case 'in-transit':
      case 'intransit':
      case 'intransit':
        return OrderStatus.InTransit;
      case 'delivered':
        return OrderStatus.Delivered;
      case 'rejected':
      case 'declined':
      case 'rejected_by_driver':
      case 'cancelled':
      case 'canceled':
        return OrderStatus.Declined;
      case 'pending':
      default:
        return OrderStatus.Pending;
    }
  }

  /// Example helper to get a simple human readable pickup address lines
  String get pickupAddressLine1 {
    final parts = pickup.address.split(',');
    return parts.isNotEmpty ? parts[0].trim() : pickup.address;
  }

  String get pickupAddressLine2 {
    final parts = pickup.address.split(',');
    return parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
  }

  String get dropoffAddressLine1 {
    final parts = dropoff.address.split(',');
    return parts.isNotEmpty ? parts[0].trim() : dropoff.address;
  }

  String get dropoffAddressLine2 {
    final parts = dropoff.address.split(',');
    return parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
  }
}
