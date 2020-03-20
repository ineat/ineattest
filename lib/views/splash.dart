import 'package:ineattest/preferences/preferences.dart';
import 'package:ineattest/views/attestation_viewer.dart';
import 'package:ineattest/views/create_attestation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Splash extends HookWidget {
  Future<void> _loading(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));
    if (!(await Preferences.hasAttestation())) {
      Navigator.of(context).pushReplacement(
        _SplashPageRoute(
          builder: (_) => CreateAttestation(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        _SplashPageRoute(
          builder: (_) => AttestationViewer(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    useMemoized(() => _loading(context));
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: "poulpy",
              child: Image.asset(
                "assets/poulpymasque.png",
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              "Ine'attest",
              style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashPageRoute extends MaterialPageRoute {
  _SplashPageRoute({@required WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(milliseconds: 800);
}
