import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Certificate {
  final String uuid;
  final String certificate;
  final String alias;
  final String issuerDN;
  final String notAfterDate;
  final String serialNumber;

  Certificate(
      {this.uuid,
      this.certificate,
      this.alias,
      this.issuerDN,
      this.notAfterDate,
      this.serialNumber});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return new Certificate(
        uuid: json["uuid"] ?? Uuid().v4(),
        certificate: json["certificate"] as String,
        alias: json['alias'] as String,
        issuerDN: json['issuerDN'] as String,
        notAfterDate: json['notAfterDate'] as String,
        serialNumber: json['serialNumber'] as String);
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'certificate': certificate,
        'alias': alias,
        'issuerDN': issuerDN,
        'notAfterDate': notAfterDate,
        'serialNumber': serialNumber
      };

  @override
  // TODO:
  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is Certificate) &&
        other.certificate == certificate &&
        other.serialNumber == serialNumber &&
        other.issuerDN == issuerDN;
  }

  static Future<List<Certificate>> getCertificates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> list = json.decode(prefs.getString("certificates"));

    if (list == null || list.isEmpty) return [];

    List<Certificate> certificates = [];

    for (Map certificate in list)
      certificates.add(Certificate.fromJson(certificate));

    return certificates;
  }

  static Future saveCertificates(List<Certificate> certificates) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("certificates", json.encode(certificates));
  }

  static Future<bool> addCertificate(Certificate certificate) async {
    List<Certificate> certificates = await Certificate.getCertificates();

    if (certificates.contains(certificate)) return false;

    certificates.add(certificate);

    await Certificate.saveCertificates(certificates);

    return true;
  }

  static Future<bool> removeCertificate(Certificate certificate) async {
    List<Certificate> certificates = await Certificate.getCertificates();

    if (!certificates.contains(certificate)) return false;

    certificates.remove(certificate);

    await Certificate.saveCertificates(certificates);

    return true;
  }
}
