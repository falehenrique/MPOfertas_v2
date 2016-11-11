//
//  AppDelegate.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 04/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit
import UserNotifications

import FBSDKCoreKit
import FBSDKLoginKit

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // aplicativo ficar em segundo plano, desconecte-se do FCM:
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // NOTE: Need to use this when swizzling is disabled
    @nonobjc public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.sandbox)
        InfoLocais.deletar(chave: "tokenPush")
        if let token = FIRInstanceID.instanceID().token() {
            InfoLocais.gravarString(valor: token, chave: "tokenPush")
            print("MEU TOKEN \(FIRInstanceID.instanceID().token())")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
    // [END receive_message]
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            InfoLocais.deletar(chave: "tokenPush")
            InfoLocais.gravarString(valor: refreshedToken, chave: "tokenPush")
            InfoLocais.deletar(chave: "codigoAtivacaoUsuario")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
        // Print full message.
        print("%@", userInfo["data.tag"])
        
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
        
        print("%@", remoteMessage.appData["tag"])
        print("%@", remoteMessage.appData["text"])
        print("%@", remoteMessage.appData["title"])

        if let title = remoteMessage.appData["title"]{
            
            if  title as! String == "cupom" {
                InfoLocais.gravarString(valor: remoteMessage.appData["tag"] as! String, chave: "meuCupom")
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minhasNotificacoes"), object: nil, userInfo: remoteMessage.appData)
                
                let alertController = UIAlertController(title: "Parabéns!!!", message: "Você acabou de ganhar um cupom de desconto.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Fechar", style: .default) { (action:UIAlertAction!) in
                    
                    
                    let tabBarController = self.window?.rootViewController as! UITabBarController
                    
                    let tabArray = tabBarController.tabBar.items as NSArray!
                    
                    let tabItem = tabArray?.object(at: 2) as! UITabBarItem
                    tabItem.badgeValue = "!"
    
                }
                alertController.addAction(OKAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                
            }  else if title as! String == "oferta"  {
                /*
                let alertController = UIAlertController(title: "Alerta de oferta", message: "Acabamos de adicionar novas promoções.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Fechar", style: .default) { (action:UIAlertAction!) in
                    
                    
                    let tabBarController = self.window?.rootViewController as! UITabBarController
                    
                    let tabArray = tabBarController.tabBar.items as NSArray!
                    
                    let tabItem = tabArray?.object(at: 0) as! UITabBarItem
                    tabItem.badgeValue = "!"
                    
                }
                alertController.addAction(OKAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)*/
                
            }
        }
        
        
        
    }
}

// [END ios_10_message_handling]
