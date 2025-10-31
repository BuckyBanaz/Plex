class ApiEndpoint {
  static const baseUrl = "http://35.154.158.173:3000/";
  static const login = "/login";
  static const individualSignup = "/individual";
  static const driverSignup = "/driver";
  static const corporateSignup = "/corporate";
  static const guestSignup = "/guest";
  static const verifyOtp = "/verify-otp";
  static const resendOtp = "/sms/send-otp";
  static const resendSms = "/verify-otp";
  static const refreshToken = "/refresh-token";
  static const location = "/location";

  //
  static const shipment = "/shipments";
  static const estimateShipment = "$shipment/estimate";
  static const createShipment = "$shipment/create";
}