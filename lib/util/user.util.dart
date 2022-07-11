import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

var uuid = const Uuid();

Future<String?> loadUserId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? userId;
  if (preferences.containsKey('userId'))
  {
    userId = preferences.getString('userId');
  } else {
    userId = uuid.v4();
    preferences.setString('userId', userId);
  }
  return userId;
}