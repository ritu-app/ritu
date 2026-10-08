import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../presets/studio_scenario.dart';
import '../scope/studio_scope.dart';
import '../theme/studio_styles.dart';
import '../util/download_text_file.dart';

class StudioScenarioList extends StatelessWidget {
  const StudioScenarioList({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final StudioScenario selected;
  final ValueChanged<StudioScenario> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final scenario in StudioScenario.values) ...[
          if (scenario != StudioScenario.values.first)
            const SizedBox(height: 8),
          _ScenarioOption(
            label: scenario.label,
            selected: scenario == selected,
            onTap: () => onSelected(scenario),
          ),
        ],
      ],
    );
  }
}

class _ScenarioOption extends StatelessWidget {
  const _ScenarioOption({
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
            decoration: BoxDecoration(
              color: RituColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? studioMeadow500 : RituColors.fillMuted,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                label,
                style: selected ? StudioText.fieldValue : StudioText.option,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExportScenarioActions extends StatelessWidget {
  const ExportScenarioActions({super.key, required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Download a ritu.backup JSON and import it on a phone via '
          'Settings → Export Data → Import from file. Keep simulated today '
          'on or before wall-clock today so period starts import cleanly.',
          style: StudioText.noteBody,
        ),
        const SizedBox(height: 12),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onExport,
            child: Text('Download JSON', style: StudioText.reset),
          ),
        ),
      ],
    );
  }
}

class ResetScenarioButton extends StatelessWidget {
  const ResetScenarioButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.rotateCcw,
                size: 20,
                color: RituColors.sage500,
              ),
              const SizedBox(width: 8),
              Text('Reset scenario', style: StudioText.reset),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> exportStudioBackup(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final controller = context.studioController;
  try {
    final json = await controller.exportBackupJson();
    if (!context.mounted) return;
    final stamp = DateTime.now().toIso8601String().split('T').first;
    downloadTextFile(filename: 'ritu-studio-$stamp.json', contents: json);
    messenger.showSnackBar(const SnackBar(content: Text('Backup downloaded')));
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
  }
}
