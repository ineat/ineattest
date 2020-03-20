import 'package:ineattest/views/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  final FlutterI18nDelegate i18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'fr',
      basePath: 'assets/i18n',
      forcedLocale: Locale('fr'),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await i18nDelegate.load(null);
  runApp(Application(i18nDelegate: i18nDelegate));
}

class Application extends StatelessWidget {
  final FlutterI18nDelegate i18nDelegate;

  const Application({Key key, this.i18nDelegate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ine'Attest",
      theme: ThemeData(
        primaryColor: Color(0xFFef0f5f),
        accentColor: Color(0xFFef0f5f),
      ),
      home: Splash(),
      localizationsDelegates: [
        i18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
