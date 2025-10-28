part of 'app_service_imports.dart';



class DatabaseService {

  final _preferenceKeys = PreferenceKeys();

  // Obtain shared preferences.
  late final SharedPreferences prefs ;

  Future<DatabaseService> init() async {
    prefs = await SharedPreferences.getInstance();
    debugPrint('Database service is initialized');
    return this;
  }

  Future<void> putIntPref(key, value) async {
    // Save an integer value to 'counter' key.
    await prefs.setInt(key, value);
  }

  Future<void> putBoolPref(key, value) async {
    // Save an boolean value to 'repeat' key.
    await prefs.setBool(key, value);
  }

  Future<void> putDoublePref(key, value) async {
    // Save an double value to 'decimal' key.
    await prefs.setDouble(key, value);
  }

  Future<void> putStringPref(key, value) async {
    // Save an String value to 'action' key.
    await prefs.setString(key, value);
  }

  Future<void> putStringListPref(key, List<String> list) async {
    // Save an list of strings to 'items' key.
    await prefs.setStringList(key, list);
  }

  bool? getBoolPref(key) { return prefs.getBool(key); }

  int? getIntPref(key) { return prefs.getInt(key); }

  double? getDoublePref(key) { return prefs.getDouble(key); }

  String? getStringPref(key) { return prefs.getString(key); }

  List<String>? getStringListPref(key) { return prefs.getStringList(key); }

  bool checkKeyPref(key) {  return prefs.containsKey(key); }

  Future<bool> clearPreference() async { return await prefs.clear(); }

  Future<void> putCustomServerURL(String? value) async => await putStringPref(_preferenceKeys.customServerURL, value);
  String? get customServerURL => getStringPref(_preferenceKeys.customServerURL);

  Future<void> putCustomAccessToken(String? value) async => await putStringPref(_preferenceKeys.customAccessToken, value);
  String? get customAccessToken => getStringPref(_preferenceKeys.customAccessToken);

  Future<void> putHasAcceptedTerms(bool value) async => await putBoolPref(_preferenceKeys.hasAcceptedTerms, value);
  bool? get hasAcceptedTerms => getBoolPref(_preferenceKeys.hasAcceptedTerms);

  Future<void> putIsSignedIn(bool value) async => await putBoolPref(_preferenceKeys.isSignedIn, value);
  bool? get isSignedIn => getBoolPref(_preferenceKeys.isSignedIn);

  Future<void> putAccessToken(String value) async => await putStringPref(_preferenceKeys.accessToken, value);
  String? get accessToken => getStringPref(_preferenceKeys.accessToken) ;
  Future<void> putApiKey(String value) async => await putStringPref(_preferenceKeys.apiKey, value);
  String? get apiKey => getStringPref(_preferenceKeys.apiKey) ;

  Future<void> putUser(UserModel value) async => await putStringPref(_preferenceKeys.user, value.toRawJson());
  UserModel? get user => getStringPref(_preferenceKeys.user) == null ? null : UserModel.fromRawJson(getStringPref(_preferenceKeys.user)!);


  Future<void> putDriver(DriverUserModel value) async => await putStringPref(_preferenceKeys.driver, value.toRawJson());
  DriverUserModel? get driver => getStringPref(_preferenceKeys.driver) == null ? null : DriverUserModel.fromRawJson(getStringPref(_preferenceKeys.driver)!);
  Future<void> putUserType(String? value) async => await putStringPref(_preferenceKeys.userType, value);
  String? get userType => getStringPref(_preferenceKeys.userType);
  Future<void> putIsLocationScreenShown(bool value) async => await putBoolPref(_preferenceKeys.isLocationScreenShown, value);
  bool? get isLocationScreenShown => getBoolPref(_preferenceKeys.isLocationScreenShown) ;

  Future<void> putLastKnownLocation(String value) async => await putStringPref(_preferenceKeys.lastKnownLocation, value);
  String? get lastKnownLocation => getStringPref(_preferenceKeys.lastKnownLocation);

  Future<void> putIsLogin(bool value) async => await putBoolPref(_preferenceKeys.isLogin, value);
  bool? get isLogin => getBoolPref(_preferenceKeys.isLogin) ;

  Future<void> putSkipLogin(bool value) async => await putBoolPref(_preferenceKeys.skipLogin, value);
  bool? get skipLogin => getBoolPref(_preferenceKeys.skipLogin);

}

