package ru.krista.io.asn1.x509.ts;

import ru.krista.crypt.crypt_signature.Bool;
import ru.krista.crypt.crypt_signature.GeneralizedTime;
import ru.krista.crypt.crypt_signature.Int;
import ru.krista.crypt.crypt_signature.ObjectIdentifier;
import ru.krista.io.asn1.core.*;
import ru.krista.io.asn1.x509.Extensions;
import ru.krista.io.asn1.x509.GeneralName;

import java.io.IOException;

public class TSTInfo extends Struct {
    @Asn1Binding(order = 1)
    public Int version;
    @Asn1Binding(order = 2)
    public ObjectIdentifier policy;
    @Asn1Binding(order = 3)
    public MessageImprint messageImprint;
    @Asn1Binding(order = 4)
    public Int serialNumber;
    @Asn1Binding(order = 5)
    public GeneralizedTime genTime;
    @Asn1Binding(order = 6, optional = true)
    public Accuracy accuracy;
    @Asn1Binding(order = 7, optional = true)
    public Bool ordering;
    @Asn1Binding(order = 8, optional = true)
    public Int nonce;
    @Asn1Binding(order = 9, optional = true, explicit = true)
    @Asn1Tag(value = Tag.CUSTOM0, cls = Tag.TagClass.CONTEXT_SPECIFIC, type = Tag.TagType.CONSTRUCTED)
    public GeneralName tsa;
    @Asn1Binding(order = 10, optional = true)
    @Asn1Tag(value = Tag.CUSTOM1, cls = Tag.TagClass.CONTEXT_SPECIFIC, type = Tag.TagType.CONSTRUCTED)
    public Extensions extensions;

    @Override
    protected void onFieldBinded(Item item) throws IOException {
        super.onFieldBinded(item);
    }
}
