import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../util/user.util.dart';


const String ip = '192.168.242.121' ;
const String MEETING_API_URL = 'http://$ip:6000/api/meeting';
const String URL_MEETING = 'http://$ip:5000';


/*Future<http.Response> startMeeting() async {
  var userId = await loadUserId();
  var response =
  await http.post(Uri.parse('$MEETING_API_URL/start'), body: {'userId': userId});
  return response;
}*/


Future<http.Response?> startMeeting() async
{
  Map<String,String> requestHeaders =
  {
    "Content-Type": "application/json"
  };
  var userId = await loadUserId();
  log(userId.toString());
  var response = await http.post(
      Uri.parse('$MEETING_API_URL/start'),
      headers: requestHeaders,
      body:

        jsonEncode(
            {
              'hostId': userId,
              'hostName':""
            }),
      );

  log(response.body);
  if(response.statusCode == 200)
  {
    return response;

  }
  else
    {
      log("No Response on Staring Meeting");
      return null;
    }
}


Future<http.Response> joinMeeting(String meetingId) async
{
  var response = await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));
  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }
  throw UnsupportedError('Not a valid meeting');
}
