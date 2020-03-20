// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attestation.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AttestationSerializer implements Serializer<Attestation> {
  @override
  Map<String, dynamic> toMap(Attestation model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'birthday', model.birthday);
    setMapValue(ret, 'address', model.address);
    setMapValue(ret, 'city', model.city);
    setMapValue(ret, 'zip', model.zip);
    setMapValue(ret, 'reason', model.reason.index);
    return ret;
  }

  @override
  Attestation fromMap(Map map) {
    if (map == null) return null;
    final obj = Attestation(
        name: map['name'] as String ?? getJserDefault('name'),
        birthday: map['birthday'] as String ?? getJserDefault('birthday'),
        city: map['city'] as String ?? getJserDefault('city'),
        zip: map['zip'] as String ?? getJserDefault('zip'),
        address: map['address'] as String ?? getJserDefault('address'),
        reason: AttestationReason.values[map['reason'] as int] ?? getJserDefault('reason'));
    return obj;
  }
}
