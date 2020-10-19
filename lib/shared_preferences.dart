import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static final String _kSliderCode = "language";
  static final String _kLoginCode = "login_success";
  static final String _kEmailCode = "email";
  static final String _kPasswordCode = "password";
  static final String _kUsernameCode = "username";
  static final String _kUserIdCode = "user_id";
  static final String _kSoundCode = "sound_onoff";
  static final String _kTrafficCode = "traffic_onoff";
  static final String _kTodayCircuit = "today_circuit";
  static final String _kRouteIdCode = "route_id";
  static final String _kPanicEnabled = "panic_onoff";

  static Future<bool> getSliderCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSliderCode) ?? false;
  }

  static Future<bool> setSliderCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kSliderCode, true);
  }

  static Future<bool> getLoginCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoginCode) ?? false;
  }

  static Future<bool> setLoginCode(bool flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kLoginCode, flag);
  }

  static Future<String> getEmailCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmailCode) ?? "";
  }

  static Future<bool> setEmailCode(String _email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kEmailCode, _email);
  }

  static Future<String> getPasswordCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPasswordCode) ?? "";
  }

  static Future<bool> setPasswordCode(String _password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kPasswordCode, _password);
  }

  static Future<String> getUsernameCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsernameCode) ?? "";
  }

  static Future<bool> setUsernameCode(String _username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kUsernameCode, _username);
  }

  static Future<String> getUserIdCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserIdCode) ?? "";
  }

  static Future<bool> setUserIdCode(String _userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kUserIdCode, _userId);
  }

  static Future<bool> getSoundCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoundCode) ?? true;
  }

  static Future<bool> setSoundCode(bool flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kSoundCode, flag);
  }

  static Future<bool> getTrafficCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kTrafficCode) ?? true;
  }

  static Future<bool> setTrafficCode(bool flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kTrafficCode, flag);
  }

  static Future<int> getTodayCircuit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTodayCircuit) ?? 0;
  }

  static Future<bool> setTodayCircuit(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_kTodayCircuit, value);
  }

  static Future<String> getRouteIdCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRouteIdCode) ?? "";
  }

  static Future<bool> setRouteIdCode(String _routeId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kRouteIdCode, _routeId);
  }

  static Future<bool> getPanicFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPanicEnabled) ?? true;
  }

  static Future<bool> setPanicFlag(bool flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kPanicEnabled, flag);
  }

}