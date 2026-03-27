import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thot/data/thot_provider.dart';

class AppDateFormats {
  static String _localeTag(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  static String _dateOrder(BuildContext context) =>
      context.read<ThotProvider>().dateFormatPreference;

  static String _capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value.replaceFirstMapped(
      RegExp(r'[A-Za-zÀ-ÿ]'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  static DateFormat _dateTimeShort(BuildContext context) {
    final locale = _localeTag(context);
    switch (_dateOrder(context)) {
      case 'month_day_year':
        return DateFormat('MMMM d yyyy HH:mm', locale);
      case 'day_month_year':
      default:
        return DateFormat('d MMMM yyyy HH:mm', locale);
    }
  }

  static DateFormat _dateShort(BuildContext context) {
    final locale = _localeTag(context);
    switch (_dateOrder(context)) {
      case 'month_day_year':
        return DateFormat('MMMM d yyyy', locale);
      case 'day_month_year':
      default:
        return DateFormat('d MMMM yyyy', locale);
    }
  }

  static DateFormat _timeShort(BuildContext context) =>
      DateFormat.Hm(_localeTag(context));

  static DateFormat _dayMonth(BuildContext context) {
    final locale = _localeTag(context);
    switch (_dateOrder(context)) {
      case 'month_day_year':
        return DateFormat('MMMM d', locale);
      case 'day_month_year':
      default:
        return DateFormat('d MMMM', locale);
    }
  }

  static DateFormat _monthYear(BuildContext context) =>
      DateFormat('MMMM yyyy', _localeTag(context));

  static String formatDateTimeShort(BuildContext context, DateTime date) =>
      _capitalizeFirstLetter(_dateTimeShort(context).format(date));

  static String formatDateShort(BuildContext context, DateTime date) =>
      _capitalizeFirstLetter(_dateShort(context).format(date));

  static String formatTimeShort(BuildContext context, DateTime date) =>
      _timeShort(context).format(date);

  static String formatDayMonth(BuildContext context, DateTime date) =>
      _capitalizeFirstLetter(_dayMonth(context).format(date));

  static String formatMonthYear(BuildContext context, DateTime date) =>
      _capitalizeFirstLetter(_monthYear(context).format(date));
}
