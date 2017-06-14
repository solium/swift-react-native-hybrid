//
//  FirstViewController.swift
//  SwiftReactNativeHybrid
//
//  Created by Jeremy Gale on 2017-06-13.
//  Copyright © 2017 Solium Capital Inc. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var count = 0
    
    @IBOutlet weak var firstViewLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var incrementButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        counterLabel.text = "Counter: \(count)"
    }

    @IBAction func incrementAndBroadcast(_ sender: Any) {
        count += 1
        counterLabel.text = "Counter: \(count)"

        // Broadcast the new count value to React Native
        NativeModuleBroadcastToJavaScript.broadcastCounterChangedEvent(count: count)
    }
}

