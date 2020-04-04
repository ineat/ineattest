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
import 'package:ineattest/views/divider.dart';
import 'package:ineattest/views/qr_code.dart';
import 'package:ineattest/views/signature.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      floatingActionButton: Offstage(
        offstage: !buttonVisibility.value,
        child: Row(
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
            HDivider8(),
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
            if (!kIsWeb) ... [
              HDivider8(),
              FloatingActionButton(
                child: Icon(Icons.share),
                onPressed: () {
                  _share(context, attestationSnapshot.data);
                },
                heroTag: "fab_share",
              )
            ]
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context, Attestation attest) async {
    final PdfGenerator generator = PdfGenerator(attest);
    final file = await generator.generatePDF(context);
    OpenFile.open(file.path);
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
            Divider12(),
            Text(
              "viewer-attestation.decree-application".translate(context),
            ),
            Divider24(),
            Text("viewer-attestation.certify-on-honor".translate(context, translationParams: {
              "lastName": attestation.lastName,
              "name": attestation.name,
              "birthday": attestation.birthday,
              "birthplace": attestation.birthplace,
              "address": attestation.address,
              "city": attestation.city,
              "zip": attestation.zip,
            })),
            Divider24(),
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _ReasonWhy(
                  attestation: attestation,
                  reason: AttestationReason.values[index],
                );
              },
              itemCount: AttestationReason.values.length,
              separatorBuilder: (context, index) => Divider12(),
            ),
            Divider36(),
            Text(
              "viewer-attestation.check-in".translate(context, translationParams: {
                "city": attestation.city,
                "date": attestation.createdAt.formatDmyHm(),
              }),
              textAlign: TextAlign.right,
            ),
            if (!kIsWeb) ... [
              Divider12(),
              AspectRatio(
                aspectRatio: 1,
                child: Signature(editable: false),
              ),
            ],
            Divider36(),
            InkWell(
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: QRCode(
                    attestation: attestation,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QRCodePage(
                      attestation: attestation,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            Divider36(),
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

class _ReasonWhy extends StatelessWidget {
  final Attestation attestation;
  final AttestationReason reason;

  const _ReasonWhy({
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
        HDivider12(),
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
