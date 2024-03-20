//
//  AppDelegate.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 04/03/2024.
//

import UIKit
import CoreData
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        } catch {
            print("Couldn't init realm \(error)")
        }
        
        return true
    }

}

