import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/backup/restore_backup_file.dart';
import '../../data/backup/ritu_backup.dart';
import '../../theme/ritu_palette.dart';

/// Figma 1242:5261, 1244:5972, and 1244:5904 — import an exported Ritu backup.
class RestoreBackupScreen extends StatefulWidget {
  const RestoreBackupScreen({
    super.key,
    this.onStartFresh,
    this.onContinue,
    this.pickFile,
    this.initialFile,
    this.initiallyInvalid = false,
  });

  final VoidCallback? onStartFresh;
  final Future<void> Function(RestoreBackupFile file)? onContinue;
  final Future<RestoreBackupFile?> Function()? pickFile;
  final RestoreBackupFile? initialFile;
  final bool initiallyInvalid;

  @override
  State<RestoreBackupScreen> createState() => _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends State<RestoreBackupScreen> {
  RestoreBackupFile? _file;
  var _invalid = false;
  var _busy = false;

  bool get _canContinue => _file != null && !_busy;

  @override
  void initState() {
    super.initState();
    _invalid = widget.initiallyInvalid;
    _file = _invalid ? null : widget.initialFile;
  }

  Future<void> _pick() async {
    if (_busy) return;
    try {
      final picked = await (widget.pickFile ?? pickRestoreBackupFile)();
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

  Future<void> _submit() async {
    final file = _file;
    if (file == null || _busy) return;
    setState(() => _busy = true);
    try {
      await widget.onContinue?.call(file);
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
    final freshLabel = file == null
        ? 'Don’t have a backup? Start fresh instead'
        : 'Want to start fresh? Sign in';

    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/ritu_logo.png',
                              width: 96,
                              height: 96,
                              filterQuality: FilterQuality.high,
                            ),
                            const SizedBox(height: 48),
                            Text(
                              'Restore your data',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 26 / 22,
                                color: context.ritu.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Import the file you exported from Ritu.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 24 / 15,
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
                              const SizedBox(height: 28),
                              const _ImportErrorBanner(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _canContinue ? _submit : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _busy ? null : widget.onStartFresh ?? () {},
                style: TextButton.styleFrom(
                  foregroundColor: context.ritu.textTertiary,
                  disabledForegroundColor: context.ritu.textTertiary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(double.infinity, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 24 / 15,
                  ),
                ),
                child: Text(freshLabel),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
        Icon(LucideIcons.import, size: 24, color: context.ritu.neutral500),
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
        Text(
          'json only',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
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
        SizedBox(
          width: double.infinity,
          child: Text(
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
                  'This file doesn’t look like a Ritu backup',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  'Make sure you’re importing the .json file from Ritu’s Export Data screen, and that it wasn’t edited or partially downloaded',
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
