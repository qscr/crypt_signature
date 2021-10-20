import 'package:crypt_signature/models/storage.dart';
import 'package:uuid/uuid.dart';
import 'package:crypt_signature/utils/X509Certificate/x509_base.dart'
    as x509_base;
import 'package:crypt_signature/utils/X509Certificate/certificate.dart'
    as x509_certificate;

class Certificate {
  static const String PEM_START_STRING = "-----BEGIN CERTIFICATE-----\n";
  static const String PEM_END_STRING = "\n-----END CERTIFICATE-----\n";

  static final Storage<Certificate> storage =
      new Storage<Certificate>(Certificate.fromJson);

  final String uuid;
  final String certificate;
  final String alias;
  final String subjectDN;
  final String notAfterDate;
  final String serialNumber;
  final String algorithm;
  final String parameterMap;
  final String certificateDescription;

  Certificate(
      {this.uuid,
      this.certificate,
      this.alias,
      this.subjectDN,
      this.notAfterDate,
      this.serialNumber,
      this.algorithm,
      this.parameterMap,
      this.certificateDescription});

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'certificate': certificate,
        'alias': alias,
        'subjectDN': subjectDN,
        'notAfterDate': notAfterDate,
        'serialNumber': serialNumber,
        'algorithm': algorithm,
        'parameterMap': parameterMap,
        'certificateDescription': certificateDescription
      };

  static Certificate fromJson(Map<String, dynamic> json) => Certificate(
      uuid: json["uuid"] ?? Uuid().v4(),
      certificate: json["certificate"] as String,
      alias: json['alias'] as String,
      subjectDN: json['subjectDN'] as String,
      notAfterDate: json['notAfterDate'] as String,
      serialNumber: json['serialNumber'] as String,
      algorithm: json['algorithm'] as String,
      parameterMap: json['parameterMap'] as String,
      certificateDescription: json['certificateDescription'] as String);

  static Certificate fromBase64(Map data) {
   String pem = PEM_START_STRING + data["certificate"] + PEM_END_STRING;
    x509_certificate.X509Certificate cert = x509_base.parsePem(pem).first;

    return Certificate(
      uuid: Uuid().v4(),
      certificate: data["certificate"],
      alias: data["alias"],
      subjectDN: cert.tbsCertificate.subject.toString(),
      notAfterDate: cert.tbsCertificate.validity.notAfter.toString(),
      serialNumber: cert.tbsCertificate.serialNumber.toRadixString(16),
      algorithm:
          cert.tbsCertificate.subjectPublicKeyInfo.algorithm.algorithm.name,
      parameterMap: getParameterMap(cert),
      certificateDescription: getCertificateDescription(cert),
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is Certificate) &&
        other.certificate == certificate &&
        other.serialNumber == serialNumber &&
        other.subjectDN == subjectDN;
  }

  static String getParameterMap(x509_certificate.X509Certificate certificate) {
    const String PARAMETER_SEPARATOR = "&";
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write("validFromDate=" +
        certificate.tbsCertificate.validity.notBefore.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("validToDate=" +
        certificate.tbsCertificate.validity.notAfter.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("issuer=" +
        certificate.tbsCertificate.issuer.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("subject=" +
        certificate.tbsCertificate.subject.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("subjectInfo=" +
        certificate.tbsCertificate.subject.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("issuerInfo=" +
        certificate.tbsCertificate.issuer.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("serialNumber=" +
        certificate.tbsCertificate.serialNumber.toRadixString(16) +
        PARAMETER_SEPARATOR);
    stringBuffer.write("signAlgoritm[name]=" +
        certificate.signatureAlgorithm.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("signAlgoritm[oid]=" +
        certificate.signatureAlgorithm.toString());
    //stringBuffer.write("hashAlgoritm[alias]=" + certificate.tbsCertificate.subjectPublicKeyInfo.algorithm.toString() + PARAMETER_SEPARATOR);

    return stringBuffer.toString();
  }

  static String getCertificateDescription(
      x509_certificate.X509Certificate certificate) {
    const String DESCRIPTION_SEPARATOR = "\n";
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write("Владелец: " +
        certificate.tbsCertificate.subject.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Серийный номер: " +
        certificate.tbsCertificate.serialNumber.toRadixString(16) +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Издатель: " +
        certificate.tbsCertificate.issuer.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Алгоритм подписи: " +
        certificate.signatureAlgorithm.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Действует с: " +
        certificate.tbsCertificate.validity.notBefore.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Действует по: " +
        certificate.tbsCertificate.validity.notAfter.toString() +
        DESCRIPTION_SEPARATOR);

    return stringBuffer.toString();
  }
}
