//
//  AppDelegate.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var window: UIWindow?
    let userStuffManager = UserStuffManager.shared
    let firebaseManager = FirebaseManager.shared
    let notificationCenter = NotificationCenter.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        notificationCenter.addObserver(self, selector: #selector(setupRootVC), name: .authStatusChanged, object: nil)
        FirebaseApp.configure()
        setupAppearance()
        setupRootVC()

        return true
    }

    private func setupAppearance() {
        let navigationbar = UINavigationBar.appearance()
        let tabbar = UITabBar.appearance()

        navigationbar.barStyle = .black
        navigationbar.tintColor = .white
        navigationbar.barTintColor = .fixedFitBlue

        tabbar.tintColor = .fixedFitBlue
    }

    @objc private func setupRootVC() {
        var rootVC: UIViewController!

        if let _ = Auth.auth().currentUser {
            let mainVC = UIStoryboard.mainVC

            rootVC = mainVC
            userStuffManager.fetchUserInformation()
        } else {
            let authVC = UIStoryboard.authVC

            rootVC = authVC
        }

        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddVC {
            if let newVC = UIStoryboard.addVC, let addVC = newVC as? AddVC {
                addVC.currentTabBarController = tabBarController
                tabBarController.present(newVC, animated: true)
                return false
            }
        }

        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FixedFit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
