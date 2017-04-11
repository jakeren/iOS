//
//  ViewController.swift
//  SettinsBundle
//
//  Created by Wei Chieh Tseng on 7/22/16.
//  Copyright © 2016 Wei Chieh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
                
        updateVersion()
        
        getChoices()
    }
    
    // MARK: Set Verion
    func updateVersion() {
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        print("version: \(version)")
        UserDefaults.standard.set(version, forKey: "version_preference")
    }
    
    // MARK: Get Choice
    func getChoices() {
        // First you should register your defaults so everything is sync'd up and defaults are assigned. Then you'll know a value exists. These values are not automatically synchronized on startup.
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["choice_preference"] = "A" as AnyObject? // default value
        
        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
        
        let choice = UserDefaults.standard.string(forKey: "choice_preference")
        
        print("choice is \(choice)")
    }


}

