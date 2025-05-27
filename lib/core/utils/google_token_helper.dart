import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveGoogleAccessToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('google_access_token', token);
}

Future<String?> loadGoogleAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('google_access_token');
}

Future<void> clearGoogleAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('google_access_token');
}