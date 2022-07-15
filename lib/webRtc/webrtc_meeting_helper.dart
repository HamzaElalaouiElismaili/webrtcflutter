import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'sdk/connection.dart';
import 'sdk/message_payload.dart';
import 'sdk/payload_data.dart';
import 'sdk/transport.dart';

class WebRTCMeetingHelper extends EventEmitter {
  String? url;
  Transport? transport;
  String? meetingId;
  List<Connection> connections = [];
  bool joined = false;
  bool connected = false;
  MediaStream? stream;
  String? userId;
  String? name;
  bool? videoEnabled = true;
  bool? audioEnabled = true;
  int? maxRetryCount;
  bool? autoConnect;

  WebRTCMeetingHelper({
    this.url,
    this.meetingId,
    this.userId,
    this.name,
    this.stream,
    this.maxRetryCount = 3,
    this.autoConnect = true,
  }) {
    transport = Transport(
      url: formatUrl(meetingId!),
      maxRetryCount: maxRetryCount,
      canReconnect: autoConnect,
    );

    listenMessage();
  }

  String formatUrl(String id) {
    return '$url?id=$id';
  }

  MessagePayload parseMessage(dynamic data) {
    try {
      return MessagePayload.fromJson(json.decode(data));
    } catch (error) {
      return MessagePayload(type: 'unknown');
    }
  }

  void sendMessage(String type, dynamic data) {
    try {
      final String payload = json.encode({'type': type, 'data': data});

      if (transport != null) {
        transport!.send(payload);
      }
    } catch (error) {
      print(error);
    }
  }

  void listenMessage() {
    if (transport != null) {
      transport!.on('open', null, (ev, context) {
        connected = true;
        print(ev.eventName);
        join();
      });
      transport!.on('message', null, (ev, context) {
        //print("listenMessage: " + ev.eventData);
        final payload = parseMessage(ev.eventData);
        handleMessage(payload);
      });
      transport!.on('closed', null, (ev, context) {
        connected = false;
      });
      transport!.on('failed', null, (ev, context) {
        reset();
        emit('failed');
      });

      transport!.connect();
    }
  }

  Connection getConnection(String userId) {
    return connections.firstWhere((connection) => connection.userId == userId);
  }

  Future<Connection?>? createConnection(UserJoinedData data) async {
    if (stream != null) {
      final connection = Connection(
        connectionType: 'incoming',
        userId: data.userId,
        name: data.name,
        stream: stream,
        audioEnabled: data.config!.audioEnabled,
        videoEnabled: data.config!.videoEnabled,
      );
      connection.on('connected', null, (ev, context) {
        print('rtp connected');
      });
      connection.on('candidate', null, (ev, context) {
        sendIceCandidate(connection.userId!, ev.eventData as RTCIceCandidate);
      });
      connection.on('stream-changed', null, (ev, context) {
        emit('stream-changed');
      });
      connections.add(connection);
      await connection.start();
      emit('connection', null, connection);
      return connection;
    }
    return null;
  }

  void join() {
    sendMessage('join-meeting', {
      'name': name,
      'userId': userId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void joinedMeeting(JoinedMeetingData data) {
    joined = true;
    userId = data.userId;
  }

  void userJoined(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendConnectionRequest(connection.userId!);
    }
  }

  void sendIceCandidate(String otherUserId, RTCIceCandidate candidate) {
    sendMessage('icecandidate', {
      'userId': userId,
      'otherUserId': otherUserId,
      'candidate': candidate.toMap(),
    });
  }

  void sendConnectionRequest(String otherUserId) {
    sendMessage('connection-request', {
      'name': name,
      'userId': userId,
      'otherUserId': otherUserId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void receivedConnectionRequest(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendOfferSdp(data.userId!);
    }
  }

  void sendOfferSdp(String otherUserId) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      final sdp = await connection.createOffer();
      sendMessage('offer-sdp', {
        'userId': userId,
        'otherUserId': otherUserId,
        'sdp': sdp!.toMap(),
      });
    }
  }

  void receivedOfferSdp(OfferSdpData data) {
    sendAnswerSdp(data.userId!, data.sdp!);
  }

  void sendAnswerSdp(String otherUserId, RTCSessionDescription sdp) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      await connection.setOfferSdp(sdp);
      final answerSdp = await connection.createAnswer();
      sendMessage('answer-sdp', {
        'userId': userId,
        'otherUserId': otherUserId,
        'sdp': answerSdp.toMap(),
      });
    }
  }

  void receivedAnswerSdp(AnswerSdpData data) async {
    final connection = getConnection(data.userId!);
    await connection.setAnswerSdp(data.sdp!);
  }

