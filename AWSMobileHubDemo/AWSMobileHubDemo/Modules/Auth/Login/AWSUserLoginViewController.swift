//
//  ViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class AWSUserLoginViewController: UIViewController {

    // MARK: IBOutlets Variables
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // MARK: Variables
    var usernameText: String?

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    let viewModel = AWSUserLoginViewModel()
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.password.text = nil
        self.username.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: AWSUserLoginViewController Action Button Events
extension AWSUserLoginViewController {
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        if (self.username.text != nil && self.password.text != nil) {
            validateLogin()
        } else {
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)

            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter a valid user name and password",
                           alertAction1: retryAction,
                           alertAction2: nil)
        }
    }
    
    func validateLogin() {
        let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        if username.text?.count == 0  {
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter username.",
                           alertAction1: retryAction,
                           alertAction2: nil)
            
            username.becomeFirstResponder()
        } else if password.text?.count == 0 {
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter password.",
                           alertAction1: retryAction,
                           alertAction2: nil)
            password.becomeFirstResponder()
        }  else {
            verifyLoginWithAWS()
        }
    }
    
    func verifyLoginWithAWS() {
        // Check for internet connection
        /*
        if (GLOBAL.sharedInstance.isInternetReachable == false) {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            displayMessage(title: CommonAlertMessages.NoInternetTitle,
                           message: CommonAlertMessages.NoInternetMessage,
                           alertAction1: okAction,
                           alertAction2: nil)
            
            return
        }
        */
        GLOBAL().showLoadingIndicatorWithMessage("")

        viewModel.verifyLogin(userName: username.text ?? "",
                              password: password.text ?? "")
    }
}

// MARK: AWSCognitoIdentityPasswordAuthentication
extension AWSUserLoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.viewModel.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            GLOBAL().hideLoadingIndicator()
            
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            GLOBAL().hideLoadingIndicator()
            
            if let error = error as NSError? {
                self.captureLoginFailEvent(userName: self.username.text ?? "")
                let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                self.displayAWSAPIErrorMessage(error: error, alertAction: retryAction)
            } else {
                self.captureLoginSuccessEvent(userName: self.username.text ?? "")
                self.username.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: AWSUserLoginViewController : Analytics Login Screen
extension AWSUserLoginViewController {
    // MARK: Capture Login Success Event
    func captureLoginSuccessEvent(userName : String)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.loginSuccess)
            .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
            .build()
    }
    
    // MARK: Capture Login Failure Event
    func captureLoginFailEvent(userName : String)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.loginFailed)
            .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
            .build()
    }
}
