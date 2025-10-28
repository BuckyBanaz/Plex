class ApiEndpoint {
  static const baseUrl = "https://node-plex-backend-5ca6.onrender.com/";
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



  static const shipment = "/shipments";
  static const estimateShipment = "$shipment/estimate";
  static const createShipment = "$shipment/create";
}