import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/ritu_palette.dart';

/// Figma 490:1391 — Settings → Help & Support.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _supportEmail = 'support@ritu.care';

  static const _faqs = <({String question, String answer})>[
    (
      question: 'How does Ritu read my cycle?',
      answer:
          "Ritu doesn't predict - it reflects. Using the period dates you've logged over time, it looks at how consistent your cycle lengths have been and describes that as Regular, Variable, or Unpredictable. It's a plain-language read of your own history, not a forecast of what's ahead.",
    ),
    (
      question: "Why don't I have insights yet?",
      answer:
          "Insights only show up once there's real data behind them. Ritu never fills gaps with guesses. Some insights need just a handful of logged days; cycle-level patterns need at least one full logged cycle, and full classification needs a few cycles of history. Keep logging, and each insight appears as soon as it has something real to show.",
    ),
    (
      question: 'Can I edit my past period date?',
      answer:
          "Yes - head to Settings, where you can update a past period date and mark whether it's exact or your best guess.",
    ),
    (
      question: 'How do I export a summary?',
      answer:
          'Open your latest summary from the Summary tab and tap Export to save it as a PDF. Summary only include sections backed by real data, so what you export always matches what Ritu actually knows from your logs.',
    ),
    (
      question: 'Can Ritu see my data? Is it safe?',
      answer:
          "Your logs stay on your device - there's no account, and nobody at Ritu can see your data. Anything you write in Journal is completely private and never used to shape your patterns; only your structured entries, like period dates, mood, and energy, are read to build your insights.",
    ),
    (
      question: 'What happens to my data if I lose my phone or change phones?',
      answer:
          "Ritu doesn't back up to the cloud automatically. You can export your data anytime and it'll save to your phone - from there, it's yours to upload to your own cloud storage as a backup. If you get a new phone or reinstall Ritu, you can bring that data back in by importing the file, either during onboarding or later from Settings.",
    ),
  ];

  int? _expanded = 0;

  Future<void> _openMail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: const {'subject': 'Ritu feedback'},
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open your email app')),
      );
    }
  }

  void _toggleFaq(int index) {
    setState(() => _expanded = _expanded == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => Navigator.of(context).pop(),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'FAQ',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: context.ritu.textPrimary,
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
                            answer: _faqs[i].answer,
                            expanded: _expanded == i,
                            showDivider: i < _faqs.length - 1,
                            onTap: () => _toggleFaq(i),
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
                      color: context.ritu.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openMail(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: context.ritu.fillPositiveSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.mail,
                                size: 16,
                                color: context.ritu.sage600,
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
                                      color: context.ritu.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    _supportEmail,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 20 / 13,
                                      color: context.ritu.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.squareArrowOutUpRight,
                              size: 16,
                              color: context.ritu.textDisabled,
                            ),
                          ],
                        ),
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
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: child,
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.showDivider,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool expanded;
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
          padding: EdgeInsets.symmetric(vertical: expanded ? 8 : 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                        color: context.ritu.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? LucideIcons.chevronDown
                        : LucideIcons.chevronRight,
                    size: 16,
                    color: context.ritu.textDisabled,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 4),
                Text(
                  answer,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
