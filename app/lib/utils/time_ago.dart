String formatTimeAgo(DateTime timestamp, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(timestamp);
  if (diff.isNegative || diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  return '${diff.inDays}d ago';
}
