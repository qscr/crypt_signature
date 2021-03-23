package ru.krista.crypt.crypt_signature;

import android.content.Context;
import android.util.Base64;

import androidx.annotation.NonNull;

import org.json.simple.JSONObject;

import java.io.FileInputStream;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.logging.Logger;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import ru.CryptoPro.JCP.JCP;
import ru.CryptoPro.JCSP.CSPConfig;
import ru.CryptoPro.JCSP.JCSP;

/** CryptSignaturePlugin */
public class CryptSignaturePlugin implements FlutterPlugin, MethodCallHandler {
    private Context context;
    private final Logger log = Logger.getLogger(this.getClass().getName());
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "crypt_signature");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initCSP": {
                boolean resulty = initCSP();

                if (resulty)
                    result.success(null);
                else result.error("ERROR", null, null);
                break;
            }
            case "sign": {
                String uuid = call.argument("uuid");
                String password = call.argument("password");
                String data = call.argument("data");

                MethodResponse<String> resulty = sign(uuid, password, data);

                if (resulty.code == MethodResponseCode.SUCCESS)
                    result.success(resulty.content);
                else result.error("ERROR", new String(resulty.content), null);
                break;
            }
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private boolean initCSP() {
        log.info("Инициализация провайдера CSP");

        int initCode = CSPConfig.initEx(context);

        if (initCode == CSPConfig.CSP_INIT_OK) {
            log.info("Провайдер инициализирован");
            return true;
        } else {
            log.info("Провайдер не инициализирован");
            return false;
        }
    }

    private MethodResponse<String> sign(String uuid, String password, String base64Data) {
        try {
            log.info("Данные " + base64Data);
            byte[] data = Base64.decode(base64Data, Base64.DEFAULT);

            MessageDigest md = MessageDigest.getInstance(
                    JCP.GOST_DIGEST_2012_256_NAME, /// TODO: должен быть как у ключа
                    JCSP.PROVIDER_NAME
            );
            md.update(data);
            byte[] digest = md.digest();

            log.info("Хэш " + Arrays.toString(digest));

            KeyStore keyStorePFX = KeyStore.getInstance(JCSP.PFX_STORE_NAME, JCSP.PROVIDER_NAME);
            InputStream fileInputStream = new FileInputStream(context.getFilesDir().getPath() + "/" + uuid + ".pfx");

            keyStorePFX.load(fileInputStream, password.toCharArray());

            String alias = null;
            Enumeration<String> aliasesPFX = keyStorePFX.aliases();

            while (aliasesPFX.hasMoreElements()) {
                String aliasPFX = aliasesPFX.nextElement();
                if (keyStorePFX.isKeyEntry(aliasPFX))
                    alias = aliasPFX;
            }

            if (alias != null) {
                log.info("Сертификат '" + alias + "' распакован");
                PrivateKey privateKey = (PrivateKey) keyStorePFX.getKey(alias, password.toCharArray());

                log.info(JCP.RAW_PREFIX + "with" + privateKey.getAlgorithm());

                Signature signature = Signature.getInstance(JCP.GOST_DIGEST_2012_256_NAME + "with" + privateKey.getAlgorithm(), JCSP.PROVIDER_NAME);
                signature.initSign(privateKey);
                signature.update(digest);
                byte[] sign = signature.sign();


                X509Certificate certificate = (X509Certificate) keyStorePFX.getCertificate(alias);

                JSONObject contentJson = new JSONObject();
                contentJson.put("data", base64Data);
                contentJson.put("certificate", Base64.encodeToString(certificate.getEncoded(), Base64.DEFAULT));
                contentJson.put("digestOID", JCP.GOST_DIGEST_2012_256_OID);
                contentJson.put("sign", Base64.encodeToString(sign, Base64.DEFAULT));

                return new MethodResponse<String>(contentJson.toString(), MethodResponseCode.SUCCESS);
            } else {
                log.info("Сертификат не распакован");
                throw new Exception("Ошибка при импорте *.pfx сертификата");
            }
        } catch (Exception exception) {
            log.info("Ошибка при чтении сертификата");
            return new MethodResponse<String>("Ошибка: " + exception.toString(), MethodResponseCode.ERROR);
        }
    }
}

class MethodResponse<T> {
    T content;
    MethodResponseCode code;

    public MethodResponse(T content, MethodResponseCode code) {
        this.content = content;
        this.code = code;
    }
}

enum MethodResponseCode {
    SUCCESS,
    ERROR
}