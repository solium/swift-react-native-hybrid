//
//  NativeModuleJavaScriptCallback.swift
//  SwiftReactNativeHybrid
//
//  Created by Jeremy Gale on 2017-06-13.
//  Copyright © 2017 Solium Capital Inc. All rights reserved.
//

import Foundation
import React

@objc(NativeModuleJavaScriptCallback)
class NativeModuleJavaScriptCallback: NSObject {
    
    // This key must match the value used in JavaScript
    static let swiftButtonEnabledKey = "swiftButtonEnabled"
    
    func toggleSwiftButtonEnabled( _ callback: @escaping RCTResponseSenderBlock) {
        // You won't be on the main thread when called from JavaScript
        DispatchQueue.main.async {
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController,
                let firstViewController = tabBarController.viewControllers?.first as? FirstViewController else {
                    return
            }
            
            let newEnabledState = !firstViewController.incrementButton.isEnabled
            firstViewController.incrementButton.isEnabled = newEnabledState
            
            let callbackInfo = [NativeModuleJavaScriptCallback.swiftButtonEnabledKey: newEnabledState]
            callback([callbackInfo])
        }
    }
}
