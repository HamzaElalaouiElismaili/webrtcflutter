import 'package:flutter/material.dart';

import 'actions_button.dart';

class ControlPanel extends StatelessWidget {
  final bool? videoEnabled;
  final bool? audioEnabled;
  final bool? isConnectionFailed;
  final VoidCallback? cameraToggle;
  final VoidCallback? sharingScreen;
  final VoidCallback? onVideoToggle;
  final VoidCallback? onAudioToggle;
  final VoidCallback? onReconnect;
  final VoidCallback? onMeetingEnd;

  ControlPanel({
     this.onAudioToggle,
     this.onVideoToggle,
     this.videoEnabled,
     this.audioEnabled,
     this.onReconnect,
     this.isConnectionFailed,
     this.onMeetingEnd,
     this.cameraToggle,
     this.sharingScreen,

  });

  List<Widget> buildControls() {
    if (!isConnectionFailed!) {
      return <Widget>[
        IconButton(
          onPressed: onVideoToggle,
          icon: Icon(videoEnabled! ? Icons.videocam : Icons.videocam_off),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(
          onPressed: cameraToggle,
          icon: Icon(videoEnabled! ? Icons.videocam : Icons.toggle_on_sharp),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(
           onPressed: sharingScreen,
          icon: const Icon(Icons.offline_share_sharp),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(
          onPressed: onAudioToggle,
          icon: Icon(audioEnabled! ? Icons.mic : Icons.mic_off),
          color: Colors.white,
          iconSize: 32.0,
        ),
        const SizedBox(width: 25,),
        Container(width: 70,decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.green),child:  IconButton(
          onPressed: onMeetingEnd!,
          icon:const  Icon(Icons.call_end ),
          color: Colors.white,
          iconSize: 32.0,
        ), )
      ];
    } else {
      return <Widget>[
        ActionButton(
          text: 'Reconnect',
          onPressed: onReconnect!,
          color: Colors.green,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    var widgets = buildControls();
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widgets,
      ),
      color: Colors.blueGrey[700],
      height: 60.0,
    );
  }
}
