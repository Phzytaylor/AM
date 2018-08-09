//
//  AppDelegate.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/14/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let hasFinishedSetup = UserDefaults.standard.bool(forKey: "hasSetup")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        
        if hasFinishedSetup{
            
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "pinScreen")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
       
        if hasFinishedSetup{
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                //print(topController.childViewControllers)
                // topController should now be your topmost view controller
                let navigationVC = self.storyboard.instantiateViewController(withIdentifier: "mainNav") as! UINavigationController
                
                
                if topController is EmptyNavatigonController{
                    print("WORKING")
                    let topOfStack = topController.navigationController?.topViewController
                    let vc = self.storyboard.instantiateViewController(withIdentifier: "pinScreen") as! PinViewController
                    topController.present(vc, animated: true, completion: nil)
                } else{
              
                    
                    guard let me = self.window?.rootViewController else {return}
                   
                let vc = self.storyboard.instantiateViewController(withIdentifier: "pinScreen") as! PinViewController
                    
                    print("Hi \(topController)")
                    
                    if me is PinViewController {
                        print("YAY")
                    } else {
                    
                    
//
                    topController.present(vc, animated: true, completion: nil)
                    }
                    
                }
                
                
            }
                
            }
            
            
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "AfterMemoModel")
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
    
    // MARK: - Core Data Saving Support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges{
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

