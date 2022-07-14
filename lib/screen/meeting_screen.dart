import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcmeet/webRtc/webrtc_meeting_helper.dart';
import 'package:webrtcmeet/widget/remote_connection.dart';
import '../models/meeting_detail.dart';
import '../screen/home_screen.dart';
import '../service/meeting_api.dart';
import '../util/task.dart';
import '../util/user.util.dart';
import '../widget/control_panel.dart';

class MeetingScreen extends StatefulWidget {
  final String name;
  final String? meetingId;
  final MeetingDetail meetingDetail;
  bool sharingScreen ;

  MeetingScreen(
      {Key? key,
        this.meetingId,
      required this.name,
        required this.sharingScreen,
      required this.meetingDetail})
      : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final _localRenderer = RTCVideoRenderer();

  final Map<String, dynamic> mediaConstraints =
  {
    "audio": true,
    "video": true,
  };

  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  bool isValidMeeting = false;
  TextEditingController textEditingController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isChatOpen = false;
  final PageController pageController = PageController();
  late MediaStream localstream ;

  @override
  void initState()
  {
    super.initState();
    initRenderers();
    startMeeting();
  }

  @override
  deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  initRenderers() async
  {
    await _localRenderer.initialize();

  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          title: 'Home',
        ),
      ),
    );
  }

  void startMeeting() async {
    final String? userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: URL_MEETING,
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );


    localstream =   await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = localstream;
    meetingHelper!.stream = localstream;


    meetingHelper!.on('open', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('connection', context, (ev, context) {

      log("log connection");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('user-left', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on('audio-toggle', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('video-toggle', context, (ev, context) {
      setState(() {
         isConnectionFailed = false;
      });
    });


    meetingHelper!.on('meeting-ended', context, (ev, ctx) {
      onMeetingEnd();
    });

    meetingHelper!.on('connection-setting-changed', context, (ev, ctx) {
      setState(() {
        // isConnectionFailed = false;
      });
    });

    meetingHelper!.on('stream-changed', context, (ev, context) {
      setState(() {
        // isConnectionFailed = false;
      });
    });

    meetingHelper!.on('message', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
        //messages.add(ev.eventData as MessageFormat);
      });
    });




    meetingHelper!.on('failed', context, (ev, context) {
      const snackBar = SnackBar(content: Text('Connection Failed'));
      scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {
        isConnectionFailed = true;
      });
    });

    meetingHelper!.on('not-found', context, (ev, context) {
      meetingEndedEvent();
    });
    setState(() {
      isValidMeeting = false;
    });
  }

  void startMeeting2() async {
    final String? userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: URL_MEETING,
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );


    localstream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    _localRenderer.srcObject = localstream;
    meetingHelper!.stream = localstream;


    meetingHelper!.on('open', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('connection', context, (ev, context) {

      log("log connection");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('user-left', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on('audio-toggle', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('video-toggle', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });


    meetingHelper!.on('meeting-ended', context, (ev, ctx) {
      onMeetingEnd();
    });

    meetingHelper!.on('connection-setting-changed', context, (ev, ctx) {
      setState(() {
        // isConnectionFailed = false;
      });
    });

    meetingHelper!.on('stream-changed', context, (ev, context) {
      setState(() {
        // isConnectionFailed = false;
      });
    });

    meetingHelper!.on('message', context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
        //messages.add(ev.eventData as MessageFormat);
      });
    });




    meetingHelper!.on('failed', context, (ev, context) {
      const snackBar = SnackBar(content: Text('Connection Failed'));
      scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {
        isConnectionFailed = true;
      });
    });

    meetingHelper!.on('not-found', context, (ev, context) {
      meetingEndedEvent();
    });
    setState(() {
      isValidMeeting = false;
    });
  }

  void onMeetingEnd()
  {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHome();
    }
  }

  void meetingEndedEvent()
  {
    const snackBar = SnackBar(content: Text('Meeing Ended'));
    scaffoldKey.currentState!.showSnackBar(snackBar);
    goToHome();
  }

  void exitClick()
  {
    Navigator.of(context).pushReplacementNamed('/');
  }

  void onEnd()
  {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHome();
    }
  }

  void onLeave() {
    if (meetingHelper != null)
    {
      meetingHelper!.leave();
      meetingHelper = null;
      goToHome();
    }
  }

  void onVideoToggle()
  {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideoOff();
      });
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(()
      {
        meetingHelper!.toggleAudio();
      });
    }
  }
  bool  issharingScreen = true ;
  void onScreeSharing()   async
  {
    if(meetingHelper != null)
    {

      if(issharingScreen)
      {
        startMeeting2();

        issharingScreen = !issharingScreen;
      }
      else
        {
        startMeeting();
        issharingScreen = !issharingScreen;
        }


    }
  }

  bool isHost() {
    return meetingHelper != null && widget.meetingDetail != null
        ? meetingHelper!.userId == widget.meetingDetail.hostId
        : false;
  }

  bool isVideoEnabled()
  {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  bool isAudioEnabled()
  {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  void handleReconnect() {
    if (meetingHelper != null)
    {
      meetingHelper!.reconnect();
    }
  }

  void handleChatToggle() {
    setState(() {
      isChatOpen = !isChatOpen;
      //  pageController.jumpToPage(isChatOpen ? 1 : 0);
    });
  }



  Widget _buildMeetingRoom() {
    return Stack(
      children: <Widget>[
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
            crossAxisCount: meetingHelper!.connections.length<3?1:2,
          children: List.generate(meetingHelper!.connections.length, (index)
          {
            return Padding(
                padding:const EdgeInsets.all(5),
              child: RemoteConnection(
                renderer: meetingHelper!.connections[index].renderer,
                connection: meetingHelper!.connections[index],
              ),
            );
          }),
        )
            : const Center(
                child: Text(
                  'Waiting for participants to join the meeting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24.0,
                  ),
                ),
              ),
        Positioned(
          bottom: 10.0,
          right: 0.0,
          child: SizedBox(
            width: 150.0,
            height: 200.0,
            child: RTCVideoView(_localRenderer),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Meet"),
        //actions: _buildActions(),
        backgroundColor: Colors.redAccent,
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: <Widget>[
          _buildMeetingRoom(),


        ],
      ),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        cameraToggle: ()=> meetingHelper!.switchCamera(),
        sharingScreen: onScreeSharing,//()=> meetingHelper!.shareScreen(),
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
       // isChatOpen: isChatOpen,
      ),
    );
  }
}
