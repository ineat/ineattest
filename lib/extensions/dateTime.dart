import 'package:intl/intl.dart';

final _dateFormat = DateFormat("dd/MM/yyyy - HH'h'mm");

extension DateTimeFormat on DateTime {
  String formatDmyHm() => _dateFormat.format(this);
}

extension DateTimeParser on String {
  DateTime parseDmyHm() => _dateFormat.parse(this);
}
