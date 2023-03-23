import UIKit
import UserNotifications
import FirebaseMessaging
import NetworkInterface
import Network
import OSLog

public class PushNotification: NSObject {
    
    public var onNotificationReceived: Closure?
    let dataTransferService: AFDataTransferServiceProtocol
    
    private let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    public init(dataTransferService: AFDataTransferServiceProtocol) {
        self.dataTransferService = dataTransferService
    }
    
    public func getPermission(completionHandler: @escaping (Error?) -> Void  ) {
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, error in
            DispatchQueue.main.async {
                self.setup()
                completionHandler(error)
            }
        }
    }
    
    public func getToken() -> String? {
        return Messaging.messaging().fcmToken
    }
    
    public func updateDeviceToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    public  func setup() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    public func registerFCMToken() {
        if let fcmToken = Messaging.messaging().fcmToken {
            let query: [String: String] = ["push_token": fcmToken, "appOS": "1"]
            let endpoint = Endpoint<Dictionary<String, String>>(
                path: "savePushToken.php",
                method: .post,
                queryParameters: query
            )
            Task {
                do {
                    let response = try await dataTransferService.request(endpoint)
                    os_log("%s", response.description)
                } catch {
                    os_log("%s", error.localizedDescription)
                }
            }
        }
    }
    
    func unregister() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}

extension PushNotification: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        onNotificationReceived?()
    }
}

extension PushNotification: MessagingDelegate {
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        registerFCMToken()
    }
}

public typealias Closure = () -> Void
