import 'package:flutter/material.dart';

/// Pastille d'état : pleine pour la garde, discrète pour l'ouverture.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    this.filled = false,
    this.muted = false,
    super.key,
  });

  final String label;
  final bool filled;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dot = filled
        ? theme.colorScheme.onPrimary
        : (muted ? theme.colorScheme.outline : theme.colorScheme.secondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: filled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}