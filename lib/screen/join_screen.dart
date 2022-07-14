
import 'package:flutter/material.dart';

import '../models/meeting_detail.dart';
import '../widget/button.dart';
import 'meeting_screen.dart';

class JoinScreen extends StatefulWidget {
   MeetingDetail meetingDetail;

  JoinScreen({Key? key, required this.meetingDetail}) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void join()
  {
    var name = textEditingController.text;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context)
        {
          return MeetingScreen(
            sharingScreen: false,
        name: name,
        meetingDetail: widget.meetingDetail,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
            ),
            Button(
              text: "Join",
              onPressed: join,
            ),
          ],
        ),
      ),
    );
  }
}
