import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ineattest/extensions/dateTime.dart';
import 'package:ineattest/extensions/i18n.dart';
import 'package:ineattest/model/attestation.dart';
import 'package:ineattest/pdf/pdf_generator.dart';
import 'package:ineattest/preferences/preferences.dart';
import 'package:ineattest/views/about_page.dart';
import 'package:ineattest/views/create_attestation.dart';
import 'package:ineattest/views/signature.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class AttestationViewer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final attestationFuture = useMemoized(() => Preferences.getAttestation());
    final attestationSnapshot = useFuture(attestationFuture);
    final buttonVisibility = useState(true);
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: EdgeInsets.all(10),
          child: Hero(
            tag: "poulpy",
            child: Image.asset(
              "assets/poulpy.png",
            ),
          ),
        ),
        title: Text("Ine'attest"),
      ),
      body: GestureDetector(
        onTap: () {
          buttonVisibility.value = !buttonVisibility.value;
        },
        child: Builder(
          builder: (context) {
            if (attestationSnapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return _AttestationContent(
              attestation: attestationSnapshot.data,
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !buttonVisibility.value
          ? Container()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton(
                  backgroundColor: Color(0xFFef0f5f),
                  child: Image(
                    width: 30.0,
                    image: AssetImage("assets/poulpy.png"),
                    fit: BoxFit.scaleDown,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutPage()));
                  },
                  heroTag: "fab_about",
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  child: Icon(Icons.text_fields),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateAttestation(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  heroTag: "fab_fields",
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  child: Icon(Icons.share),
                  onPressed: () {
                    _share(context, attestationSnapshot.data);
                  },
                  heroTag: "fab_share",
                )
              ],
            ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
  }

  void _share(BuildContext context, Attestation attest) async {
    PdfGenerator pdfGenerator = PdfGenerator(attest);
    await pdfGenerator.generatePDF(context);
    final path = await _localPath;
    final File file = File('$path/attestation.pdf');
    file.writeAsBytesSync(pdfGenerator.pdf.save());
    pdfGenerator.pdf.save();
    OpenFile.open('$path/attestation.pdf');
  }
}

class _AttestationContent extends StatelessWidget {
  final Attestation attestation;

  const _AttestationContent({Key key, @required this.attestation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "viewer-attestation.title".translate(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _SmallDivider(),
            Text(
              "viewer-attestation.decree-application".translate(context),
            ),
            _MediumDivider(),
            Text("viewer-attestation.certify-on-honor".translate(context, translationParams: {
              "name": attestation.name,
              "birthday": attestation.birthday,
              "birthplace": attestation.birthplace,
              "address": attestation.address,
              "city": attestation.city,
              "zip": attestation.zip,
            })),
            _MediumDivider(),
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ReasonWhy(
                  attestation: attestation,
                  reason: AttestationReason.values[index],
                );
              },
              itemCount: AttestationReason.values.length,
              separatorBuilder: (context, index) => _SmallDivider(),
            ),
            SizedBox(height: 36.0),
            Text(
              "viewer-attestation.check-in".translate(context, translationParams: {
                "city": attestation.city,
                "date": attestation.createdAt.formatDmyHm(),
              }),
              textAlign: TextAlign.right,
            ),
            _SmallDivider(),
            AspectRatio(
              aspectRatio: 1,
              child: Signature(
                editable: false,
              ),
            ),
            SizedBox(height: 36.0),
            ListView.separated(
              padding: const EdgeInsets.only(bottom: 96.0),
              primary: false,
              shrinkWrap: true,
              itemBuilder: (context, index) => Text('viewer-attestation.nota-bene.nb-${index + 1}'.translate(context)),
              separatorBuilder: (context, index) => Divider(color: Colors.transparent),
              itemCount: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _MediumDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
    );
  }
}

class _SmallDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12.0,
    );
  }
}

class ReasonWhy extends StatelessWidget {
  final Attestation attestation;
  final AttestationReason reason;

  const ReasonWhy({
    Key key,
    this.attestation,
    this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon((attestation.reason == reason) ? Icons.check_box : Icons.check_box_outline_blank),
        SizedBox(
          width: 12.0,
        ),
        Flexible(
          child: Text(
            "viewer-attestation.reason.${reason.toValueString()}".translate(context),
            style: TextStyle(fontWeight: (attestation.reason == reason) ? FontWeight.bold : FontWeight.normal),
          ),
        )
      ],
    );
  }
}
