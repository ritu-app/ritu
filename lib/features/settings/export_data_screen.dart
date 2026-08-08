import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/app_restart_provider.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_colors.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  var _includeLogs = true;
  var _includeJournal = true;
  var _includeSettings = true;
  var _busy = false;

  bool get _canSave =>
      !_busy && (_includeLogs || _includeJournal || _includeSettings);

  Future<void> _export() async {
    if (!_canSave) return;
    setState(() => _busy = true);
    try {
      final json = await ref.read(rituBackupServiceProvider).exportJson(
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
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RituColors.fillElevated,
          title: Text(
            'Replace all data?',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RituColors.textPrimary,
            ),
          ),
          content: Text(
            'Importing a backup replaces everything currently stored on this device. This can’t be undone.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: RituColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: RituColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Import',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: RituColors.sage600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.single;
    String? raw;
    if (file.bytes != null) {
      raw = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      raw = await File(file.path!).readAsString();
    }
    if (raw == null || raw.trim().isEmpty) {
      _showMessage('Could not read the selected file.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(rituBackupServiceProvider).importJson(raw);
      if (!mounted) return;
      ref.invalidate(profileProvider);
      ref.read(appRestartProvider.notifier).state++;
    } catch (error) {
      if (!mounted) return;
      _showMessage('Import failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Text(
                    'Export your data',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Download a copy of all your data in the format you prefer',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: RituColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Export format',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _Card(
                    children: [
                      _FormatRow(
                        title: 'PDF report',
                        subtitle:
                            'Best for sharing with healthcare professionals',
                        enabled: false,
                        selected: false,
                        showDivider: true,
                      ),
                      _FormatRow(
                        title: 'CSV',
                        subtitle: 'Spreadsheet for detailed analysis',
                        enabled: false,
                        selected: false,
                        showDivider: true,
                      ),
                      _FormatRow(
                        title: 'JSON',
                        subtitle: 'RAW data for advanced use',
                        enabled: true,
                        selected: true,
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Includes',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: RituColors.textPrimary,
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
                        onTap: () => setState(
                          () => _includeJournal = !_includeJournal,
                        ),
                        showDivider: true,
                      ),
                      const _IncludeRow(
                        title: 'Insights & patterns',
                        selected: false,
                        enabled: false,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _canSave ? _export : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: RituColors.sage500,
                        disabledBackgroundColor:
                            RituColors.sage500.withValues(alpha: 0.5),
                        foregroundColor: RituColors.white,
                        disabledForegroundColor: RituColors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 24 / 15,
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: RituColors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : _import,
                    child: Text(
                      'Import from file',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                        color: RituColors.sage600,
                      ),
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

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.selected,
    required this.showDivider,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final bool selected;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        enabled ? RituColors.textPrimary : RituColors.textTertiary;
    final subtitleColor =
        enabled ? RituColors.textTertiary : RituColors.textDisabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: RituColors.borderSubtle,
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          _SelectionMark(selected: selected, enabled: enabled, radio: true),
          const SizedBox(width: 16),
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
                    color: titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: subtitleColor,
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
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RituColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              _SelectionMark(
                selected: selected,
                enabled: enabled,
                radio: false,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: enabled
                        ? RituColors.textPrimary
                        : RituColors.textTertiary,
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
  const _SelectionMark({
    required this.selected,
    required this.enabled,
    required this.radio,
  });

  final bool selected;
  final bool enabled;
  final bool radio;

  @override
  Widget build(BuildContext context) {
    if (selected && enabled) {
      return const Icon(
        LucideIcons.circleCheck,
        size: 16,
        color: RituColors.sage500,
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled ? RituColors.textDisabled : RituColors.borderSubtle,
        ),
      ),
      child: radio && selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: RituColors.sage500,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
