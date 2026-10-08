import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/core/home_greeting.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../theme/studio_styles.dart';
import '../util/studio_labels.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({
    super.key,
    required this.date,
    required this.window,
    required this.cycleDay,
    required this.onDate,
    required this.onWindow,
    required this.onCycleDay,
    required this.onCycleDayCommit,
  });

  final DateTime date;
  final GreetingTimeWindow window;
  final int cycleDay;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<GreetingTimeWindow> onWindow;
  final ValueChanged<int> onCycleDay;
  final ValueChanged<int> onCycleDayCommit;

  static const _minDay = 1;
  static const _sliderCap = 60;

  @override
  Widget build(BuildContext context) {
    final day = cycleDay.clamp(_minDay, 99);
    final maxDay = math.max(_sliderCap, day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: 'Date'),
        const SizedBox(height: 4),
        _SelectField(
          value: formatStudioNumericDate(date),
          icon: LucideIcons.calendar1,
          onTap: () => _pickDate(context),
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Time of day'),
        const SizedBox(height: 4),
        _TimeOfDayField(window: window, onWindow: onWindow),
        const SizedBox(height: 16),
        const _CycleDayLabel(),
        const SizedBox(height: 4),
        StudioCycleDaySlider(
          value: day,
          min: _minDay,
          max: maxDay,
          onChanged: onCycleDay,
          onChangeEnd: onCycleDayCommit,
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    onDate(dateOnly(picked));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: StudioText.fieldLabel);
  }
}

class _CycleDayLabel extends StatelessWidget {
  const _CycleDayLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Cycle day', style: StudioText.fieldLabel),
        const SizedBox(width: 4),
        const Tooltip(
          message:
              'Day 1 is the latest period start. Drag to move through this cycle.',
          child: Icon(
            LucideIcons.info,
            size: 14,
            color: RituColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: RituColors.fillMuted),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StudioText.fieldValue,
                  ),
                ),
                Icon(icon, size: 20, color: studioIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeOfDayField extends StatelessWidget {
  const _TimeOfDayField({required this.window, required this.onWindow});

  final GreetingTimeWindow window;
  final ValueChanged<GreetingTimeWindow> onWindow;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(RituColors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: RituColors.fillMuted),
          ),
        ),
      ),
      menuChildren: [
        for (final option in GreetingTimeWindow.values)
          MenuItemButton(
            onPressed: () => onWindow(option),
            child: Text(
              greetingWindowRangeLabel(option),
              style: StudioText.fieldValue,
            ),
          ),
      ],
      builder: (context, controller, _) {
        return _SelectField(
          value: greetingWindowRangeLabel(window),
          icon: LucideIcons.chevronDown,
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}

class StudioCycleDaySlider extends StatefulWidget {
  const StudioCycleDaySlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;

  @override
  State<StudioCycleDaySlider> createState() => _StudioCycleDaySliderState();
}

class _StudioCycleDaySliderState extends State<StudioCycleDaySlider> {
  late int _value = widget.value;

  @override
  void didUpdateWidget(StudioCycleDaySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final day = _dayFor(details.localPosition.dx, width);
            _set(day);
            widget.onChangeEnd(day);
          },
          onHorizontalDragUpdate: (details) {
            _set(_dayFor(details.localPosition.dx, width));
          },
          onHorizontalDragEnd: (_) => widget.onChangeEnd(_value),
          child: SizedBox(
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 9.5,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: RituColors.fillMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 9.5,
                  width: _thumbLeft(width) + 10,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: studioMeadow500,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: _thumbLeft(width),
                  top: 2,
                  child: const _CycleDayThumb(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _set(int day) {
    if (day == _value) return;
    setState(() => _value = day);
    widget.onChanged(day);
  }

  double _thumbLeft(double width) {
    const thumb = 20.0;
    final span = math.max(1, widget.max - widget.min);
    final t = ((_value - widget.min) / span).clamp(0.0, 1.0);
    return (width - thumb) * t;
  }

  int _dayFor(double dx, double width) {
    const thumb = 20.0;
    final travel = math.max(1.0, width - thumb);
    final t = ((dx - thumb / 2) / travel).clamp(0.0, 1.0);
    return (widget.min + t * (widget.max - widget.min)).round().clamp(
      widget.min,
      widget.max,
    );
  }
}

class _CycleDayThumb extends StatelessWidget {
  const _CycleDayThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RituColors.meadow600,
        border: Border.all(color: RituColors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4.3,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
