//
//  HomeViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import WebKit

class HomeViewController: UIViewController {
    // MARK: Variables
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    // MARK: WKWebView Variable
    var webView : WKWebView!
    
    // MARK: Website URL Varible
    fileprivate static let websiteURL = "http://makeandkeep.com/"
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        self.refresh()
    }
    
    // MARK: Setup Web View
    private func setUpWebView() {
        // loading URL :
        let url = URL(string: HomeViewController.websiteURL)
        let request = URLRequest(url: url!)
        
        // Content Handler
        let contentController = WKUserContentController()
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        // Set Web View Configuration
        let config = WKWebViewConfiguration()
        let preferences = WKPreferences.init()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        config.userContentController = contentController
        
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame, configuration: config)
        webView.navigationDelegate = self
        webView.load(request)
        self.view.addSubview(webView)
        self.view.sendSubviewToBack(webView)
    }
    
    private func setMultiFactorAuth() {
        let AWSSettings = AWSCognitoIdentityUserSettings.init()
        let mfaOptions = AWSCognitoIdentityUserMFAOption.init()
        
        mfaOptions.attributeName = "email"
        mfaOptions.deliveryMedium = AWSCognitoIdentityProviderDeliveryMediumType.email
        AWSSettings.mfaOptions = [mfaOptions]
        
        user?.setUserSettings(AWSSettings)
        
        if let userName = user?.username {
            captureMultiFactorSettingsEvent(username: userName, multifactorOption: "email")
        }
    }
    
    // MARK: Navigation Right Button setup
    private func addRightButton() {
        let logoutButton = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(logoutUser))
        
        navigationItem.rightBarButtonItems = [logoutButton]
    }
    
    // MARK: Logout User
    @objc func logoutUser(sender: UIBarButtonItem) {
        // Capture Logout Event
        captureLogoutEvent(userName: (user?.username ?? ""))
        
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.refresh()
    }
    
    // MARK: Refresh AWS User with User Details API
    private func refresh() {
        GLOBAL().showLoadingIndicatorWithMessage("")
        
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                self.title = self.user?.username
                self.addRightButton()
                self.setUpWebView()
                self.setMultiFactorAuth()
            })
            
            DispatchQueue.main.async(execute: {
                GLOBAL().hideLoadingIndicator()
            })
            
            return nil
        }
    }
}

// MARK: Refresh AWS User with User Details API
extension HomeViewController : WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        GLOBAL().hideLoadingIndicator()
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        GLOBAL().showLoadingIndicatorWithMessage("")
    }
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        GLOBAL().hideLoadingIndicator()
        self.navigationItem.title = webView.title
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            print("URL of Page : \(host)")
            
            // Set Multifactor Options Event
            capturePageURLEventTrack(websiteURL: host)
        }
        decisionHandler(.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage)
    {
        if(message.name == "callbackHandler") {
            print("Action Compared")
        }
    }
}

extension HomeViewController {
    // MARK: Capture Web Page Loading Analytics
    func capturePageURLEventTrack(websiteURL : String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.websiteTrack)
        .addProperty(propertyName: AnalyticsAttributes.websiteURL, propertyValue: websiteURL)
        .build()
    }
    
    // MARK: Capture Logout Event
    func captureLogoutEvent(userName : String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.logout)
        .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
        .build()
    }
    
    // MARK: Set Multifactor Options Event
    func captureMultiFactorSettingsEvent(username: String,
                                         multifactorOption : String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.MultiFactorSettings)
        .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: username)
        .addProperty(propertyName: AnalyticsAttributes.multifactorOption, propertyValue: multifactorOption)
        .build()
    }
}
