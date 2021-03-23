import 'dart:async';

import 'package:crypt_signature/ui/home.dart';
import 'package:crypt_signature/utils/fade_in_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CryptSignature {
  static const MethodChannel _channel = const MethodChannel('crypt_signature');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> sign(BuildContext context, String base64Data) async {
    await Navigator.of(context)
        .push(FadePageRoute(builder: (context) => Home()));
  }
}
