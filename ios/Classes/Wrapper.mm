//
//  Wrapper.mm
//  KristaCrypt
//
//  Created by Кристофер Кристовский on 27.08.2020.
//  Copyright © 2020 Кристофер Кристовский. All rights reserved.
//

#import "Wrapper.h"
#include "Headers/CPROCSP.h"
#include "Headers/DisableIntegrity.h"

#define MY_ENCODING_TYPE  (PKCS_7_ASN_ENCODING | X509_ASN_ENCODING)

extern bool USE_CACHE_DIR;
bool USE_CACHE_DIR = false;

/// Инициализация провайдера и получение списка контейнеров
int initCSP()
{
    int INIT_CSP_OK = 0;
    //int INIT_CSP_LICENSE_ERROR = 1;
    int INIT_CSP_ERROR = -1;
    
    printf("\nИнициализация провайдера и получение списка контейнеров\n\n");
    
    DisableIntegrityCheck();
    
    /// Инициализация контекста
    HCRYPTPROV phProv = 0;
    
    if (!CryptAcquireContextA(&phProv, NULL, NULL, PROV_GOST_2012_256, CRYPT_SILENT | CRYPT_VERIFYCONTEXT)) {
        printf("Не удалось инициализировать context\n");
        printf("%d\n", CSP_GetLastError());
        return INIT_CSP_ERROR;
    }
    
    printf("\nКонтекст инициализирован\n");
    printf("Context HCRYPTPROV = %d\n", (LONG)phProv);
    
    /// Получение списка контейнеров
    DWORD pdwDataLen = 0;
    DWORD flag = 1;
    DWORD error_no_more_items = 259;
    
    printf("\nПолучение списка контейнеров\n\n");
    if (!CryptGetProvParam(phProv, PP_ENUMCONTAINERS, NULL, &pdwDataLen, flag)) {
        DWORD error = CSP_GetLastError();
        if (error == error_no_more_items) {
            printf("Список контейнеров пуст\n");
            CryptReleaseContext(phProv, 0);
            return INIT_CSP_ERROR;
        }
            
        printf("Не удалось получить список контейнеров\n");
        printf("%d\n", error);
        CryptReleaseContext(phProv, 0);
        return INIT_CSP_ERROR;
    }
    
    BYTE* data = (BYTE*)malloc(pdwDataLen);
    
    int i = 1;
    
    while (CryptGetProvParam(phProv, PP_ENUMCONTAINERS, data, &pdwDataLen, flag)) {
        printf("\nКонтейнер #%d\n", i);
        printf("%s\n", data);
        flag = 2;
        i++;
    };
    
    free(data);
    
    return INIT_CSP_OK;
}

