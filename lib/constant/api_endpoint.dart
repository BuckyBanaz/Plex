class ApiEndpoint {
  static const baseUrl = "http://p2dev10.in";
  static const login = "/login";
  static const forgotPassword = "/forgot-password";
  static const individualSignup = "/individual";
  static const driverSignup = "/driver";
  static const corporateSignup = "/corporate";
  static const guestSignup = "/guest";
  static const verifyOtp = "/verify-otp";
  static const resendOtp = '/resend-otp';
  static const resendSms = "/verify-otp";
  static const refreshToken = "/refresh-token";
  static const location = "/location";
  static const userAddress = "/address";
  static const fcmToken = "/update-fcm";
  static const updateStatus = "/update-online-status";

  //
  static const shipment = "/shipments";
  static const estimateShipment = "$shipment/estimate";
  static const createShipment = "$shipment/create";
  static const getShipments = '/shipments';
  static const acceptShipment = '/shipments/:id/accept';
  static const rejectShipment = '/shipments/:id/reject';

}