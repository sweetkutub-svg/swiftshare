enum TransferStatus {
  pending('Pending'),
  connecting('Connecting'),
  active('Transferring'),
  paused('Paused'),
  completed('Completed'),
  error('Error'),
  declined('Declined'),
  cancelled('Cancelled');

  final String label;
  const TransferStatus(this.label);
}
