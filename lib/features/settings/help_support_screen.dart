import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/ritu_colors.dart';

/// Figma 490:1391 — Settings → Help & Support (FAQ + feedback).
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _supportEmail = 'support@ritu.care';

  static const _faqs = <({String question, String answer})>[
    (
      question: 'How does Ritu predict my cycle?',
      answer:
          'Ritu estimates your cycle day and next period from the period starts you’ve logged and your typical cycle length. Predictions get steadier as you log more cycles.',
    ),
    (
      question: 'Why don\'t I have insights yet?',
      answer:
          'Insights unlock as you build a logging history. Keep tracking daily check-ins so Ritu can learn your patterns over time.',
    ),
    (
      question: 'Can I edit my past log?',
      answer:
          'Yes. Open a past day from Home or Journal to review and update what you logged.',
    ),
    (
      question: 'How do I export a report?',
      answer:
          'Go to Settings → Export Data to download a JSON copy of your on-device data. PDF and CSV exports are coming later.',
    ),
    (
      question: 'Can Ritu see my data? Is it safe?',
      answer:
          'No. Everything stays on this device only — there’s no account and no cloud sync. Your journal and logs never leave your phone unless you export them.',
    ),
    (
      question:
          'What happens to my data if I lose my phone or change phones?',
      answer:
          'Because data is stored only on your phone, it won’t move automatically. Export a backup from Settings before switching devices, then import it on the new one.',
    ),
  ];

  final _feedbackController = TextEditingController();
  var _feedback = '';
  var _sending = false;

  bool get _canSend => !_sending && _feedback.trim().isNotEmpty;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openMail({String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Ritu feedback',
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open your email app')),
      );
    }
  }

  Future<void> _sendFeedback() async {
    if (!_canSend) return;
    setState(() => _sending = true);
    try {
      await _openMail(body: _feedback.trim());
      if (!mounted) return;
      _feedbackController.clear();
      setState(() => _feedback = '');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openFaq(int index) {
    final faq = _faqs[index];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FaqAnswerScreen(
          question: faq.question,
          answer: faq.answer,
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'FAQ',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (var i = 0; i < _faqs.length; i++) ...[
                          _FaqRow(
                            question: _faqs[i].question,
                            showDivider: i < _faqs.length - 1,
                            onTap: () => _openFaq(i),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Share feedback',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'What’s on your mind',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 24 / 15,
                            color: RituColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 125,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: RituColors.fillElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: RituColors.borderSubtle),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: const InputDecorationTheme(
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                            child: TextField(
                              controller: _feedbackController,
                              onChanged: (value) =>
                                  setState(() => _feedback = value),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              cursorColor: RituColors.sage500,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 20 / 13,
                                color: RituColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                isCollapsed: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Tell us in detail...',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 13,
                                  color: RituColors.textDisabled,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: FilledButton(
                            onPressed: _canSend ? _sendFeedback : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: RituColors.sage500,
                              disabledBackgroundColor:
                                  RituColors.sage500.withValues(alpha: 0.4),
                              foregroundColor: RituColors.white,
                              disabledForegroundColor: RituColors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: const StadiumBorder(),
                              textStyle: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 20 / 13,
                              ),
                            ),
                            child: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: RituColors.white,
                                    ),
                                  )
                                : const Text('Send feedback'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Card(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openMail(),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: RituColors.fillPositiveSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              LucideIcons.mail,
                              size: 16,
                              color: RituColors.sage600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email us at',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 18 / 11,
                                    color: RituColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  _supportEmail,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 20 / 13,
                                    color: RituColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            LucideIcons.squareArrowOutUpRight,
                            size: 16,
                            color: RituColors.textDisabled,
                          ),
                        ],
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

class _FaqAnswerScreen extends StatelessWidget {
  const _FaqAnswerScreen({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    question,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    answer,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: RituColors.textSecondary,
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
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({
    required this.question,
    required this.showDivider,
    required this.onTap,
  });

  final String question;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: RituColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
