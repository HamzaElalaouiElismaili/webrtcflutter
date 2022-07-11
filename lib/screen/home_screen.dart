import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../models/meeting_detail.dart';
import '../service/meeting_api.dart';
import '../widget/button.dart';
import 'dart:convert';

import 'join_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void goToJoinScreen({required MeetingDetail meetingDetail})
  {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => JoinScreen(
          meetingDetail: meetingDetail,
        ),
      ),
    );
  }

  void validateMeeting(String meetingId) async {
    try {
      Response response = await joinMeeting(meetingId);
      var data = json.decode(response.body);
      final meetingDetail = MeetingDetail.fromJson(data["data"]);
     // log('meetingDetail $meetingDetail');
      goToJoinScreen(meetingDetail: meetingDetail);
    } catch (err) {
      const snackbar = SnackBar(content: Text('Invalid MeetingId'));
      scaffoldKey.currentState!.showSnackBar(snackbar);
      log(err.toString());
    }
  }

  void joinMeetingClick() async {
    final meetingId = controller.text;
    log('Joined meeting $meetingId');
    validateMeeting(meetingId);
   }

  void startMeetingClick() async
  {
    log("data");
    var response = await startMeeting();
    log("data");

    final body = json.decode(response!.body);
    final meetingId = body['data'];
    log('Started meeting $meetingId');
    validateMeeting(meetingId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 40.0),
                child: const Text(
                  "Welcome to Meet ",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 32.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter the Meeting Id',
                    hintStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Button(
                text: "Join Meeting",
                onPressed: joinMeetingClick,
              ),
              Button(
                text: "Start Meeting",
                onPressed: startMeetingClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
