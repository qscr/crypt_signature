import 'package:crypt_signature/models/certificate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CertificateWidget extends StatelessWidget {
  final Certificate certificate;

  const CertificateWidget(this.certificate, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> dateSplit = certificate.notAfterDate.split(" ");
    String date = dateSplit[2] + " " + dateSplit[1] + " " + dateSplit[5];

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "№ " + certificate.serialNumber,
                  style: TextStyle(letterSpacing: -1, fontSize: 14),
                ),
                Text(
                  "Алиас: " + certificate.alias,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("Дата окончания: " + date,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(
                  "IssuerDN: " + certificate.issuerDN,
                  style: TextStyle(letterSpacing: -1, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Certificate.removeCertificate(certificate),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Icon(
                CupertinoIcons.delete,
                size: 30,
                color: CupertinoColors.systemRed,
              ),
            ))
      ],
    );
  }
}
