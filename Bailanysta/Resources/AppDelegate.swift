//
//  AppDelegate.swift
//  Kolesa Team
//
//  Created by Timur Kaldybek on 08.08.2024.
//

import UIKit
import FirebaseCore
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupNavigationBarBackButton()
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: GlobalConstants.revenueCatApiKey)
        Purchases.logLevel = .debug
        
        Task {
            await SubscriptionManager.shared.setupInitialState()
        }

        NotificationManager.shared.requestPermissionAndSchedule()
        NotificationManager.shared.rescheduleIfNeeded()

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
    
    private var backButtonImage: UIImage? = {
        let image = UIImage(named: "chevron-back")
        let wideScreenInitialValue: CGFloat = 414
        let leftInset: CGFloat = UIScreen.main.bounds.width < wideScreenInitialValue ? -8 : -4
        
        return image?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0))
    }()
    
}

//MARK: - Setup UIAppearance
private extension AppDelegate {
    private func setupNavigationBarBackButton() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = Color.background
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backButtonAppearance.normal.titlePositionAdjustment = Constants.backButtonOffset
        navigationBarAppearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        UINavigationBar.appearance().titleTextAttributes = nil
        UINavigationBar.appearance().tintColor = Color.text
        UINavigationBar.appearance().standardAppearance   = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance    = navigationBarAppearance
    }
    
}

// MARK: - Constants
private extension AppDelegate {
    private enum Constants {
        static let navigationBarFontSize: CGFloat = 17
        static let backButtonOffset = UIOffset(horizontal: -CGFloat.greatestFiniteMagnitude, vertical: -1)
        static let titleOffset = UIOffset(horizontal: -CGFloat.greatestFiniteMagnitude, vertical: 0)
    }
}


