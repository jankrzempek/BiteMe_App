//
//  AppDelegate.swift
//  BiteMe
//
//  Created by Jan Krzempek on 09/08/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
               FirebaseApp.configure()

         let db = Firestore.firestore()
        let storage = Storage.storage()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

