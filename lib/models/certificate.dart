import 'package:crypt_signature/models/algorithm.dart';
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
  final Algorithm algorithm;
  final x509_certificate.X509Certificate x509certificate;

    String parameterMap;
  String certificateDescription;

  Certificate(
      {this.uuid,
      this.certificate,
      this.alias,
      this.subjectDN,
      this.notAfterDate,
      this.serialNumber,
      this.algorithm,
      this.parameterMap,
      this.certificateDescription,
      this.x509certificate});

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

  void setParams() {
    this.parameterMap = getParameterMap();
    this.certificateDescription = getCertificateDescription();
  }

  static Certificate fromJson(Map<String, dynamic> json) => Certificate(
      uuid: json["uuid"] ?? Uuid().v4(),
      certificate: json["certificate"] as String,
      alias: json['alias'] as String,
      subjectDN: json['subjectDN'] as String,
      notAfterDate: json['notAfterDate'] as String,
      serialNumber: json['serialNumber'] as String,
      algorithm: Algorithm.fromJson(json['algorithm']),
      parameterMap: json['parameterMap'] as String,
      certificateDescription: json['certificateDescription'] as String);

  static Certificate fromBase64(Map data) {
    String pem = PEM_START_STRING + data["certificate"] + PEM_END_STRING;
    x509_certificate.X509Certificate cert = x509_base.parsePem(pem).first;

    String publicKeyOID =
        cert.tbsCertificate.subjectPublicKeyInfo.algorithm.algorithm.name;
    Algorithm algorithm = Algorithm.findAlgorithmByPublicKeyOID(publicKeyOID);

    Certificate certificate = Certificate(
        uuid: Uuid().v4(),
        certificate: data["certificate"],
        alias: data["alias"],
        subjectDN: cert.tbsCertificate.subject.toString(),
        notAfterDate: cert.tbsCertificate.validity.notAfter.toString(),
        serialNumber: cert.tbsCertificate.serialNumber.toRadixString(16),
        algorithm: algorithm,
        x509certificate: cert);

    certificate.setParams();

    return certificate;
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is Certificate) &&
        other.certificate == certificate &&
        other.serialNumber == serialNumber;
  }

  String getParameterMap() {
    const String PARAMETER_SEPARATOR = "&";
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write("validFromDate=" +
        this.x509certificate.tbsCertificate.validity.notBefore.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("validToDate=" +
        this.x509certificate.tbsCertificate.validity.notAfter.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("issuer=" +
        this.x509certificate.tbsCertificate.issuer.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("subject=" +
        this.x509certificate.tbsCertificate.subject.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("subjectInfo=" +
        this.x509certificate.tbsCertificate.subject.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("issuerInfo=" +
        this.x509certificate.tbsCertificate.issuer.toString() +
        PARAMETER_SEPARATOR);
    stringBuffer.write("serialNumber=" +
        this.x509certificate.tbsCertificate.serialNumber.toRadixString(16) +
        PARAMETER_SEPARATOR);
    stringBuffer.write("signAlgoritm[name]=" +
        this.algorithm.name +
        PARAMETER_SEPARATOR);
    stringBuffer.write("signAlgoritm[oid]=" +
        this.algorithm.signatureOID +
        PARAMETER_SEPARATOR);
    stringBuffer.write("hashAlgoritm[alias]=" + this.algorithm.hashOID);

    return stringBuffer.toString();
  }

  String getCertificateDescription() {
    const String DESCRIPTION_SEPARATOR = "\n";
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write("Владелец: " +
        this.x509certificate.tbsCertificate.subject.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Серийный номер: " +
        this.x509certificate.tbsCertificate.serialNumber.toRadixString(16) +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Издатель: " +
        this.x509certificate.tbsCertificate.issuer.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Алгоритм подписи: " +
        this.algorithm.name +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Действует с: " +
        this.x509certificate.tbsCertificate.validity.notBefore.toString() +
        DESCRIPTION_SEPARATOR);
    stringBuffer.write("Действует по: " +
        this.x509certificate.tbsCertificate.validity.notAfter.toString());

    return stringBuffer.toString();
  }
}
