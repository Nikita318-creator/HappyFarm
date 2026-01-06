import UIKit
import AdServices
import AppsFlyerLib
import FirebaseInstallations

struct CoreConfigData {
    let attToken: String?
    let appsFlyerID: String?
    let appInstanceID: String?
    let uuid: String
    let osVersion: String
    let devModel: String
    let bundleID: String
    var fcmToken: String?
}

class BaseConfig {
    
    // MARK: - Вспомогательный метод для devModel
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let deviceModel = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        return deviceModel
    }
    
    // MARK: - Основной метод сбора данных
    func collectCoreData() async -> CoreConfigData {
        let appInstanceID = try? await Installations.installations().installationID()
        let fcmToken = UserDefaults.standard.string(forKey: "fcm_token")
        let attToken = try? AAAttribution.attributionToken()
        
        let devModel = getDeviceModel()
        let bundleID = Bundle.main.bundleIdentifier ?? "com.unknown.app"

        let appsFlyerID = AppsFlyerLib.shared().getAppsFlyerUID()
        let deviceUUID = UUID().uuidString.lowercased()
        let osVersion = UIDevice.current.systemVersion
  
        
        return CoreConfigData(
            attToken: attToken,
            appsFlyerID: appsFlyerID,
            appInstanceID: appInstanceID,
            uuid: deviceUUID,
            osVersion: osVersion,
            devModel: devModel,
            bundleID: bundleID,
            fcmToken: fcmToken
        )
    }
}
