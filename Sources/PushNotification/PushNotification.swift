import UIKit
import UserNotifications
import FirebaseMessaging
import OSLog

public typealias Closure = () -> Void
public typealias RegisterTokenHandler = (_ fcmToken: String) async throws -> Void
public typealias WillPresentNotification = (UNNotification) -> UNNotificationPresentationOptions

open class PushNotification: NSObject {
    
    public var onNotificationReceived: Closure?
    public var willPresentNotification: WillPresentNotification?
    
    private let registerTokenHandler: RegisterTokenHandler
    
    private let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    public init(registerTokenHandler: @escaping RegisterTokenHandler) {
        self.registerTokenHandler = registerTokenHandler
    }
    
    open func getPermission(completionHandler: @escaping (Error?) -> Void  ) {
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, error in
            DispatchQueue.main.async {
                self.setup()
                completionHandler(error)
            }
        }
    }
    
    open func getToken() -> String? {
        return Messaging.messaging().fcmToken
    }

    open func updateDeviceToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    open func setup() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    open func registerFCMToken() {
        if let fcmToken = Messaging.messaging().fcmToken {
            Task {
                do {
                    try await registerTokenHandler(fcmToken)
                } catch {
                    os_log("%s", error.localizedDescription)
                }
            }
        }
    }
    
    open func unregister() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}

extension PushNotification: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let willPresentNotification = willPresentNotification {
            let options = willPresentNotification(notification)
            completionHandler(options)
        } else {
            completionHandler([.alert, .badge, .sound])
        }
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
