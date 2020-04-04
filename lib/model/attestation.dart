import 'package:flutter/widgets.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'attestation.jser.dart';

class Attestation {
  final String name;
  final String lastName;
  final String birthday;
  final String birthplace;
  final String zip;
  final String address;
  final String city;
  final AttestationReason reason;
  final DateTime createdAt;

  Attestation({
    @required this.name,
    @required this.lastName,
    @required this.birthday,
    @required this.birthplace,
    @required this.address,
    @required this.city,
    @required this.zip,
    @required this.reason,
    @required this.createdAt,
  });
}

class DateTimeProcessorIso implements FieldProcessor<DateTime, String> {
  const DateTimeProcessorIso();

  DateTime deserialize(String input) {
    return DateTime.parse(input);
  }

  String serialize(DateTime value) {
    return value?.toIso8601String();
  }
}

class AttestationReasonProcessor implements FieldProcessor<AttestationReason, int> {
  const AttestationReasonProcessor();

  AttestationReason deserialize(int input) {
    return input == -1 ? null : AttestationReason.values[input];
  }

  int serialize(AttestationReason value) {
    return value?.index ?? -1;
  }
}

@GenSerializer(fields: const {
  'createdAt': const EnDecode(processor: DateTimeProcessorIso()),
  'reason': const EnDecode(processor: AttestationReasonProcessor()),
})
class AttestationSerializer extends Serializer<Attestation> with _$AttestationSerializer {}

enum AttestationReason {
  work,
  food,
  health,
  family,
  sport,
  judical,
  voluntary,
}

extension AttestationReasonString on AttestationReason {
  String toValueString() {
    return this.toString().split(".").last;
  }
}
