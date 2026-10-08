import 'package:flutter/material.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../theme/studio_styles.dart';

class StudioPillButton extends StatelessWidget {
  const StudioPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RituColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: RituColors.sage500),
          ),
          child: SizedBox(
            height: 38,
            width: expand ? double.infinity : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: expand ? 12 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: RituColors.sage600),
                  const SizedBox(width: 4),
                  Text(label, style: StudioText.reset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (expand) return button;
    return Align(alignment: Alignment.center, child: button);
  }
}

class StudioToggle extends StatelessWidget {
  const StudioToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      label: 'Logged today',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(!value),
          child: SizedBox(
            width: 36,
            height: 19,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: value ? RituColors.sage500 : RituColors.textMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Align(
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: RituColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 15, height: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudioSegmentedControl<T> extends StatelessWidget {
  const StudioSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RituColors.fillSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _Segment(
                  label: labelOf(option),
                  selected: option == selected,
                  onTap: () => onChanged(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: selected
                ? BoxDecoration(
                    color: RituColors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(32, 29, 29, 0.04),
                        offset: Offset(0, 4),
                        blurRadius: 2,
                      ),
                    ],
                  )
                : const BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: selected
                    ? StudioText.fieldValue
                    : StudioText.segmentIdle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
