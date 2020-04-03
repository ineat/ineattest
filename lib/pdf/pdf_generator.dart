import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:ineattest/extensions/dateTime.dart';
import 'package:ineattest/extensions/i18n.dart';
import 'package:ineattest/model/attestation.dart';
import 'package:ineattest/preferences/preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  Document pdf;
  Attestation attestation;

  PdfGenerator(Attestation _attestation) {
    attestation = _attestation;
  }

  PdfImage checkedImage;
  PdfImage uncheckedImage;

  PdfImage signatureImage;

  Future<void> generatePDF(material.BuildContext buildContext) async {
    pdf = Document(
        theme: Theme.withFont(
      base: Font.ttf(await rootBundle.load("assets/arial.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/arial.ttf")),
      italic: Font.ttf(await rootBundle.load("assets/arial.ttf")),
      boldItalic: Font.ttf(await rootBundle.load("assets/arial.ttf")),
    ).copyWith(defaultTextStyle: TextStyle(fontSize: 11)));
    checkedImage = await pdfImageFromImageProvider(
      pdf: pdf.document,
      image: material.AssetImage('assets/checked.png'),
    );

    uncheckedImage = await pdfImageFromImageProvider(
      pdf: pdf.document,
      image: material.AssetImage('assets/unchecked.png'),
    );
    var sig = await Preferences.getSignatureImage();
    signatureImage = await pdfImageFromImageProvider(pdf: pdf.document, image: material.MemoryImage(sig));

    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Text(
                    "viewer-attestation.title".translate(buildContext),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "viewer-attestation.decree-application".translate(buildContext),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  "viewer-attestation.certify-on-honor".translate(buildContext, translationParams: {
                    "name": attestation.name,
                    "birthday": attestation.birthday,
                    "birthplace": attestation.birthplace,
                    "address": attestation.address,
                    "city": attestation.city,
                    "zip": attestation.zip,
                  }),
                ),
                SizedBox(height: 24.0),
                for (AttestationReason reason in AttestationReason.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: _ReasonWhy(
                      buildContext: buildContext,
                      attestation: attestation,
                      reason: reason,
                      checkedImage: checkedImage,
                      uncheckedImage: uncheckedImage,
                    ),
                  ),
                SizedBox(height: 12.0),
                Text(
                  "viewer-attestation.check-in".translate(buildContext, translationParams: {
                    "city": attestation.city,
                    "date": DateTime.now().formatDmyHm(),
                  }),
                ),
                SizedBox(height: 12.0),
                SizedBox(
                  child: Image(signatureImage),
                  width: 125,
                  height: 125,
                ),
                SizedBox(height: 4.0),
                for(var index = 1; index <= 3; index++) Text('viewer-attestation.nota-bene.nb-${index}'.translate(buildContext)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReasonWhy extends StatelessWidget {
  final material.BuildContext buildContext;
  final Attestation attestation;
  final AttestationReason reason;
  final PdfImage checkedImage;
  final PdfImage uncheckedImage;

  _ReasonWhy({
    this.buildContext,
    this.attestation,
    this.reason,
    this.checkedImage,
    this.uncheckedImage,
  });

  @override
  Widget build(Context context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 20,
          height: 20,
          child: Image((reason == attestation.reason) ? checkedImage : uncheckedImage, fit: BoxFit.scaleDown),
        ),
        SizedBox(
          width: 12.0,
        ),
        Flexible(
          child: Text(
            "viewer-attestation.reason.${reason.toValueString()}".translate(buildContext),
            style: TextStyle(
              fontWeight: (attestation.reason == reason) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        )
      ],
    );
  }
}
