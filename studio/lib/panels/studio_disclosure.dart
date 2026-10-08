import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/studio_styles.dart';

class StudioSurface extends StatelessWidget {
  const StudioSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: studioCardDecoration(),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Collapsed summary card. Expanded body replaces the summary.
class StudioDisclosure extends StatelessWidget {
  const StudioDisclosure({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    this.summary,
    this.expandedSubtitle,
    this.body,
  });

  final String title;
  final String? summary;
  final String? expandedSubtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: studioCardDecoration(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, expanded ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              label: title,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(title, style: StudioText.cardTitle),
                          ),
                          Icon(
                            expanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 20,
                            color: studioIcon,
                          ),
                        ],
                      ),
                      if (expanded && expandedSubtitle != null)
                        Text(expandedSubtitle!, style: StudioText.caption),
                      if (!expanded && summary != null)
                        Text(
                          summary!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StudioText.cardSummary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded && body != null) ...[
              const SizedBox(height: 16),
              body!,
            ],
          ],
        ),
      ),
    );
  }
}
