# PushNotification Library

`PushNotification` is a library that provides a convenient way to handle push notifications in your iOS applications. It is built on top of Apple's `UserNotifications` framework and `Firebase` Messaging service.

## Installation
### Swift Package Manager

```swift
    .package(url: "git@github.com:Paletech/iOS-Push-Notifications-Module.git", from: "1.0.0"),
```

## Usage
### Set up PushNotification

To use the `PushNotification` library, you need to create an instance of the `PushNotification` class and set its `registerTokenHandler` property to a closure that will handle the registration token.

```swift
let registerTokenHandler: RegisterTokenHandler = { fcmToken in
    // Handle the registration token
}

let pushNotification = PushNotification(registerTokenHandler: registerTokenHandler)
```

### Get Permission for Push Notification

To request permission for push notifications, you can call the getPermission method of the `PushNotification` instance. It will request authorization for the notification settings and register the app for remote notifications.

```swift
pushNotification.getPermission { error in
    // Handle the error
}
```

### Register and Unregister

To register the device for push notifications, you can call the `registerFCMToken` method of the `PushNotification` instance. It will retrieve the Firebase registration token and call the `registerTokenHandler` closure.
```swift
pushNotification.registerFCMToken()
```
To unregister the device from push notifications, you can call the unregister method of the `PushNotification` instance. It will unregister the app from remote notifications.
```swift
pushNotification.unregister()
```

### Handle Notifications

To handle incoming notifications, you can set the `onNotificationReceived` property of the `PushNotification` instance to a closure that will be called when a notification is received.

```swift
pushNotification.onNotificationReceived = {
    // Handle the notification
}
```

To handle the presentation of notifications, you can set the `willPresentNotification` property of the `PushNotification` instance to a closure that will be called when a notification is about to be presented.

```swift
pushNotification.willPresentNotification = { notification in
    // Handle the presentation
    return [.alert, .badge, .sound]
}
```
