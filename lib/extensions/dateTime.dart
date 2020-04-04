import 'package:intl/intl.dart';

final _dateFormatDmyHm = DateFormat("dd/MM/yyyy - HH'h'mm");
final _dateFormatDmy = DateFormat("dd/MM/yyyy");

extension DateTimeFormat on DateTime {
  String formatDmyHm() => _dateFormatDmyHm.format(this);
  String formatDmy() => _dateFormatDmy.format(this);
}

extension DateTimeParser on String {
  DateTime parseDmyHm() => _dateFormatDmyHm.parse(this);
  DateTime parseDmy() => _dateFormatDmy.parse(this);
}
