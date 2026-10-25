import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/repository_providers.dart';
import '../../theme/ritu_palette.dart';
import 'import_data_screen.dart';

/// Figma 1249:5779 — Settings → Export & Import.
class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  Future<void> _openExport() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _ExportOptionsScreen()),
    );
  }

  Future<void> _openImport() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ImportDataScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackChevron(onTap: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'Export & Import',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                  Text(
                    'Back up your journal, or restore it from a file you’ve exported before.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: context.ritu.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    title: 'Export Data',
                    subtitle: 'Download a copy of your data as a file',
                    onTap: _openExport,
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    title: 'Import Data',
                    subtitle: 'Restore from a previously exported file',
                    onTap: _openImport,
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

/// Figma 471:1641 — JSON export options.
class _ExportOptionsScreen extends ConsumerStatefulWidget {
  const _ExportOptionsScreen();

  @override
  ConsumerState<_ExportOptionsScreen> createState() =>
      _ExportOptionsScreenState();
}

class _ExportOptionsScreenState extends ConsumerState<_ExportOptionsScreen> {
  var _includeLogs = true;
  var _includeJournal = true;
  var _includeSettings = true;
  var _busy = false;

  bool get _canSave =>
      !_busy && (_includeLogs || _includeJournal || _includeSettings);

  /// iOS requires a non-zero [sharePositionOrigin] for the share sheet popover.
  Rect _sharePositionOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null &&
        box.hasSize &&
        box.size.width > 0 &&
        box.size.height > 0) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  Future<void> _export() async {
    if (!_canSave) return;
    final shareOrigin = _sharePositionOrigin(context);
    setState(() => _busy = true);
    try {
      final json = await ref
          .read(rituBackupServiceProvider)
          .exportJson(
            includeLogs: _includeLogs,
            includeJournal: _includeJournal,
            includeSettings: _includeSettings,
          );

      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().split('T').first;
      final file = File(p.join(dir.path, 'ritu-backup-$stamp.json'));
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Ritu data export',
        sharePositionOrigin: shareOrigin,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackChevron(
              onTap: _busy ? null : () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'Export your data',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                  Text(
                    'Download a copy of your data as a JSON file. Raw data for backup or advanced use',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: context.ritu.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Includes',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _IncludeRow(
                        title: 'Logs',
                        selected: _includeLogs,
                        enabled: !_busy,
                        onTap: () =>
                            setState(() => _includeLogs = !_includeLogs),
                        showDivider: true,
                      ),
                      _IncludeRow(
                        title: 'Journal entries',
                        selected: _includeJournal,
                        enabled: !_busy,
                        onTap: () =>
                            setState(() => _includeJournal = !_includeJournal),
                        showDivider: true,
                      ),
                      const _IncludeRow(
                        title: 'Insights & patterns',
                        selected: false,
                        enabled: true,
                        showDivider: true,
                      ),
                      _IncludeRow(
                        title: 'Settings',
                        selected: _includeSettings,
                        enabled: !_busy,
                        onTap: () => setState(
                          () => _includeSettings = !_includeSettings,
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _canSave ? _export : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.ritu.sage500,
                        disabledBackgroundColor: context.ritu.sage500
                            .withValues(alpha: 0.5),
                        foregroundColor: context.ritu.white,
                        disabledForegroundColor: context.ritu.white,
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
                          : const Text('Save'),
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

class _BackChevron extends StatelessWidget {
  const _BackChevron({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onTap,
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
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.ritu.fillElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.ritu.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                        color: context.ritu.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 18 / 11,
                        color: context.ritu.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: context.ritu.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _IncludeRow extends StatelessWidget {
  const _IncludeRow({
    required this.title,
    required this.selected,
    required this.enabled,
    required this.showDivider,
    this.onTap,
  });

  final String title;
  final bool selected;
  final bool enabled;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.ritu.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              _SelectionMark(selected: selected, enabled: enabled),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: enabled
                        ? context.ritu.textPrimary
                        : context.ritu.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (selected && enabled) {
      return Icon(
        LucideIcons.circleCheck,
        size: 16,
        color: context.ritu.sage500,
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled
              ? context.ritu.textDisabled
              : context.ritu.borderSubtle,
        ),
      ),
    );
  }
}
