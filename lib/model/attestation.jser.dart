// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attestation.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AttestationSerializer implements Serializer<Attestation> {
  final _attestationReasonProcessor = const AttestationReasonProcessor();
  final _dateTimeProcessorIso = const DateTimeProcessorIso();
  @override
  Map<String, dynamic> toMap(Attestation model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'birthday', model.birthday);
    setMapValue(ret, 'birthplace', model.birthplace);
    setMapValue(ret, 'zip', model.zip);
    setMapValue(ret, 'address', model.address);
    setMapValue(ret, 'city', model.city);
    setMapValue(
        ret, 'reason', _attestationReasonProcessor.serialize(model.reason));
    setMapValue(
        ret, 'createdAt', _dateTimeProcessorIso.serialize(model.createdAt));
    return ret;
  }

  @override
  Attestation fromMap(Map map) {
    if (map == null) return null;
    final obj = Attestation(
        name: map['name'] as String ?? getJserDefault('name'),
        birthday: map['birthday'] as String ?? getJserDefault('birthday'),
        birthplace: map['birthplace'] as String ?? getJserDefault('birthplace'),
        address: map['address'] as String ?? getJserDefault('address'),
        city: map['city'] as String ?? getJserDefault('city'),
        zip: map['zip'] as String ?? getJserDefault('zip'),
        reason: _attestationReasonProcessor.deserialize(map['reason'] as int) ??
            getJserDefault('reason'),
        createdAt:
            _dateTimeProcessorIso.deserialize(map['createdAt'] as String) ??
                getJserDefault('createdAt'));
    return obj;
  }
}
