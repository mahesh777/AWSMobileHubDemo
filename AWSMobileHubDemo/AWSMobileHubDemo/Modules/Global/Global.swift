//
//  Global.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Reachability


class GLOBAL : NSObject {
    
    //sharedInstance
    static let sharedInstance = GLOBAL()
    
    //MARK: - Internet Reachability
    var reachability: Reachability?
    var isInternetReachable : Bool? = false
    
    let isSimulator = TARGET_OS_SIMULATOR != 0
    
    override init() {
        dictionary = Dictionary < String , Any? > ()
    }
    
    var dictionary : Dictionary < String , Any? >
    
    func getGlobalValue(_ KeyToReturn : String) -> Any? {
        if let ReturnValue = dictionary[KeyToReturn]
        {
            return ReturnValue
        }
        return nil
    }
    
    
    func setupReachability(_ hostName: String?) {
        GLOBAL.sharedInstance.reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        
        NotificationCenter.default.addObserver(GLOBAL.sharedInstance, selector: #selector(reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: nil)
    }
    
    func startNotifier() {
        setupReachability("https://aws.amazon.com/")
        
        print("--- start notifier")
        
        do {
            try GLOBAL.sharedInstance.reachability?.startNotifier()
        } catch {
            print("Unable to create Reachability")
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .none {
            GLOBAL.sharedInstance.isInternetReachable = true
        } else {
            GLOBAL.sharedInstance.isInternetReachable = false
        }
    }
    
    //MARK: - Progress HUD
    
    func showLoadingIndicatorWithMessage(_ message : String){
        let hud = MBProgressHUD.showAdded(to: APPLICATION.appDelegate.window!, animated: true)
        hud.label.text = "Loading..."
        hud.label.textColor = UIColor.white
        hud.label.isHidden = false
        hud.mode = .indeterminate
        
        hud.backgroundView.color = UIColor.clear
        //hud.bezelView.color = UIColor(red: 77/255.0, green: 188/255.0, blue: 22/255.0, alpha: 0.8)
        hud.bezelView.color = UIColor(red: 29/255.0, green: 161/255.0, blue: 242/255.0, alpha: 0.8)
        hud.contentColor = UIColor.white
        
        hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor;
        
        //hud.mode =  MBProgressHUDMode.indeterminate
        
        hud.show(animated: true)
        
    }
    
    func hideLoadingIndicator(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:APPLICATION.appDelegate.window! , animated: true)
        }
    }
    
    func showLoadingIndicatorWithMessageAndUserInteraction(_ message : String,view:UIView){
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = message
    }
    
    func hideLoadingIndicatorUserInteraction(_ view:UIView){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:APPLICATION.appDelegate.window! , animated: true)
        }
    }
}