bool addCert(char* pathtoCertFile, char* password) {
    printf("\nУстановка контейнера\n\n");
    
    CRYPT_DATA_BLOB certBlob;
    
    FILE *file = fopen(pathtoCertFile, "rb");
    fseek(file, 0, SEEK_END);
    certBlob.cbData = (DWORD)ftell(file);
    fseek(file, 0, SEEK_SET);
    certBlob.pbData = (BYTE*)malloc(certBlob.cbData);
    fread(certBlob.pbData, 1, certBlob.cbData, file);
    fclose(file);
    
    /// Добавление контейнера
    HCERTSTORE certStore = PFXImportCertStore(&certBlob, (LPCWSTR)password, CRYPT_SILENT | CRYPT_EXPORTABLE);
    
    if (!certStore) {
        printf("Не удалось добавить контейнер закрытого ключа");
        return false;
    } else {
        printf("\nКонтейнер успешно добавлен\n\n");
    }
    
    /// Вывод информации о сертификате
    PCCERT_CONTEXT pPrevCertContext = NULL;
    printf("Информация о сертификатах в конейнере\n");
    
    do {
        pPrevCertContext = CertEnumCertificatesInStore(certStore, pPrevCertContext);
        if (pPrevCertContext != NULL) {
            DWORD csz = CertNameToStrA(X509_ASN_ENCODING, &pPrevCertContext->pCertInfo->Subject, CERT_SIMPLE_NAME_STR, NULL, 0);
            LPSTR psz = (LPSTR)malloc(csz);
            
            CertNameToStrA(X509_ASN_ENCODING, &pPrevCertContext->pCertInfo->Subject, CERT_SIMPLE_NAME_STR, psz, csz);
            
            printf("Certificate: %s\n", psz);
            
            free(psz);
        }
    } while (pPrevCertContext != NULL);
    
    /// Закрытие certStore
    if (certStore) CertCloseStore(certStore, CERT_CLOSE_STORE_FORCE_FLAG);
    
    HCRYPTPROV hProv = 0;

    if(!CryptAcquireContext(
                            &hProv,
                            _TEXT("\\\\.\\HDIMAGE\\test"),
                            NULL,
                            PROV_GOST_2012_256,
                            CRYPT_SILENT))
    {
        printf("CryptAcquireContext error\n");
        return false;
    }

    //--------------------------------------------------------------------
    // Установка параметров в соответствии с паролем.

    printf("\nУстановка пароля на ключевой контейнер\n\n");
    
    CRYPT_PIN_PARAM param;
    param.type = CRYPT_PIN_PASSWD;
    param.dest.passwd = (char*)"123";

    if(!CryptSetProvParam(
                          hProv,
                          PP_CHANGE_PIN,
                          (BYTE*)&param,
                          0))
    {
        printf("Set pin error\n");
        wchar_t buf[256];
        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
        printf("%ls\n", buf);
        return false;
    }
    
    return true;
}

bool removeCert() {
    return false;
}

