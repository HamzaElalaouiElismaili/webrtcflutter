import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'peer_connection.dart';

class Connection extends PeerConnection {
  String? userId;
  String? connectionType;
  String? name;
  bool? videoEnabled = true;
  bool? audioEnabled = true;

  Connection({
    this.userId,
    this.connectionType,
    this.name,
    this.audioEnabled,
    this.videoEnabled,
    MediaStream? stream,
  }) : super(localStream: stream);

  void toggleVideo(bool val) {
    videoEnabled = val;
  }

  void toggleAudio(bool val) {
    audioEnabled = val;
  }



}
//List<Connection> connections = [Connection()];
