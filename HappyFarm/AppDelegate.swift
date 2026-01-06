import FirebaseCore
import AppsFlyerLib
import UIKit
import FirebaseInstallations
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        AppsFlyerLib.shared().appsFlyerDevKey = "" // test111
        AppsFlyerLib.shared().appleAppID = "6756974543"
        AppsFlyerLib.shared().start()
        
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()

        let _ = BaseUseCase.shared
        
        return true
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let dataImageURLString = UserDefaults.standard.string(forKey: "mainPropertyKeyKey") {
            BaseUseCase.shared.finalDataImageString = dataImageURLString
            return
        }
        
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "fcm_token")
            BaseUseCase.shared.setConfigData()
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let linkString = userInfo["link"] as? String,
           let url = URL(string: linkString) {
            
            UIApplication.shared.open(url, options: [:]) { success in }
            
            completionHandler(.newData)
            return
        }
        completionHandler(.noData)
    }
}
