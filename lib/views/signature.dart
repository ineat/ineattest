import 'package:ineattest/extensions/i18n.dart';
import 'package:ineattest/preferences/preferences.dart';
import 'package:ineattest/views/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signature/signature.dart' as signature;

class Signature extends HookWidget {
  final bool editable;

  Signature({this.editable = true});

  @override
  Widget build(BuildContext context) {
    final idMemoized = useState(0);
    final signatureImageFuture = useMemoized(() => Preferences.getSignatureImage(), [idMemoized.value]);
    final signatureImageSnapshot = useFuture(signatureImageFuture);
    if (signatureImageSnapshot.connectionState != ConnectionState.done) {
      return Progress();
    } else {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Stack(
          children: <Widget>[
            signatureImageSnapshot.hasData
                ? Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Image.memory(signatureImageSnapshot.data),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "signature.create".translate(context),
                                )),
                          ),
                          Expanded(
                            child: Image.asset(
                              "assets/arrow_bottom_right.png",
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Positioned(
              bottom: 12.0,
              right: 12.0,
              child: Offstage(
                offstage: !this.editable,
                child: FloatingActionButton(
                  elevation: 0.0,
                  child: Icon(Icons.gesture),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (_) => _SignaturePage(),
                      fullscreenDialog: true,
                    );
                    Navigator.of(context).push(route).then((refresh) {
                      if (refresh ?? false) {
                        idMemoized.value = idMemoized.value + 1;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class _SignaturePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final signatureController = Hook.use(_SignatureControllerHook(
      penStrokeWidth: 2.0,
      penColor: Colors.black,
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text("signature.add".translate(context)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridPaper(
                    color: const Color(0x44C3E8F3),
                    interval: 100.0,
                    divisions: 2,
                    subdivisions: 5,
                    child: signature.Signature(
                      controller: signatureController,
                      width: constraints.biggest.width,
                      height: constraints.biggest.height,
                      backgroundColor: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: signatureController.isEmpty
          ? null
          : FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () async {
                await Preferences.saveSignature(signatureController);
                Navigator.of(context).pop(true);
              },
            ),
    );
  }
}

class _SignatureControllerHook<T> extends Hook<signature.SignatureController> {
  final Color penColor;
  final double penStrokeWidth;

  const _SignatureControllerHook({
    @required this.penColor,
    @required this.penStrokeWidth,
  });

  @override
  _SignatureControllerState<T> createState() => _SignatureControllerState<T>();
}

class _SignatureControllerState<T> extends HookState<signature.SignatureController, _SignatureControllerHook<T>> {
  signature.SignatureController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = signature.SignatureController(
      penStrokeWidth: hook.penStrokeWidth,
      penColor: hook.penColor,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  signature.SignatureController build(BuildContext context) {
    return _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
