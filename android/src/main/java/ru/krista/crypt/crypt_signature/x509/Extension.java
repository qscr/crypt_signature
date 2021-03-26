package ru.krista.io.asn1.x509;

import ru.krista.crypt.crypt_signature.Bool;
import ru.krista.crypt.crypt_signature.ObjectIdentifier;
import ru.krista.crypt.crypt_signature.OctetString;
import ru.krista.io.asn1.core.Asn1Binding;
import ru.krista.io.asn1.core.Struct;

public class Extension extends Struct {
    @Asn1Binding(order = 1)
    public ObjectIdentifier extnID;
    @Asn1Binding(order = 2, optional = true)
    public Bool critical;
    @Asn1Binding(order = 3)
    public OctetString extnValue;
}
