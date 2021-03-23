import 'dart:convert';
import 'dart:io';

import 'package:api_event/models/api_response.dart';
import 'package:crypt_signature/models/certificate.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Native {
  static const MethodChannel _channel = const MethodChannel('crypt_signature');

  static Future<bool> initCSP() async {
    try {
      bool result = await _channel.invokeMethod("initCSP");
      return result;
    } catch (exception) {
      print("Не удалось инициализировать провайдер: " + exception.toString());
      return false;
    }
  }

  static Future<ApiResponse<Certificate>> installCertificate(
      File file, String password) async {
    try {
      String certificateInfo = await _channel.invokeMethod(
          "installCert", {"pathToCert": file.path, "password": password});

      Certificate certificate =
          Certificate.fromJson(json.decode(certificateInfo));

      Directory directory = await getApplicationDocumentsDirectory();

      await file.copy(directory.path + certificate.uuid + ".pfx");

      file.delete();

      return ApiResponse.completed(certificate);
    } catch (exception) {
      return ApiResponse.error(
          "Возникла ошибка при добавлении сертификата. Проверьте правильность введенного пароля");
    }
  }

  static Future sign(
      Certificate certificate, String password, String data) async {
    try {
      final result = await _channel.invokeMethod("sign",
          {"uuid": certificate.uuid, "password": password, "data": data});

      print(result);
    } catch (exception) {
      return ApiResponse.error(
          "Возникла ошибка во время подписи. Проверьте правильность введенного пароля");
    }
  }
}
