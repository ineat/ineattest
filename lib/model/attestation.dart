import 'package:flutter/widgets.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'attestation.jser.dart';

class Attestation {
  final String name;
  final String birthday;
  final String zip;
  final String address;
  final String city;
  final AttestationReason reason;

  Attestation({
    @required this.name,
    @required this.birthday,
    @required this.address,
    @required this.city,
    @required this.zip,
    @required this.reason,
  });
}

@GenSerializer()
class AttestationSerializer extends Serializer<Attestation> with _$AttestationSerializer {}

enum AttestationReason { work, food, health, family, sport }

extension AttestationReasonString on AttestationReason {
  String toValueString() {
    return this.toString().split(".").last;
  }
}
