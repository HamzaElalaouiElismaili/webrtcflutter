import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../webRtc/sdk/connection.dart';


class RemoteConnection extends StatefulWidget {
  final RTCVideoRenderer renderer;
  final Connection connection;


  RemoteConnection({required this.renderer, required this.connection});

  @override
  _RemoteConnectionState createState() => _RemoteConnectionState();
}

class _RemoteConnectionState extends State<RemoteConnection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          RTCVideoView(
            widget.renderer,
            mirror: false,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,),
          Container(
            color: widget.connection.videoEnabled!
                ? Colors.transparent
                : Colors.black,
            child: Center(
                child: Text(
                  widget.connection.videoEnabled! ? '' : widget.connection.name!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                )),
          ),


          Positioned(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: const Color.fromRGBO(0, 0, 0, 0.7),
              child: Row(
                children: <Widget>[
                  Text(
                    widget.connection.name!,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    widget.connection.videoEnabled!
                        ? Icons.videocam
                        : Icons.videocam_off,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  Icon(
                    widget.connection.audioEnabled! ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            bottom: 10.0,
            right: 10.0,
          )
        ],
      ),
    );
  }
}
