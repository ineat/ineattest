import 'package:flutter/material.dart';
import 'package:ineattest/extensions/dateTime.dart';
import 'package:ineattest/extensions/i18n.dart';
import 'package:ineattest/model/attestation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatelessWidget {
  final Attestation attestation;
  final double size;

  const QRCode({
    Key key,
    this.attestation,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: "qrcode.content".translate(context, translationParams: {
        "createdAt": attestation.createdAt.formatDmy(),
        "lastName": attestation.lastName,
        "name": attestation.name,
        "birthday": attestation.birthday,
        "birthplace": attestation.birthplace,
        "address": attestation.address,
        "zip": attestation.zip,
        "city": attestation.city,
        "exitAt": attestation.createdAt.formatDmyHm(),
        "reason": "create-attestation.reason.${attestation.reason.toValueString()}".translate(context),
      }),
      version: QrVersions.auto,
      size: this.size,
    );
  }
}

class QRCodePage extends StatelessWidget {
  final Attestation attestation;

  const QRCodePage({Key key, this.attestation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("qrcode.zoom".translate(context)),
      ),
      body: Center(
        child: QRCode(
          attestation: attestation,
          size: null,
        ),
      ),
    );
  }
}
