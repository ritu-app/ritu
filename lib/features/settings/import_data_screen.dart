import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/backup/restore_backup_file.dart';
import '../../data/backup/ritu_backup.dart';
import '../../providers/app_restart_provider.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_palette.dart';

/// Figma 1249:5890 / 1249:5977 / 1249:6162 / 1249:6221 —
/// Settings → Export & Import → Import Data.
class ImportDataScreen extends ConsumerStatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ConsumerState<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends ConsumerState<ImportDataScreen> {
  RestoreBackupFile? _file;
  var _invalid = false;
  var _busy = false;

  bool get _canImport => _file != null && !_invalid && !_busy;

  Future<void> _pick() async {
    if (_busy) return;
    try {
      final picked = await ref.read(restoreBackupPickerProvider)();
      if (!mounted || picked == null) return;
      final restorable = RituBackup.isRestorable(picked.contents);
      setState(() {
        if (restorable) {
          _file = picked;
          _invalid = false;
        } else {
          _file = null;
          _invalid = true;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _file = null;
        _invalid = true;
      });
    }
  }

  Future<void> _confirmImport() async {
    final file = _file;
    if (file == null || !_canImport) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.ritu.barrier,
      builder: (_) => _ReplaceDataDialog(fileName: file.name),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(rituBackupServiceProvider).importJson(file.contents);
      if (!mounted) return;
      ref.invalidate(profileProvider);
      ref.read(appRestartProvider.notifier).state++;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _file = null;
        _invalid = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;

    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _busy ? null : () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    'Import your data',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                  Text(
                    'Restore your data from a JSON file you exported before',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: context.ritu.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _UploadZone(
                    file: file,
                    enabled: !_busy,
                    prompt: _invalid
                        ? 'Tap to choose a different file'
                        : 'Tap to choose a file',
                    onTap: _pick,
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap again if you want to select a different file',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 20 / 13,
                        color: context.ritu.textTertiary,
                      ),
                    ),
                  ],
                  if (_invalid) ...[
                    const SizedBox(height: 16),
                    const _ImportErrorBanner(),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _canImport ? _confirmImport : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.ritu.sage500,
                        disabledBackgroundColor: context.ritu.sage500
                            .withValues(alpha: 0.4),
                        foregroundColor: context.ritu.white,
                        disabledForegroundColor: context.ritu.white.withValues(
                          alpha: 0.4,
                        ),
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 24 / 15,
                        ),
                      ),
                      child: _busy
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.ritu.white,
                              ),
                            )
                          : const Text('Import'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({
    required this.file,
    required this.enabled,
    required this.prompt,
    required this.onTap,
  });

  final RestoreBackupFile? file;
  final bool enabled;
  final String prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = file != null;
    const radius = BorderRadius.all(Radius.circular(8));
    final body = Material(
      color: selected ? context.ritu.fillSecondary : context.ritu.fillElevated,
      borderRadius: radius,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: Container(
          height: 114,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: context.ritu.sage600, width: 0.5),
                )
              : null,
          child: selected
              ? _SelectedFile(file: file!)
              : _EmptyFilePrompt(prompt: prompt),
        ),
      ),
    );

    if (selected) return body;

    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: context.ritu.borderDefault,
        radius: 8,
        strokeWidth: 2,
      ),
      child: body,
    );
  }
}

class _EmptyFilePrompt extends StatelessWidget {
  const _EmptyFilePrompt({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.import, size: 24, color: context.ritu.textDisabled),
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 24 / 15,
            color: context.ritu.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _SelectedFile extends StatelessWidget {
  const _SelectedFile({required this.file});

  final RestoreBackupFile file;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          LucideIcons.fileCheckCorner,
          size: 24,
          color: context.ritu.sage500,
        ),
        Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 24 / 15,
            color: context.ritu.textPrimary,
          ),
        ),
        Text(
          formatBackupFileSize(file.sizeBytes),
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: context.ritu.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ImportErrorBanner extends StatelessWidget {
  const _ImportErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillCritical,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Icon(
              LucideIcons.info,
              size: 16,
              color: context.ritu.textCritical,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This file doesn't look like a Ritu backup",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  "Make sure you're importing the .json file from Ritu's Export Data screen, and that it wasn't edited or partially downloaded",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplaceDataDialog extends StatelessWidget {
  const _ReplaceDataDialog({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 358),
        child: Material(
          color: context.ritu.fillElevated,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.ritu.borderSubtle, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will replace your current data',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  'Importing "$fileName" overwrites everything currently on this device - periods, journal entries, and settings. This can\'t be undone',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: context.ritu.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _DialogAction(
                      label: 'Overwrite and continue',
                      color: context.ritu.textCritical,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    const SizedBox(width: 32),
                    _DialogAction(
                      label: 'Cancel',
                      color: context.ritu.textTertiary,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
        textStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 20 / 13,
        ),
      ),
      child: Text(label),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
