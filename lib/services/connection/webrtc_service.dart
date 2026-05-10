import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/connection_mode.dart';
import '../../models/peer_device.dart';
import '../signaling/signaling_client.dart';

class WebRTCService {
  final _logger = AppLogger.instance;
  final _signaling = SignalingClient.instance;

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  final _connectionStateController = StreamController<RTCIceConnectionState>.broadcast();
  Stream<RTCIceConnectionState> get connectionStateStream => _connectionStateController.stream;

  Future<void> initialize() async {
    _logger.i('WebRTCService initialized');
    _listenToSignaling();
  }

  void _listenToSignaling() {
    _signaling.onOffer = (data) async {
      await _handleOffer(data);
    };
    _signaling.onAnswer = (data) async {
      await _handleAnswer(data);
    };
    _signaling.onIceCandidate = (data) async {
      await _handleRemoteIceCandidate(data);
    };
  }

  Future<ConnectionResult> connect(PeerDevice peer) async {
    try {
      final iceServers = await _signaling.fetchIceServers();
      final config = {
        'iceServers': iceServers,
        'sdpSemantics': 'unified-plan',
      };

      _peerConnection = await createPeerConnection(config);
      _peerConnection!.onIceConnectionState = (state) {
        _connectionStateController.add(state);
      };

      _dataChannel = await _peerConnection!.createDataChannel(
        'SwiftShareData',
        RTCDataChannelInit()
          ..ordered = true
          ..maxRetransmits = 30,
      );
      _setupDataChannel(_dataChannel!);

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await _signaling.sendOffer(offer.sdp!);
      _logger.i('WebRTC offer sent');

      return const ConnectionResult(success: true, mode: ConnectionMode.remote);
    } catch (e) {
      _logger.e('WebRTC connect failed', e: e);
      return ConnectionResult(success: false, error: e.toString(), mode: ConnectionMode.remote);
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final iceServers = await _signaling.fetchIceServers();
      final config = {'iceServers': iceServers, 'sdpSemantics': 'unified-plan'};
      _peerConnection = await createPeerConnection(config);

      _peerConnection!.onDataChannel = (channel) {
        _dataChannel = channel;
        _setupDataChannel(channel);
      };

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['offer'], 'offer'),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      await _signaling.sendAnswer(answer.sdp!);
      _logger.i('WebRTC answer sent');
    } catch (e) {
      _logger.e('Handle offer failed', e: e);
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['answer'], 'answer'),
      );
      _logger.i('WebRTC remote description set (answer)');
    } catch (e) {
      _logger.e('Handle answer failed', e: e);
    }
  }

  Future<void> _handleRemoteIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = data['candidate'];
      if (candidate != null) {
        await _peerConnection!.addCandidate(
          RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']),
        );
      }
    } catch (e) {
      _logger.e('Add ICE candidate failed', e: e);
    }
  }

  void _setupDataChannel(RTCDataChannel channel) {
    channel.onMessage = (msg) {
      if (msg.binary != null) {
      } else if (msg.text != null) {
        _messageController.add(msg.text!);
      }
    };
    channel.onDataChannelState = (state) {
      _logger.i('DataChannel state: $state');
    };
  }

  Future<void> send(String data) async {
    if (_dataChannel != null && _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage(data));
    }
  }

  Future<void> sendBinary(Uint8List data) async {
    if (_dataChannel != null && _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage.fromBinary(data));
    }
  }

  Future<void> disconnect() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    _dataChannel = null;
    _peerConnection = null;
    _logger.i('WebRTC disconnected');
  }
}
