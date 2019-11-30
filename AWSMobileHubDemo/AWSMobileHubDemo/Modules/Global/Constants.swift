//
//  Constants.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1_RSYT9nEm6"
let CognitoIdentityUserPoolAppClientId = "2s05ahlhqnl8o2q4pisbhgqu3i"
let CognitoIdentityUserPoolAppClientSecret = "2e2tumuo5augaun59kndbupr3t20hts8fvlv7ufpftlak84m4v4"

let AWSCognitoUserPoolsSignInProviderKey = "UserPool"

struct APPLICATION
{
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static var APP_STATUS_BAR_COLOR = UIColor(red: CGFloat(27.0/255.0), green: CGFloat(32.0/255.0), blue: CGFloat(42.0/255.0), alpha: 1)
    static var APP_NAVIGATION_BAR_COLOR = UIColor(red: CGFloat(41.0/255.0), green: CGFloat(48.0/255.0), blue: CGFloat(63.0/255.0), alpha: 1)
    static let applicationName = "AWSMobileHubDemo"
}

struct DYNAMICFONTSIZE {
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    
    static let IS_IPHONE_6P = UIScreen.main.bounds.height == 736.0
    static let IS_IPHONE_6 = UIScreen.main.bounds.height == 667.0
    static let IS_IPHONE_X = UIScreen.main.bounds.height == 812.0
    
    static let IS_IPHONE_5  = UIScreen.main.bounds.height == 568.0
    static let IS_IPHONE_4 = UIScreen.main.bounds.height == 480.0
    static let IPAD1_2_H  =  UIScreen.main.bounds.width == 1024.0
    static let IPAD3_H  =  UIScreen.main.bounds.width == 2048.0
    
    static var SCREEN_WIDTH = UIScreen.main.bounds.width
    static var SCREEN_HEIGHT = UIScreen.main.bounds.height
    
    static var SCALE_FACT_W_NEW : CGFloat  = SCREEN_WIDTH/375.0
    static var SCALE_FACT_H_NEW : CGFloat  = SCREEN_HEIGHT/667.0
    
    static var SCALE_FACT_H : CGFloat  = (((IS_IPAD) ? 2.20 : ((IS_IPHONE_6P) ? 1.30 : ((IS_IPHONE_6) ? 1.17 : ((IS_IPHONE_5) ? 1.00 : 1.00)))))
    
    static var SCALE_FACT_FONT : CGFloat  = (((IS_IPHONE_X) ? 1.05 : ((IS_IPHONE_6P) ? 1.10 : ((IS_IPHONE_6) ? 1.00 : ((IS_IPHONE_5) ? 0.85 : 1.00)))))
    
}

struct CommonAlertMessages {
    static var underProgressMessage = "Under progress, this feature will be available soon."
    static var SomethingWrongMessage = "Something went wrong!"
    static var APINoResultsMessage = "No results found!"
    static var RequiredFieldValidationMessage = "Missing Required Fields"
    static var NoInternetMessage = "Unable to connect to the internet."
    static var NoInternetTitle = "No Internet"
}
