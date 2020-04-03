import 'dart:convert';
import 'dart:typed_data';

import 'package:ineattest/model/attestation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class Preferences {
  static final String _signatureImageKey = "signature_image";
  static final String _attestationKey = "attestation";

  Preferences._();

  static Future<bool> hasSignature() async {
    return (await getSignatureImage()) != null;
  }
  static Future<Uint8List> getSignatureImage() async {
    final preferences = await SharedPreferences.getInstance();
    final String signatureBase64 = preferences.getString(_signatureImageKey);
    if (signatureBase64 != null) {
      return base64Decode(signatureBase64);
    }
    return null;
  }

  static Future<void> saveSignature(SignatureController signatureController) async {
    final bytes = await signatureController.toPngBytes();
    final signatureBase64 = base64Encode(bytes);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_signatureImageKey, signatureBase64);
  }

  static Future<bool> hasAttestation() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_attestationKey);
  }

  static Future<void> saveAttestation(Attestation attestation) async {
    final preferences = await SharedPreferences.getInstance();
    final json = jsonEncode(AttestationSerializer().toMap(attestation));
    await preferences.setString(_attestationKey, json);
  }

  static Future<Attestation> getAttestation() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(_attestationKey)) {
      final json = preferences.getString(_attestationKey);
      return AttestationSerializer().fromMap(jsonDecode(json));
    } else
      return null;
  }
}
