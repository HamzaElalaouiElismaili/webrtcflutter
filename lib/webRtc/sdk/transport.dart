import 'dart:async';
import 'package:eventify/eventify.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Transport extends EventEmitter {
  String? url;
  bool? canReconnect = false;
  int retryCount = 0;
  int? maxRetryCount = 1;
  Timer? timer;
  bool closed = false;
  IO.Socket? socket;

  Transport({this.url, this.canReconnect, this.maxRetryCount});

  void connect() async {
    try {
      if (retryCount <= maxRetryCount!) {
        retryCount++;
        socket = IO.io(url, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
        });

        print(url);

        socket!.connect();
        socket!.onConnect((data) => {print('Connect: ${socket!.id}')});
        listenEvents();
      } else {
        emit('failed');
      }
    } catch (error) {
      print(error);
      connect();
    }
  }

  void listenEvents() {
    socket!.on("message", handleMessage);
    // socket.on("update-user-list", (data) => {print(data)});
    handleOpen();
  }

  void remoteEvents() {}

  void handleOpen() {
    sendHeartbeat();
    emit('open');
  }

  void handleMessage(dynamic data) {
    print('handleMessage: $data');
    emit('message', null, data);
  }

  void handleClose() {
    reset();
    if (!closed) {
      connect();
    }
  }

  void handleError(Object error) {
    print(error);
    reset();
    if (!closed) {
      connect();
    }
  }

  void send(dynamic data) {
    socket!.emit("message", data);
  }

  void sendHeartbeat() {
    // timer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   send(json.encode({'type': 'heartbeat'}));
    // });
  }

  void reset() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
  }

  void close() {
    closed = true;
    destroy();
  }

  void destroy() {
    reset();
    url = '';
  }

  void reconnect() {
    retryCount = 0;
    connect();
  }
}
