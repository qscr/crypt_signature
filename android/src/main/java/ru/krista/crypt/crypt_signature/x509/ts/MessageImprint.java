package ru.krista.io.asn1.x509.ts;

import ru.krista.crypt.crypt_signature.OctetString;
import ru.krista.io.asn1.core.Asn1Binding;
import ru.krista.io.asn1.core.Struct;
import ru.krista.io.asn1.x509.AlgorithmIdentifier;

/**
 * Created by shubin on 02.10.18.
 */
public class MessageImprint extends Struct {
    @Asn1Binding(order = 1)
    public AlgorithmIdentifier hashAlgorithm;
    @Asn1Binding(order = 2)
    public OctetString hashedMessage;
}
