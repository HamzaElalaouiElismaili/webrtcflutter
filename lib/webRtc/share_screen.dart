

import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class ScreenSharing {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  Future<void> makeScreenSharing() async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    try {
      MediaStream? _localStream;
      final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

      var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);

      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      log(e.toString());
    }
  }
}