enum ConnectionMode {
  lan('LAN', 'Local Network', 0),
  wifiDirect('WiFi Direct', 'Direct Connection', 1),
  remote('Remote', 'Internet P2P', 2);

  final String label;
  final String description;
  final int priority;

  const ConnectionMode(this.label, this.description, this.priority);
}