void sign() {
    printf("\nПодписание\n");
    HCRYPTPROV hProv = 0;            // Дескриптор CSP
    HCRYPTKEY hKey = 0;              // Дескриптор ключа
    HCRYPTHASH hHash = 0;
    
    BYTE *pbHash = NULL;
    BYTE *pbKeyBlob = NULL;
    BYTE *pbSignature = NULL;
    
    BYTE *pbBuffer = (BYTE *)malloc(1024);
    memset(pbBuffer, 0, 1024);
    DWORD dwBufferLen = 1024;//(DWORD)(strlen((char *)pbBuffer)+1);
    DWORD cbHash;
    DWORD dwSigLen;
    
    printf("Получение дескриптора провайдера\n");
    if(!CryptAcquireContext(
                            &hProv,
                            _TEXT("\\\\.\\HDIMAGE\\test"),
                            NULL,
                            PROV_GOST_2012_256,
                            CRYPT_SILENT))
    {
        printf("CryptAcquireContext error\n");
        return;
    }
    
    printf("Установка параметров в соответствии с паролем\n");
    if(!CryptSetProvParam(
                          hProv,
                          PP_KEYEXCHANGE_PIN,
                          (BYTE*)"123",
                          0))
    {
        printf("Set pin error\n");
        wchar_t buf[256];
        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
        printf("%ls\n", buf);
        return;
    }
    
    printf("Получение ключа обмена\n");
    if(!CryptGetUserKey(
       hProv,
       AT_KEYEXCHANGE,
       &hKey))
    {
        printf("CryptGetUserKey\n");
        wchar_t buf[256];
        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
        printf("%ls\n", buf);
        return;
    }
    
    printf("Создание объекта функции хэширования\n");
    if(!CryptCreateHash(
                        hProv,
                        CALG_GR3411_2012_256,
                        0,
                        0,
                        &hHash))
    {
        printf("CryptCreateHash error\n");
        return;
    }
    
    //--------------------------------------------------------------------
    // Передача параметра HP_OID объекта функции хэширования.
    //--------------------------------------------------------------------
    
    //--------------------------------------------------------------------
    // Определение размера BLOBа и распределение памяти.
    
    if(!CryptGetHashParam(hHash,
                          HP_OID,
                          NULL,
                          &cbHash,
                          0))
    {
        printf("CryptGetHashParam error \n");
        return;
    }
    
    pbHash = (BYTE*)malloc(cbHash);
    if(!pbHash) {
        printf("Out of memmory \n");
        return;
    }
    
    // Копирование параметра HP_OID в pbHash.
    
    if(!CryptGetHashParam(hHash,
                          HP_OID,
                          pbHash,
                          &cbHash,
                          0))
    {
        printf("CryptGetHashParam error \n");
        return;
    }
    
    //--------------------------------------------------------------------
    // Вычисление криптографического хэша буфера.
    
    if(!CryptHashData(
                      hHash,
                      pbBuffer,
                      dwBufferLen,
                      0))
    {
        printf("CryptHashData error\n");
        return;
    }
    
//    BYTE rgbHash[64];
//    CHAR rgbDigits[] = "0123456789abcdef";
//    if(!CryptGetHashParam(hHash, HP_HASHVAL, rgbHash, &cbHash, 0))
//    {
//        printf("CryptGetHashParam error \n");
//        wchar_t buf[256];
//        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
//                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
//                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
//        printf("%ls\n", buf);
//        return;
//    }
//
//    for(int i = 0; i < cbHash; i++)
//    {
//        printf("%c%c", rgbDigits[rgbHash[i] >> 4],
//            rgbDigits[rgbHash[i] & 0xf]);
//    }
//    printf("\n");
    
    //--------------------------------------------------------------------
    // Определение размера подписи и распределение памяти.
    
    if(!CryptSignHash(
                     hHash,
                     AT_KEYEXCHANGE,
                     NULL,
                     0,
                     NULL,
                     &dwSigLen))
    {
        printf("CryptSignHash error\n");
        wchar_t buf[256];
        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
        printf("%ls\n", buf);
        return;
    }
    
    wchar_t buf[256];
    CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
    printf("%ls\n", buf);
    
    //--------------------------------------------------------------------
    // Распределение памяти под буфер подписи.
    
    pbSignature = (BYTE *)malloc(dwSigLen);
    
    if(!pbSignature)
    {
        printf("Out of memmory \n");
        return;
    }
    
    // Подпись объекта функции хэширования.
    printf("Подпись объекта функции хэширования\n");
    if(!CryptSignHash(
                     hHash,
                     AT_KEYEXCHANGE,
                     NULL,
                     0,
                     pbSignature,
                     &dwSigLen))
    {
        printf("CryptSignHash error\n");
        wchar_t buf[256];
        CSP_FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, CSP_GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       buf, (sizeof(buf) / sizeof(wchar_t)), NULL);
        printf("%ls\n", buf);
        return;
    }
    
    DWORD base64Len;
    CryptBinaryToStringA(pbSignature, dwSigLen, CRYPT_STRING_BASE64, NULL, &base64Len);
    LPSTR base64String = (char*)malloc(base64Len);
    CryptBinaryToStringA(pbSignature, dwSigLen, CRYPT_STRING_BASE64, base64String, &base64Len);
    
    printf("Сигнатура: ");
    printf("%s", base64String);
    
    if(pbHash)
        free(pbHash);
    if(pbKeyBlob)
        free(pbKeyBlob);
    if(pbSignature)
        free(pbSignature);
    
    // Уничтожение объекта функции хэширования.
    if(hHash)
        CryptDestroyHash(hHash);
    
    // Уничтожение дескриптора ключа пользователя.
    
    if(hKey)
        CryptDestroyKey(hKey);
    
    // Освобождение дескриптора провайдера.
    
    if(hProv)
        CryptReleaseContext(hProv, 0);
    
    printf("The program ran to completion without error. \n");
    return;
}


enum MethodResponseCode {
    SUCCESS, ERROR
};


class MethodResponse {
public:
    MethodResponseCode code;
    char* content;
    MethodResponse(char* content, MethodResponseCode code) {
        this->code = code;
        this->content = content;
    };
};
