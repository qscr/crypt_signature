package ru.krista.io.asn1.x509.ts;

import ru.krista.crypt.crypt_signature.ObjectIdentifier;
import ru.krista.io.asn1.core.OID;
import ru.krista.io.asn1.x509.pksc7.CMSVersion;
import ru.krista.io.asn1.x509.pksc7.Pksc7ContentInfo;
import ru.krista.io.asn1.x509.pksc7.SignedData;

public class TimeStampToken extends Pksc7ContentInfo {
    public static TimeStampToken instantiate() {
        TimeStampToken res = new TimeStampToken();
        res.oid = ObjectIdentifier.withOid(OID.PKCS7_SIGNEDDATA);
        res.content = new SignedData();
        res.content.version = CMSVersion.v1();
        return res;
    }
}
