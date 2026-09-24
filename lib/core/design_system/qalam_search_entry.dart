import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'qalam_typography.dart';

/// A quiet search entry (underline, no box) that opens global search.
class QalamSearchEntry extends StatelessWidget {
  const QalamSearchEntry({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: () => context.push('/search'),
      child: InkWell(
        onTap: () => context.push('/search'),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: colors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.body(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
