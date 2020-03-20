import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

extension DateTimeFormat on DateTime {
  String formatDDMMYYY() => _dateFormat.format(this);
}

extension DateTimeParser on String {
  DateTime parseDDMMYYYY() => _dateFormat.parse(this);
}
