import 'package:flutter/material.dart';

class ReliabilityAuditEntry {
  final DateTime timestamp;
  final String label;
  final String message;
  final String detail;
  final bool degraded;

  const ReliabilityAuditEntry({
    required this.timestamp,
    required this.label,
    required this.message,
    required this.detail,
    required this.degraded,
  });
}

class ReliabilityNoticeBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool degraded;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ReliabilityNoticeBanner({
    super.key,
    required this.title,
    required this.message,
    required this.degraded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = degraded ? Colors.orange.shade900 : Colors.green.shade800;
    final bg = degraded ? Colors.orange.shade100 : Colors.green.shade100;

    return Material(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              degraded
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message.trim().isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

class ReliabilityAuditPanel extends StatelessWidget {
  final String title;
  final List<ReliabilityAuditEntry> entries;
  final VoidCallback? onClear;
  final int maxVisible;

  const ReliabilityAuditPanel({
    super.key,
    required this.title,
    required this.entries,
    this.onClear,
    this.maxVisible = 8,
  });

  String _formatTime(DateTime timestamp) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(timestamp.hour)}:${twoDigits(timestamp.minute)}:${twoDigits(timestamp.second)}';
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final shownEvents = entries.take(maxVisible).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.orange.shade900),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (onClear != null)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final event in shownEvents)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    event.degraded
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 16,
                    color: event.degraded
                        ? Colors.orange.shade800
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatTime(event.timestamp)} • ${event.label}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          event.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (event.detail.trim().isNotEmpty)
                          Text(
                            event.detail,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (entries.length > shownEvents.length)
            Text(
              'Showing first ${shownEvents.length} of ${entries.length} events',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}
