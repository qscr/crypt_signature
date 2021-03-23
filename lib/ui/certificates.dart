import 'package:crypt_signature/models/certificate.dart';
import 'package:crypt_signature/ui/certificate.dart';
import 'package:flutter/material.dart';
import 'package:api_event/api_event.dart';

class Certificates extends StatefulWidget {
  @override
  _CertificatesState createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {
  Event<List<Certificate>> certificates = Event<List<Certificate>>();

  @override
  void initState() {
    _getCertificates();
    super.initState();
  }

  _getCertificates() async {
    List<Certificate> list = await Certificate.getCertificates();
    certificates.publish(list);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Certificate>>(
        stream: certificates.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            );

          return snapshot.data.isNotEmpty
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      CertificateWidget(snapshot.data[index]))
              : Center(child: Text("Список сертификатов пуст"));
        });
  }
}
