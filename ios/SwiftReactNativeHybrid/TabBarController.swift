//
//  TabBarController.swift
//  SwiftReactNativeHybrid
//
//  Created by Jeremy Gale on 2017-06-13.
//  Copyright © 2017 Solium Inc. All rights reserved.
//

import Foundation
import React

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        viewControllers = setupViewControllers()
    }

    func setupViewControllers() -> [UIViewController] {
        let firstViewController = UIStoryboard(name: "FirstViewController", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        let rnViewController = createReactNativePortfolioViewController()

        return [firstViewController, rnViewController]
    }

    func createReactNativePortfolioViewController() -> UIViewController {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = RCTRootView(bridge: delegate.bridge!, moduleName: "ReactNativeTab", initialProperties: nil)

        let reactNativeViewController = UIViewController()
        reactNativeViewController.view = rootView

        let tabBarItem = UITabBarItem(title: "Second", image: UIImage(named: "second"), selectedImage: nil)
        reactNativeViewController.tabBarItem = tabBarItem

        return reactNativeViewController
    }
}

