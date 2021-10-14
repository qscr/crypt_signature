import Flutter
import UIKit

public class SwiftCryptSignaturePlugin: NSObject, FlutterPlugin {
    private let INIT_CSP_OK = 0;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "crypt_signature", binaryMessenger: registrar.messenger())
        let instance = SwiftCryptSignaturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "initCSP") {
            
            let resultCode = initCSP();
            if (resultCode == INIT_CSP_OK) {
                result(resultCode);
            }
            else {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Battery info unavailable",
                                    details: nil));
            }
        }
        
        result(FlutterMethodNotImplemented);
    }
}
