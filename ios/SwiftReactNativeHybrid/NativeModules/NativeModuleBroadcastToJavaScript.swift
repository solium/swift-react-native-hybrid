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
    
    // These strings must match the value used in JavaScript
    static let counterChangedEvent = "SwiftCounterChanged"
    static let counterKey = "count"
    
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
        
        let counterEventInfo: [String: Any] = [counterKey: count]
        rnEventEmitter.sendEvent(withName: counterChangedEvent, body: counterEventInfo)
    }
}
