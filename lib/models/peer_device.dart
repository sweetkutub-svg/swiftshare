import 'connection_mode.dart';

class PeerDevice {
  final String id;
  final String name;
  final String? ipAddress;
  final ConnectionMode connectionMode;
  final DateTime discoveredAt;
  final bool isTrusted;

  const PeerDevice({
    required this.id,
    required this.name,
    this.ipAddress,
    required this.connectionMode,
    required this.discoveredAt,
    this.isTrusted = false,
  });

  PeerDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    ConnectionMode? connectionMode,
    DateTime? discoveredAt,
    bool? isTrusted,
  }) {
    return PeerDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      connectionMode: connectionMode ?? this.connectionMode,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      isTrusted: isTrusted ?? this.isTrusted,
    );
  }

  @override
  String toString() => 'PeerDevice(name: $name, mode: ${connectionMode.label})';
}
