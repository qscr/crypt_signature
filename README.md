!!! ДОБАВИТЬ В ПРОЕКТ ПРИ ПОДКЛЮЧЕНИИ МОДУЛЯ
    packagingOptions {
        exclude 'META-INF/Digest.CP'
        exclude 'META-INF/Sign.CP'
        exclude 'META-INF/NOTICE.txt'
        exclude 'META-INF/LICENSE.txt'
        doNotStrip "*/arm64-v8a/*.so"
        doNotStrip "*/armeabi/*.so"
        doNotStrip "*/x86_64/*.so"
        doNotStrip "*/x86/*.so"
    }