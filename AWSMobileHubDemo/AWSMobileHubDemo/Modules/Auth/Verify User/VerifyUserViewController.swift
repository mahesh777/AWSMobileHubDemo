//
//  VerifyUserViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class VerifyUserViewController: UIViewController {
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let AWSuser = self.user, let username = AWSuser.username {
            self.username.text = username
        }
        
        self.sentToLabel.text = "Code sent to: \(self.sentTo!)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: IBActions
    
    // handle confirm sign up
    @IBAction func confirm(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.code.text, !confirmationCodeValue.isEmpty else {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            displayMessage(title: "Confirmation code missing.",
                           message: "Please enter a valid confirmation code.",
                           alertAction1: okAction,
                           alertAction2: nil)
            return
        }
        GLOBAL().showLoadingIndicatorWithMessage("")
        
        self.user?.confirmSignUp(self.code.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                GLOBAL().hideLoadingIndicator()
                
                if let error = task.error as NSError? {
                    strongSelf.captureVerifyUserFailedEvent(userName: strongSelf.username.text ?? "")
                    let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    strongSelf.displayAWSAPIErrorMessage(error: error, alertAction: retryAction)
                } else {
                    strongSelf.captureVerifyUserSuccessEvent(userName: strongSelf.username.text ?? "")
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { Void in
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    })
                    
                    strongSelf.displayMessage(title: "Congrats!!",
                                   message: "You are successfully verified.",
                                   alertAction1: okAction,
                                   alertAction2: nil)
                }
            })
            return nil
        }
        
    }
}

extension VerifyUserViewController {
    // handle code resend action
    @IBAction func resend(_ sender: AnyObject) {
        GLOBAL().showLoadingIndicatorWithMessage("")
        
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                GLOBAL().hideLoadingIndicator()
                
                // Capture Resend Code Event
                strongSelf.captureResendCodeAnalyticEvent(userName: strongSelf.username.text ?? "")
                
                if let error = task.error as NSError? {
                    let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    strongSelf.displayMessage(title: error.userInfo["__type"] as? String,
                                              message: error.userInfo["message"] as? String,
                                              alertAction1: retryAction,
                                              alertAction2: nil)
                } else if let result = task.result {
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

                    strongSelf.displayMessage(title: "Code Resent",
                                   message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                                   alertAction1: okAction,
                                   alertAction2: nil)
                }
            })
            return nil
        }
    }
}

extension VerifyUserViewController {
    // MARK: Capture Verify User Success Event
    func captureVerifyUserSuccessEvent(userName : String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.verifyUserSuccess)
        .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
        .build()
    }
    
    // MARK: Capture Verify User Failed Event
    func captureVerifyUserFailedEvent(userName: String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.verifyUserSuccess)
        .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
        .build()
    }
    
    // MARK: Tap Resend Code Event
    func captureResendCodeAnalyticEvent(userName: String) {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.tapResendCode)
        .addProperty(propertyName: AnalyticsAttributes.userName, propertyValue: userName)
        .build()
    }
    
}
