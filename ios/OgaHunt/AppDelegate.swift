//
//  AppDelegate.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import AEConsole
import AELog
import UIKit

let log = Logger.shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var coreDataStack = CoreDataStack(modelName: "OgaHunt")
    var window: UIWindow?
    let authService = AuthService()
    let tabBarController = AppTabBarController()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            Bundle(path: "/Applications/InjectionX.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif

        setupLogging()
        setupBackend()

        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        print("SQLite: \(path)")

        tabBarController.setupWithStack(stack: coreDataStack)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        AppAppearance.shared.set(theme: Theme.yellowishTheme())

        AppAppearance.shared.apply()

        log.info("App started successfully")

        setupNotifications()

        checkIfLoginIsRequired()

        setupSyncMaster()

        setupConsoleLogger()

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your
        // application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        checkIfLoginIsRequired()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
        // optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        coreDataStack.saveContext()
    }

    func checkIfLoginIsRequired(animated: Bool = false) {
        SignInVC.presentIfRequired(controller: window?.rootViewController, animated: animated)
    }
}

// Deal with login/logout events and present VC accordingly
extension AppDelegate {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginNotification(notification:)), name: .authLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotification(notification:)), name: .authLogout, object: nil)
    }

    @objc func loginNotification(notification _: NSNotification) {
        print("Login happened")
        // Select hunt screen
        tabBarController.selectedIndex = 0
    }

    @objc
    func logoutNotification(notification _: NSNotification) {
        print("Logout happened")
        checkIfLoginIsRequired(animated: true)
    }
}

extension AppDelegate {
    func setupSyncMaster() {
        let intervalInSeconds: TimeInterval = 5 // every 5 seconds process the full queue
        SyncMaster.global.periodicSyncEnable = false
        SyncMaster.global.startTimer(timeInterval: intervalInSeconds)
    }

    func setupLogging() {
        Logger.shared.setup()
    }

    func setupBackend() {
        let baseURL = Environment().serverURL()
        print(baseURL)
        Backend.global.setup(baseURL: baseURL)

        SyncMaster.global.setup(backend: Backend.global, coreDataStack: coreDataStack)
    }

    func setupConsoleLogger() {
        /// - Note: Access Console settings
        let settings = Console.shared.settings

        /// - Note: Customize Console settings like this, these are defaults:
        settings.isShakeGestureEnabled = false
        settings.backColor = UIColor.black
        settings.textColor = UIColor.white
        settings.fontSize = 12.0
        settings.rowSpacing = 4.0
        settings.opacity = 0.7

        /// - Note: Configure Console in app window (it's recommended to skip this for public release)
        Console.shared.configure(in: window)

        /// - Note: Log something with AELog
        aelog()
    }
}