  void setIceCandidate(IceCandidateData data) async {
    final connection = getConnection(data.userId!);
    await connection.setCandidate(data.candidate!);
  }

  void userLeft(UserLeftData data) {
    final connection = getConnection(data.userId!);
    emit('user-left', null, connection);
    connection.close();
    connections.removeWhere((element) => element.userId == connection.userId);
  }

  void meetingEnded(MeetingEndedData data) {
    emit('meeting-ended');
    destroy();
  }

  void endMeeting() {
    sendMessage('end-meeting', {
      'userId': userId,
    });
    destroy();
  }

  void leave() {
    sendMessage('leave-meeting', {
      'userId': userId,
    });
    destroy();
  }



  bool isFrontCamera = true;

  void switchCamera() async
  {
    if (stream != null) {
      bool value = await  Helper.switchCamera(stream!.getVideoTracks()[0]);
      while (value == isFrontCamera)
      {
        value = await Helper.switchCamera(stream!.getVideoTracks()[0]);
      }
      isFrontCamera = value;
    }

  }

  void shareScreen() async
  {
    if (stream != null)
    {

      navigator.mediaDevices.getDisplayMedia({'video':true,'audio':true}).then((value)
      {
        value = stream!;
        value.addTrack(stream!.getVideoTracks()[0]);
      } );


    }
  }


  bool toggleVideoOff() {
    if (stream != null)
    {
      final videoTrack = stream!.getVideoTracks()[0];
      final bool videoEnabled = videoTrack.enabled = !videoTrack.enabled;
      this.videoEnabled = videoEnabled;

      sendMessage('video-toggle', {
        'userId': userId,
        'videoEnabled': videoEnabled,
      });
      emit('video-toggle', null, {
        'userId': userId,
        'videoEnabled': videoEnabled,
      });
      return videoEnabled;
    }
    return false;
  }

  bool toggleAudio() {
    if (stream != null) {
      final audioTrack = stream!.getAudioTracks()[0];
      final bool audioEnabled = audioTrack.enabled = !audioTrack.enabled;
      this.audioEnabled = audioEnabled;

      sendMessage('audio-toggle', {
        'userId': userId,
        'audioEnabled': audioEnabled,
      });
      emit('audio-toggle', null, {
        'userId': userId,
        'audioEnabled': audioEnabled,
      });
      return audioEnabled;
    }
    return false;
  }

  void listenVideoToggle(VideoToggleData data) {
    final connection = getConnection(data.userId!);
    connection.toggleVideo(data.videoEnabled!);
    emit('connection-setting-changed');
  }

  void listenAudioToggle(AudioToggleData data) {
    final connection = getConnection(data.userId!);
    connection.toggleAudio(data.audioEnabled!);
    emit('connection-setting-changed');
  }

  void handleNotFound() {
    emit('not-found');
  }

  stopStream() {
    if (stream != null) {
      stream!.dispose();
    }
  }

  void handleMessage(MessagePayload payload) {
    switch (payload.type) {
      case 'joined-meeting':
        joinedMeeting(JoinedMeetingData.fromJson(payload.data));
        break;
      case 'user-joined':
        userJoined(UserJoinedData.fromJson(payload.data));
        break;
      case 'connection-request':
        receivedConnectionRequest(UserJoinedData.fromJson(payload.data));
        break;
      case 'offer-sdp':
        receivedOfferSdp(OfferSdpData.fromJson(payload.data));
        break;
      case 'answer-sdp':
        receivedAnswerSdp(AnswerSdpData.fromJson(payload.data));
        break;
      case 'user-left':
        userLeft(UserLeftData.fromJson(payload.data));
        break;
      case 'meeting-ended':
        meetingEnded(MeetingEndedData.fromJson(payload.data));
        break;
      case 'icecandidate': setIceCandidate(IceCandidateData.fromJson(payload.data));
        break;
      case 'video-toggle':
        listenVideoToggle(VideoToggleData.fromJson(payload.data));
        break;
      case 'audio-toggle':
        listenAudioToggle(AudioToggleData.fromJson(payload.data));
        break;
      case 'not-found':
        handleNotFound();
        break;
      default:
        break;
    }
  }




      void destroy() {
        if (transport != null) {
          transport!.destroy();
          transport = null;
        }
        for (var connection in connections) {
          connection.close();
        }
        stopStream();
        connections = [];
        connected = false;
        stream = null;
        joined = false;
      }

      void reset() {
        connections = [];
        joined = false;
        connected = false;
      }

      void reconnect() {
        if (transport != null) {
          transport!.reconnect();
        }
      }
    }



class Session {
  Session({required this.sid, required this.pid});
  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

