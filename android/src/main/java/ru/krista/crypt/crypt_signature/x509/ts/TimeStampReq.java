package ru.krista.io.asn1.x509.ts;

import ru.krista.crypt.crypt_signature.Bool;
import ru.krista.crypt.crypt_signature.Int;
import ru.krista.crypt.crypt_signature.ObjectIdentifier;
import ru.krista.io.asn1.core.Asn1Binding;
import ru.krista.io.asn1.core.Struct;
import ru.krista.io.asn1.x509.Extensions;

public class TimeStampReq extends Struct {
    @Asn1Binding(order = 1)
    public Int version;
    @Asn1Binding(order = 2)
    public MessageImprint messageImprint;
    @Asn1Binding(order = 3, optional = true)
    public ObjectIdentifier reqPolicy;
    @Asn1Binding(order = 4, optional = true)
    public Int nonce;
    @Asn1Binding(order = 5, optional = true)
    public Bool certReq;
    @Asn1Binding(order = 6, optional = true)
    public Extensions extensions;
}
