import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnection extends EventEmitter {
  MediaStream? localStream;
  MediaStream? remoteStream;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  RTCPeerConnection? rtcPeerConnection;

  PeerConnection({this.localStream});

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        "urls": [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302'
        ],
      }
    ]
  };
  final Map<String, dynamic> loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  Future<void> start() async {
    rtcPeerConnection = await createPeerConnection(configuration, loopbackConstraints);
    rtcPeerConnection!.addStream(localStream!);
    rtcPeerConnection!.onAddStream = _onAddStream;
    rtcPeerConnection!.onRemoveStream = _onRemoveStream;
    rtcPeerConnection!.onRenegotiationNeeded = _onRenegotiationNeeded;
    rtcPeerConnection!.onIceCandidate = _onIceCandidate;
    await renderer.initialize();
    emit('connected');
  }

  void _onAddStream(MediaStream stream) {
    remoteStream = stream;
    renderer.srcObject = stream;
    //renderer.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
    emit('stream-changed');
  }

  void _onRemoveStream(MediaStream stream) {
    remoteStream = null;
  }

  void _onRenegotiationNeeded() {
    print('negotiationneeded');
    emit('negotiationneeded');
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    emit('candidate', null, candidate);
  }

  Future<RTCSessionDescription?> createOffer() async {
    try {
      final RTCSessionDescription sdp =
          await rtcPeerConnection!.createOffer(offerSdpConstraints);
      await rtcPeerConnection!.setLocalDescription(sdp);
      return sdp;
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<void> setOfferSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection!.setRemoteDescription(sdp);
    }
  }

  Future<RTCSessionDescription> createAnswer() async {
    final RTCSessionDescription sdp =
        await rtcPeerConnection!.createAnswer(offerSdpConstraints);
    await rtcPeerConnection!.setLocalDescription(sdp);
    return sdp;
  }

  Future<void> setAnswerSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection!.setRemoteDescription(sdp);
    }
  }

  Future<void> setCandidate(RTCIceCandidate candidate) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection!.addCandidate(candidate);
    }
  }

  void close() {
    if (rtcPeerConnection != null) {
      rtcPeerConnection!.close();
      rtcPeerConnection = null;
    }
    renderer.dispose();
    localStream = null;
    remoteStream = null;
  }
}
