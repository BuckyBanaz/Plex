// file: models/order_model.dart

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

  factory CollectTime.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CollectTime(type: 'unknown');
    DateTime? dt;
    try {
      if (json['scheduledAt'] != null) dt = DateTime.parse(json['scheduledAt']);
    } catch (_) {
      dt = null;
    }
    return CollectTime(type: json['type'] ?? 'unknown', scheduledAt: dt);
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

  factory LocationInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LocationInfo(name: 'N/A', phone: 'N/A', address: 'Unknown');
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
      name: json['name'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      address: json['address'] ?? 'Unknown',
      latitude: _lat,
      longitude: _lng,
    );
  }
}

class PriceBreakdown {
  final double tax;
  final double baseFare;
  final double distanceFare;

  PriceBreakdown({required this.tax, required this.baseFare, required this.distanceFare});

  factory PriceBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PriceBreakdown(tax: 0.0, baseFare: 0.0, distanceFare: 0.0);
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return PriceBreakdown(
      tax: _toDouble(json['tax']),
      baseFare: _toDouble(json['baseFare']),
      distanceFare: _toDouble(json['distanceFare']),
    );
  }
}

class Pricing {
  final double amount;
  final String currency;
  final int? distanceMeters;
  final PriceBreakdown? priceBreakdown;

  Pricing({required this.amount, required this.currency, this.distanceMeters, this.priceBreakdown});

  factory Pricing.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Pricing(amount: 0.0, currency: 'INR');
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Pricing(
      amount: _toDouble(json['amount'] ?? json['estimatedCost'] ?? 0.0),
      currency: json['currency'] ?? 'INR',
      distanceMeters: json['distanceMeters'] is int ? json['distanceMeters'] : (json['distanceMeters'] != null ? int.tryParse(json['distanceMeters'].toString()) : null),
      priceBreakdown: PriceBreakdown.fromJson(json['priceBreakdown'] as Map<String, dynamic>? ),
    );
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

  factory Estimate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Estimate(estimatedCostINR: 0.0, estimatedCostUSD: 0.0, distanceKm: 0.0, durationText: '', currency: 'INR');
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Estimate(
      estimatedCostINR: _toDouble(json['estimatedCostINR'] ?? json['estimatedCostINR'] ?? json['estimatedCost'] ?? 0.0),
      estimatedCostUSD: _toDouble(json['estimatedCostUSD'] ?? json['estimatedCostUSD'] ?? 0.0),
      distanceKm: _toDouble(json['distanceKm'] ?? json['distanceKm'] ?? 0.0),
      durationText: json['durationText'] ?? '',
      currency: json['currency'] ?? 'INR',
    );
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
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

    return OrderModel(
      id: (json['shipment']?['id'] ?? json['id'] ?? '').toString(),
      orderId: (json['shipment']?['orderId'] ?? json['orderId'] ?? json['orderId']).toString(),
      userId: json['shipment']?['userId'] is int ? json['shipment']!['userId'] as int : (json['userId'] is int ? json['userId'] as int : null),
      vehicleType: json['shipment']?['vehicleType'] ?? json['vehicleType'] ?? '',
      images: (json['shipment']?['images'] ?? json['images'] ?? []) as List<dynamic>,
      collectTime: CollectTime.fromJson((json['shipment']?['collectTime'] ?? json['collectTime']) as Map<String, dynamic>?),
      pickup: LocationInfo.fromJson((json['shipment']?['pickup'] ?? json['pickup']) as Map<String, dynamic>?),
      dropoff: LocationInfo.fromJson((json['shipment']?['dropoff'] ?? json['dropoff']) as Map<String, dynamic>?),
      weight: (json['shipment']?['weight'] ?? json['weight'] ?? '').toString(),
      notes: (json['shipment']?['notes'] ?? json['notes'] ?? '').toString(),
      estimate: Estimate.fromJson((json['shipment']?['estimate'] ?? json['estimate']) as Map<String, dynamic>?),
      invoiceNumber: (json['shipment']?['invoiceNumber'] ?? json['invoiceNumber'] ?? json['shipment']?['invoiceNumber'] ?? 'N/A').toString(),
      initialStatus: parseStatus((json['shipment']?['status'] ?? json['status'] ?? 'pending').toString()),
      paymentStatus: (json['shipment']?['paymentStatus'] ?? json['paymentStatus'] ?? 'pending').toString(),
      paymentMethod: (json['shipment']?['paymentMethod'] ?? json['paymentMethod'] ?? '').toString(),
      estimatedCost: _toDouble(json['shipment']?['estimatedCost'] ?? json['estimatedCost'] ?? (json['shipment']?['pricing']?['amount'] ?? 0.0)),
      pricing: Pricing.fromJson((json['shipment']?['pricing'] ?? json['pricing']) as Map<String, dynamic>?),
      updatedAt: _parseDate(json['shipment']?['updatedAt'] ?? json['updatedAt']),
      createdAt: _parseDate(json['shipment']?['createdAt'] ?? json['createdAt']),
      reference: json['shipment']?['reference'] ?? json['reference'],
      driverId: json['shipment']?['driverId'] is int ? json['shipment']!['driverId'] as int : (json['driverId'] is int ? json['driverId'] as int : null),
      vehicleId: json['shipment']?['vehicleId'] is int ? json['shipment']!['vehicleId'] as int : (json['vehicleId'] is int ? json['vehicleId'] as int : null),
      driverDetails: (json['shipment']?['driverDetails'] ?? json['driverDetails']) as Map<String, dynamic>?,
      stripePaymentIntentId: (json['shipment']?['stripePaymentIntentId'] ?? json['stripePaymentIntentId'])?.toString(),
      clientSecret: (json['shipment']?['clientSecret'] ?? json['clientSecret'])?.toString(),
      deliveredAt: _parseDate(json['shipment']?['deliveredAt'] ?? json['deliveredAt']),
    );
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
