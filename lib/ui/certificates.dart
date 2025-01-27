import 'dart:async';
import 'dart:io';

import 'package:crypt_signature_null_safety/exceptions/api_response_exception.dart';
import 'package:crypt_signature_null_safety/models/certificate.dart';
import 'package:crypt_signature_null_safety/native/native.dart';
import 'package:crypt_signature_null_safety/ui/certificate.dart';
import 'package:crypt_signature_null_safety/ui/dialogs.dart';
import 'package:crypt_signature_null_safety/ui/loading_widget.dart';
import 'package:crypt_signature_null_safety/ui/locker/inherited_locker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Certificates extends StatefulWidget {
  final String? hint;

  const Certificates({Key? key, this.hint}) : super(key: key);

  @override
  _CertificatesState createState() => _CertificatesState();
}

class _CertificatesState extends State<Certificates> {
  StreamController<List<Certificate>>? certificatesStreamController;

  @override
  void initState() {
    certificatesStreamController = StreamController();
    _getCertificates();
    super.initState();
  }

  @override
  void dispose() {
    certificatesStreamController?.close();
    super.dispose();
  }

  void _getCertificates() {
    List<Certificate> list = Certificate.storage.get();
    certificatesStreamController?.add(list);
  }

  Future<void> _addCertificate() async {
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["pfx"]);

    if (filePickerResult != null) {
      File? file = filePickerResult.files.single.path != null
          ? File(filePickerResult.files.single.path!)
          : null;
      String? password = await showInputDialog(
        context,
        "Введите пароль для\n распаковки сертификата",
        "Пароль",
        TextInputType.visiblePassword,
        obscureText: true,
      );

      if (password != null && password.isNotEmpty) {
        try {
          InheritedLocker.of(context)?.lockScreen?.call();
          Certificate certificate = await Native.addCertificate(file!, password);
          if (!Certificate.storage.add(certificate))
            showError(context, "Сертификат уже добавлен");
          else
            _getCertificates();
        } on ApiResponseException catch (e) {
          showError(context, e.message, details: e.details);
        } finally {
          InheritedLocker.of(context)?.unlockScreen?.call();
        }
      }
    }
  }

  Future<void> _removeCertificate(Certificate certificate) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/certificates/${certificate.uuid}.pfx";
    File file = File(filePath);
    file.delete();

    Certificate.storage.remove(certificate);

    _getCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _addCertificate();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(106, 147, 245, 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Text(
              "Добавить сертификат",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Certificate>>(
            stream: certificatesStreamController?.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();

              if (snapshot.data?.isEmpty ?? false)
                return const Center(child: Text("Список сертификатов пуст"));

              return Column(
                children: [
                  const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(widget.hint ?? '', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) =>
                          CertificateWidget(snapshot.data![index], _removeCertificate),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
