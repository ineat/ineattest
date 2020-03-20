import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

extension i18n on String {
  String translate(final BuildContext context, {final String fallbackKey, final Map<String, String> translationParams}) {
    return FlutterI18n.translate(context, this, fallbackKey: fallbackKey, translationParams: translationParams);
  }
}
