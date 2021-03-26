package ru.krista.io.asn1.x509.ts;

import ru.krista.io.asn1.core.Asn1Binding;
import ru.krista.io.asn1.core.Struct;

public class PKIStatusInfo extends Struct {
    public static PKIStatusInfo success() {
        PKIStatusInfo res = new PKIStatusInfo();
        res.status = new PKIStatus();
        res.status.setContent(new byte[]{PKIStatus.GRANTED});
        return res;
    }


    @Asn1Binding(order = 1)
    public PKIStatus status;
    @Asn1Binding(order = 2, optional = true)
    public PKIFreeText statusString;
    @Asn1Binding(order = 3, optional = true)
    public PKIFailureInfo failInfo;
}
