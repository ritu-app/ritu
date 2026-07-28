// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ritu_widgetbook/use_cases/components/buttons_use_cases.dart'
    as _ritu_widgetbook_use_cases_components_buttons_use_cases;
import 'package:ritu_widgetbook/use_cases/components/calendar_use_cases.dart'
    as _ritu_widgetbook_use_cases_components_calendar_use_cases;
import 'package:ritu_widgetbook/use_cases/components/chips_use_cases.dart'
    as _ritu_widgetbook_use_cases_components_chips_use_cases;
import 'package:ritu_widgetbook/use_cases/components/log_slider_card_use_cases.dart'
    as _ritu_widgetbook_use_cases_components_log_slider_card_use_cases;
import 'package:ritu_widgetbook/use_cases/components/progress_dots_use_cases.dart'
    as _ritu_widgetbook_use_cases_components_progress_dots_use_cases;
import 'package:ritu_widgetbook/use_cases/screens/home_use_cases.dart'
    as _ritu_widgetbook_use_cases_screens_home_use_cases;
import 'package:ritu_widgetbook/use_cases/screens/journal_use_cases.dart'
    as _ritu_widgetbook_use_cases_screens_journal_use_cases;
import 'package:ritu_widgetbook/use_cases/screens/onboarding_use_cases.dart'
    as _ritu_widgetbook_use_cases_screens_onboarding_use_cases;
import 'package:ritu_widgetbook/use_cases/screens/settings_use_cases.dart'
    as _ritu_widgetbook_use_cases_screens_settings_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Components',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Buttons',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'OutlinedPillButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_components_buttons_use_cases
                    .outlinedPillButtonUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SetupFooter',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_components_buttons_use_cases
                    .setupFooterUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Calendar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'RituCalendar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default selection',
                builder:
                    _ritu_widgetbook_use_cases_components_calendar_use_cases
                        .rituCalendarDefaultUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Dotted selection style',
                builder:
                    _ritu_widgetbook_use_cases_components_calendar_use_cases
                        .rituCalendarDottedUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Max selectable date (no future dates)',
                builder:
                    _ritu_widgetbook_use_cases_components_calendar_use_cases
                        .rituCalendarMaxSelectableUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Preview dates (estimated range)',
                builder:
                    _ritu_widgetbook_use_cases_components_calendar_use_cases
                        .rituCalendarPreviewDatesUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Chips',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'RituChoiceChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _ritu_widgetbook_use_cases_components_chips_use_cases
                    .rituChoiceChipInteractiveUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Wrap of options',
                builder: _ritu_widgetbook_use_cases_components_chips_use_cases
                    .rituChoiceChipWrapUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'LogSliderCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _ritu_widgetbook_use_cases_components_log_slider_card_use_cases
                    .logSliderCardUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ProgressDots',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _ritu_widgetbook_use_cases_components_progress_dots_use_cases
                    .progressDotsUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'RituDateChip',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _ritu_widgetbook_use_cases_components_chips_use_cases
                .rituDateChipUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'List of dates',
            builder: _ritu_widgetbook_use_cases_components_chips_use_cases
                .rituDateChipListUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Screens',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Home',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'HomeScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Logged today',
                builder: _ritu_widgetbook_use_cases_screens_home_use_cases
                    .homeLoggedTodayUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'No period logged yet',
                builder: _ritu_widgetbook_use_cases_screens_home_use_cases
                    .homeEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Not logged today',
                builder: _ritu_widgetbook_use_cases_screens_home_use_cases
                    .homeNotLoggedUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Journal',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'JournalScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'New user',
                builder: _ritu_widgetbook_use_cases_screens_journal_use_cases
                    .journalNewUserUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Onboarding',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'ConfirmationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_onboarding_use_cases
                    .confirmationScreenUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'LastPeriodScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_onboarding_use_cases
                    .lastPeriodScreenUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'NameScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_onboarding_use_cases
                    .nameScreenUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'NotificationScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_onboarding_use_cases
                    .notificationScreenUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PastDatesScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_onboarding_use_cases
                    .pastDatesScreenUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Settings',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CustomSymptomsScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty state',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .customSymptomsEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With symptoms',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .customSymptomsWithDataUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PeriodHistoryScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'With past dates',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .periodHistoryUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PeriodStartedScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .periodStartedUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SettingsScreen',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty state',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .settingsEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With history',
                builder: _ritu_widgetbook_use_cases_screens_settings_use_cases
                    .settingsWithHistoryUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
