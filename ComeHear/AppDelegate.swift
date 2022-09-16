//
//  AppDelegate.swift
//  ComeHear
//
//  Created by Pane on 2022/06/10.
//

import UIKit
import AVFoundation
import KakaoSDKCommon
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var languageCode = ""
    var loginState: LoginState = .logout
    var loginType: String?
    var userMemberIdx: Int?
    var userToken: String?
    var userNickName: String?
    var userEmail: String?
    
    var isMainLoading: Bool = true
    var authorizationState: CLAuthorizationStatus?
    var preventTap = false
    var userLogin = false {
        didSet {
            if userLogin {
                loginState = .login
                loginType = UserDefaults.standard.string(forKey: "user_loginType")
                userMemberIdx = UserDefaults.standard.integer(forKey: "user_memberIdx")
                userToken = UserDefaults.standard.string(forKey: "user_token")
                userNickName = UserDefaults.standard.string(forKey: "user_nickName")
                userEmail = UserDefaults.standard.string(forKey: "user_emil")
            } else {
                loginState = .logout
                UserDefaults.standard.removeObject(forKey: "user_login")
                UserDefaults.standard.removeObject(forKey: "user_loginType")
                UserDefaults.standard.removeObject(forKey: "user_memberIdx")
                UserDefaults.standard.removeObject(forKey: "user_token")
                UserDefaults.standard.removeObject(forKey: "user_nickName")
                UserDefaults.standard.removeObject(forKey: "user_emil")
                loginType = nil
                userMemberIdx = nil
                userToken = nil
                userNickName = nil
                userEmail = nil
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if UserDefaults.standard.bool(forKey: "user_login") {
            userLogin = true
        }
        
        let language = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as! String
        let index = language.index(language.startIndex, offsetBy: 2)
        languageCode = String(language[..<index])
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
        } catch {
#if DEBUG
            print("Failed to set audio session category.")
#endif
        }
        
        KakaoSDK.initSDK(appKey: "a836951f1196e09fcff96b01a795efd5")
            return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

}

