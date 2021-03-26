package ru.krista.io.asn1.x509.ts;

import ru.krista.io.asn1.core.Asn1Binding;
import ru.krista.io.asn1.core.Struct;

/**
 * Ответ от сервева отпечатков времени
 */
public class TimeStampResp extends Struct {
    @Asn1Binding(order = 1)
    public PKIStatusInfo status;
    @Asn1Binding(order = 2, optional = true)
    public TimeStampToken timeStampToken;
}
