package ru.krista.io.asn1.x509.ts;

import ru.krista.crypt.crypt_signature.Int;
import ru.krista.io.asn1.core.*;

import java.io.IOException;

public class Accuracy extends Struct {
    @Asn1Binding(order = 1, optional = true)
    public Int seconds;
    @Asn1Binding(order = 2, optional = true)
    @Asn1Tag(value = Tag.CUSTOM0, cls = Tag.TagClass.CONTEXT_SPECIFIC)
    public Int millis;
    @Asn1Binding(order = 3, optional = true)
    @Asn1Tag(value = Tag.CUSTOM1, cls = Tag.TagClass.CONTEXT_SPECIFIC)
    public Int micros;

    @Override
    protected void onFieldBinded(Item item) throws IOException {
        super.onFieldBinded(item);
    }
}
