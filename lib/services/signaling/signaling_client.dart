import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants.dart';
import '../../core/logger.dart';

class SignalingClient {
  SignalingClient._();
  static final SignalingClient _instance = SignalingClient._();
  static SignalingClient get instance => _instance;

  final _logger = AppLogger.instance;
  io.Socket? _socket;

  String? _currentRoomId;

  final _onOfferController = StreamController<Map<String, dynamic>>.broadcast();
  final _onAnswerController = StreamController<Map<String, dynamic>>.broadcast();
  final _onIceController = StreamController<Map<String, dynamic>>.broadcast();
  final _onRoomMetaController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOfferStream => _onOfferController.stream;
  Stream<Map<String, dynamic>> get onAnswerStream => _onAnswerController.stream;
  Stream<Map<String, dynamic>> get onIceCandidateStream => _onIceController.stream;

  void Function(Map<String, dynamic>)? onOffer;
  void Function(Map<String, dynamic>)? onAnswer;
  void Function(Map<String, dynamic>)? onIceCandidate;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> initialize() async {
    _logger.i('SignalingClient initialized');
  }

  void connect() {
    if (_socket != null && _socket!.connected) return;
    final url = AppConstants.signalingServerUrl;
    _socket = io.io(url, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      _logger.i('Signaling connected');
    });

    _socket!.on('webrtc-offer', (data) {
      onOffer?.call(data);
      _onOfferController.add(data);
    });

    _socket!.on('webrtc-answer', (data) {
      onAnswer?.call(data);
      _onAnswerController.add(data);
    });

    _socket!.on('webrtc-ice-candidate', (data) {
      onIceCandidate?.call(data);
      _onIceController.add(data);
    });

    _socket!.on('room-metadata', (data) {
      _onRoomMetaController.add(data);
    });

    _socket!.on('receiver-joined', (_) {
      _logger.i('Receiver joined room');
    });

    _socket!.on('transfer-complete', (_) {
      _logger.i('Transfer complete signaled');
    });

    _socket!.on('transfer-cancel', (_) {
      _logger.i('Transfer cancelled signaled');
    });

    _socket!.onDisconnect((_) {
      _logger.i('Signaling disconnected');
    });

    _socket!.onError((err) {
      _logger.e('Signaling error', e: err);
    });
  }

  Future<String?> createRoom() async {
    connect();
    await _waitForConnection();
    final completer = Completer<String?>();
    _socket!.emitWithAck('create-room', {}, ack: (res) {
      if (res is Map && res['success'] == true) {
        _currentRoomId = res['roomId'] as String?;
        completer.complete(_currentRoomId);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  Future<bool> joinRoom(String roomId) async {
    connect();
    await _waitForConnection();
    final completer = Completer<bool>();
    _socket!.emitWithAck('join-room', {'roomId': roomId}, ack: (res) {
      if (res is Map) {
        completer.complete(res['success'] == true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  Future<void> sendOffer(String sdp) async {
    _socket?.emit('webrtc-offer', {'roomId': _currentRoomId, 'offer': sdp});
  }

  Future<void> sendAnswer(String sdp) async {
    _socket?.emit('webrtc-answer', {'roomId': _currentRoomId, 'answer': sdp});
  }

  Future<void> sendIceCandidate(Map<String, dynamic> candidate) async {
    _socket?.emit('webrtc-ice-candidate', {'roomId': _currentRoomId, 'candidate': candidate});
  }

  Future<void> sendRoomMetadata(Map<String, dynamic> metadata) async {
    _socket?.emit('room-metadata', {'roomId': _currentRoomId, 'metadata': metadata});
  }

  Future<void> _waitForConnection() async {
    int retries = 20;
    while ((_socket == null || !_socket!.connected) && retries > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries--;
    }
  }

  Future<List<Map<String, dynamic>>> fetchIceServers() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('${AppConstants.signalingServerUrl}/ice-config'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final servers = data['iceServers'] as List<dynamic>;
      return servers.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.e('Fetch ICE servers failed', e: e);
      return [{'urls': 'stun:stun.l.google.com:19302'}];
    }
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
    _currentRoomId = null;
    _logger.i('Signaling disconnected');
  }
}
