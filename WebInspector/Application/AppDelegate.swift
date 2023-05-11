//
//  AppDelegate.swift
//  WebInspector
//
//  Created by Robert on 24.05.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dependencyManager: DependencyManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        dependencyManager = DependencyManager(window: window!)
        
        setupNavigationBarAppearance()
        setupNavigationControllerToolbarAppearance()
        
        dependencyManager.makeLaunchAppInteractor().execute()
        
        window?.makeKeyAndVisible()
        return true
    }
    
    private func setupNavigationBarAppearance() {
        let scrollEdgeNavigationBarAppearance = UINavigationBarAppearance()
        scrollEdgeNavigationBarAppearance.backgroundColor = UIColor(named: "navBarColor")
        scrollEdgeNavigationBarAppearance.shadowColor = nil
        
        UINavigationBar.appearance().backgroundColor = UIColor(named: "navBarColor")
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeNavigationBarAppearance
    }
    
    private func setupNavigationControllerToolbarAppearance() {
        let scrollEdgeToolbarAppearance = UIToolbarAppearance()
        scrollEdgeToolbarAppearance.backgroundColor = UIColor(named: "navBarColor")
        
        let toolbarAppearance = UIToolbar.appearance(whenContainedInInstancesOf: [UINavigationController.self])
        toolbarAppearance.scrollEdgeAppearance = scrollEdgeToolbarAppearance
        toolbarAppearance.standardAppearance = scrollEdgeToolbarAppearance
        toolbarAppearance.backgroundColor = UIColor(named: "navBarColor")
        toolbarAppearance.tintColor = UIColor.init(red: 1, green: 212.0/255, blue: 121.0/255, alpha: 1)
        toolbarAppearance.barTintColor = UIColor(named: "navBarColor")
        toolbarAppearance.isOpaque = false
    }

}

