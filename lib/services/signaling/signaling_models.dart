class SignalingMessage {
  final String event;
  final String roomId;
  final Map<String, dynamic> payload;

  const SignalingMessage({
    required this.event,
    required this.roomId,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
    'event': event,
    'roomId': roomId,
    ...payload,
  };

  factory SignalingMessage.fromJson(Map<String, dynamic> json) {
    return SignalingMessage(
      event: json['event'] as String,
      roomId: json['roomId'] as String,
      payload: Map<String, dynamic>.from(json)..remove('event')..remove('roomId'),
    );
  }
}

class IceServerConfig {
  final List<String> urls;
  final String? username;
  final String? credential;

  const IceServerConfig({
    required this.urls,
    this.username,
    this.credential,
  });

  Map<String, dynamic> toJson() => {
    'urls': urls,
    if (username != null) 'username': username,
    if (credential != null) 'credential': credential,
  };

  factory IceServerConfig.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'];
    return IceServerConfig(
      urls: urls is String ? [urls] : List<String>.from(urls as List),
      username: json['username'] as String?,
      credential: json['credential'] as String?,
    );
  }
}
