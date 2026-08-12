import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/date_format.dart';
import '../../../data/models/period_log.dart';
import '../../../theme/ritu_colors.dart';
import 'choice_chips.dart';
import 'period_end_date_sheet.dart';

enum PeriodOngoingStatus { stillGoing, ended }

enum EndConfidenceChoice { exact, rough }

/// Shared “still going / ended / exact / rough” fields for period entry flows.
class PeriodEpisodeFormFields extends StatelessWidget {
  const PeriodEpisodeFormFields({
    super.key,
    required this.ongoingStatus,
    required this.onOngoingStatusChanged,
    required this.endConfidence,
    required this.onEndConfidenceChanged,
    required this.selectedEndDate,
    required this.onEndDatePicked,
    required this.roughDurationBucket,
    required this.onRoughDurationBucketChanged,
    required this.maxEndDate,
    required this.startDate,
    required this.startDateValid,
  });

  final PeriodOngoingStatus? ongoingStatus;
  final ValueChanged<PeriodOngoingStatus> onOngoingStatusChanged;
  final EndConfidenceChoice? endConfidence;
  final ValueChanged<EndConfidenceChoice> onEndConfidenceChanged;
  final DateTime? selectedEndDate;
  final ValueChanged<DateTime> onEndDatePicked;
  final String? roughDurationBucket;
  final ValueChanged<String> onRoughDurationBucketChanged;
  final DateTime maxEndDate;
  final DateTime? startDate;
  final bool startDateValid;

  static const roughOptions = <String, String>{
    RoughDurationBuckets.twoToThreeDays: '2-3 days',
    RoughDurationBuckets.fourToFiveDays: '4-5 days',
    RoughDurationBuckets.sixToSevenDays: '6-7 days',
    RoughDurationBuckets.eightPlusDays: '8+ days',
  };

  Future<void> _pickEndDate(BuildContext context) async {
    final start = startDate;
    if (start == null || !startDateValid) return;
    final picked = await showPeriodEndDateSheet(
      context: context,
      startedOn: start,
      maxEndDate: maxEndDate,
      initialEndDate: selectedEndDate,
    );
    if (picked != null) {
      onEndDatePicked(dateOnly(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Is it still going, or has it ended?',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 24 / 18,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            RituChoiceChip(
              label: 'Still going',
              selected: ongoingStatus == PeriodOngoingStatus.stillGoing,
              onTap: () => onOngoingStatusChanged(PeriodOngoingStatus.stillGoing),
            ),
            RituChoiceChip(
              label: "It's ended",
              selected: ongoingStatus == PeriodOngoingStatus.ended,
              onTap: () => onOngoingStatusChanged(PeriodOngoingStatus.ended),
            ),
          ],
        ),
        if (ongoingStatus == PeriodOngoingStatus.ended) ...[
          const SizedBox(height: 24),
          Text(
            'How sure are you about when it ended?',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: RituColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RituChoiceChip(
                label: 'I know the exact date',
                selected: endConfidence == EndConfidenceChoice.exact,
                onTap: () => onEndConfidenceChanged(EndConfidenceChoice.exact),
              ),
              RituChoiceChip(
                label: 'Not sure - roughly',
                selected: endConfidence == EndConfidenceChoice.rough,
                onTap: () => onEndConfidenceChanged(EndConfidenceChoice.rough),
              ),
            ],
          ),
          if (endConfidence == EndConfidenceChoice.exact) ...[
            const SizedBox(height: 24),
            Text(
              'When did it end?',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 24 / 18,
                color: RituColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: startDateValid ? () => _pickEndDate(context) : null,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: RituColors.fillElevated,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selectedEndDate == null
                        ? RituColors.borderDisabled
                        : RituColors.sage600,
                  ),
                ),
                child: Text(
                  selectedEndDate == null
                      ? 'Tap to select a date'
                      : formatDisplayDate(selectedEndDate!),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 24 / 15,
                    color: selectedEndDate == null
                        ? RituColors.textMuted
                        : RituColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
          if (endConfidence == EndConfidenceChoice.rough) ...[
            const SizedBox(height: 24),
            Text(
              'And roughly how many days did it last?',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 24 / 18,
                color: RituColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in roughOptions.entries)
                  RituChoiceChip(
                    label: entry.value,
                    selected: roughDurationBucket == entry.key,
                    onTap: () => onRoughDurationBucketChanged(entry.key),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

/// Whether the episode form has enough detail to save.
bool periodEpisodeFormIsComplete({
  required DateTime? startDate,
  required PeriodOngoingStatus? ongoingStatus,
  required EndConfidenceChoice? endConfidence,
  required DateTime? selectedEndDate,
  required String? roughDurationBucket,
}) {
  if (startDate == null || ongoingStatus == null) return false;
  if (ongoingStatus == PeriodOngoingStatus.stillGoing) return true;
  if (endConfidence == null) return false;
  if (endConfidence == EndConfidenceChoice.exact) {
    return selectedEndDate != null;
  }
  return roughDurationBucket != null;
}

/// Typical bleed length for profile defaults from form state.
int? typicalPeriodDaysFromEpisodeForm({
  required PeriodOngoingStatus? ongoingStatus,
  required EndConfidenceChoice? endConfidence,
  required DateTime? startDate,
  required DateTime? selectedEndDate,
  required String? roughDurationBucket,
}) {
  if (ongoingStatus == PeriodOngoingStatus.stillGoing) return null;
  if (endConfidence == EndConfidenceChoice.exact &&
      startDate != null &&
      selectedEndDate != null) {
    return dateOnly(selectedEndDate!)
            .difference(dateOnly(startDate))
            .inDays +
        1;
  }
  if (endConfidence == EndConfidenceChoice.rough &&
      roughDurationBucket != null) {
    return RoughDurationBuckets.typicalDaysFor(roughDurationBucket);
  }
  return null;
}
