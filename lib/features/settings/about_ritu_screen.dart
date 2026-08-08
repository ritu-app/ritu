import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/ritu_colors.dart';

const _sageBanner = Color(0xFF708B7D);
const _borderDefault = Color(0xFFE2DDD8);

/// Figma 501:1422 — Settings → About Ritu.
class AboutRituScreen extends StatelessWidget {
  const AboutRituScreen({super.key});

  /// Set once the App Store listing exists.
  static final Uri? _appStoreUri = null;

  static const _helps = <({String title, String subtitle})>[
    (
      title: 'Capture your rhythm',
      subtitle: 'Build a complete picture of your daily well-being',
    ),
    (
      title: 'Recognize patterns',
      subtitle: 'Discover connections hidden within your health data',
    ),
    (
      title: 'Understand Yourself',
      subtitle: 'Gain insights that support informed health decisions',
    ),
  ];

  Future<void> _rateOnAppStore(BuildContext context) async {
    final uri = _appStoreUri;
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App Store listing coming soon')),
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open the App Store')),
      );
    }
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  const _HeroBanner(),
                  const SizedBox(height: 20),
                  const _MissionCard(),
                  const SizedBox(height: 20),
                  Text(
                    'How Ritu helps',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 20 / 13,
                      color: RituColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _HelpsCard(items: _helps),
                  const SizedBox(height: 20),
                  _RateCard(onTap: () => _rateOnAppStore(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageBanner,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderDefault,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 96,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: -116 * 0.1121,
                  top: -96 * 0.25,
                  width: 116 * 1.1724,
                  height: 96 * 1.4167,
                  child: Image.asset(
                    'assets/images/about_hero.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ritu',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 34 / 28,
              color: RituColors.textInverse,
            ),
          ),
          Text(
            'A private journal for your cycle',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textInverse,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our mission',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 20 / 13,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            'Women’s bodies follow unique rhythms. Ritu helps you discover '
            'those patterns, understand your cycle, and make more informed '
            'decisions about your well-being.',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: RituColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpsCard extends StatelessWidget {
  const _HelpsCard({required this.items});

  final List<({String title, String subtitle})> items;

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
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _HelpRow(
              title: items[i].title,
              subtitle: items[i].subtitle,
              showDivider: i < items.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 20 / 13,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: RituColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RituColors.fillElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: RituColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RituColors.fillAttentionSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.star,
                  size: 16,
                  color: RituColors.iconAttention,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate Ritu on the App store',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                        color: RituColors.textPrimary,
                      ),
                    ),
                    Text(
                      'It helps more people find the app',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 18 / 11,
                        color: RituColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.squareArrowOutUpRight,
                size: 16,
                color: RituColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
