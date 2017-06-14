//
//  NativeModuleBroadcastToJavaScript.swift
//  SwiftReactNativeHybrid
//
//  Created by Jeremy Gale on 2017-06-13.
//  Copyright © 2017 Solium Capital Inc. All rights reserved.
//

import Foundation
import React

@objc(NativeModuleBroadcastToJavaScript)
class NativeModuleBroadcastToJavaScript: RCTEventEmitter {
    
    static let counterChangedEvent = "SwiftCounterChanged"
    
    // MARK: RCTEventEmitter
    override func supportedEvents() -> [String]! {
        return [NativeModuleBroadcastToJavaScript.counterChangedEvent]
    }
    
    static func broadcastCounterChangedEvent(count: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rnEventEmitter = appDelegate.bridge?.module(forName: "NativeModuleBroadcastToJavaScript") as? NativeModuleBroadcastToJavaScript else {
                print("NativeModuleBroadcastToJavaScript - Failed to bridge")
                return
        }
        
        let counterEventInfo: [String: Any] = ["count": count]
        rnEventEmitter.sendEvent(withName: counterChangedEvent, body: counterEventInfo)
    }
}
