package ru.krista.io.asn1.x509.ts;

import ru.krista.io.asn1.core.Asn1Tag;
import ru.krista.io.asn1.core.Primitive;
import ru.krista.io.asn1.core.Tag;

import java.io.IOException;

@Asn1Tag(value = Tag.INTEGER)
public class PKIStatus extends Primitive {
    public static final int GRANTED = 0;
    public static final int GRANTED_WITH_MODS = 1;
    public static final int REJECTION = 2;
    public static final int WAITING = 3;
    public static final int REVOCATION_WAITING = 4;
    public static final int REVOCATION_NOTIFICATION = 5;

    public int asInt() {
        return getContent()[0] & 0xFF;
    }


    @Override
    protected void validateContent() throws IOException {
        byte[] content = getContent();
        if ((content.length != 1) || ((content[0] & 0xFF) > 5))
            throw new IOException("Ошибочное значение ситатуса ответа");
    }

}
