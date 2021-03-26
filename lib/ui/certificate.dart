import 'package:api_event/models/api_response.dart';
import 'package:crypt_signature/bloc/native.dart';
import 'package:crypt_signature/models/certificate.dart';
import 'package:crypt_signature/ui/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CertificateWidget extends StatelessWidget {
  final Certificate certificate;
  final void Function(Certificate) removeCallback;

  const CertificateWidget(this.certificate, this.removeCallback, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> dateSplit = certificate.notAfterDate.split(" ");
    String date = dateSplit[2] + " " + dateSplit[1] + " " + dateSplit[5];

    sign(Certificate certificate) async {
      String password = await showPasswordDialog(context,
          "Введите пароль для\n доступа к контейнеру приватного ключа");

      if (password != null && password.isNotEmpty) {
        ApiResponse response = await Native.sign(certificate, password);
        if (response.status == Status.COMPLETED) {
          Navigator.of(context).pop(response.data);
        } else
          showError(context,
              "Возникла ошибка во время подписи.\nПроверьте правильность введенного пароля",
              details: response.message);
      }
    }

    return GestureDetector(
      onTap: () => sign(certificate),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
        padding:
            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 0),
                  blurRadius: 0.5,
                  spreadRadius: 0.05),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 0),
                blurRadius: 5.0,
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "№" + certificate.serialNumber,
                    style: TextStyle(
                        letterSpacing: -1, fontSize: 12, color: Colors.grey),
                  ),
                ),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => removeCallback(certificate),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(
                        Icons.clear,
                        size: 14,
                        color: CupertinoColors.systemRed,
                      ),
                    ))
              ],
            ),
            Text(
              "Алиас: " + certificate.alias,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("Дата окончания: " + date,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text(
              "Информация: " + certificate.issuerDN,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
