//
//  ResetPasswordViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 20/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ResetPasswordViewController: UIViewController {
    // MARK: Variables
    var user: AWSCognitoIdentityUser?
    
    // MARK: IBOutlets Variables
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var proposedPasswordTextField: UITextField!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: Back Button Event
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Update Password Event
    @IBAction func updatePassword(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.confirmationCodeTextField.text,
            !confirmationCodeValue.isEmpty else {
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                displayMessage(title: "Confirmation Code Field Empty",
                               message: "Please enter a confirmation code.",
                               alertAction1: okAction,
                               alertAction2: nil)
                return
        }
        
        guard let passwordValue = self.proposedPasswordTextField.text,
            !passwordValue.isEmpty else {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: "Password Field Empty",
                           message: "Please enter a password of your choice.",
                           alertAction1: okAction,
                           alertAction2: nil)
            return
        }
        
        GLOBAL().showLoadingIndicatorWithMessage("")
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue,
                                         password: self.proposedPasswordTextField.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            
            DispatchQueue.main.async(execute: {
                GLOBAL().hideLoadingIndicator()
                
                if let error = task.error as NSError? {
                    strongSelf.captureResetPasswordEvent(isDone: false)
                    let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    strongSelf.displayAWSAPIErrorMessage(error: error, alertAction: retryAction)
                } else {
                    strongSelf.captureResetPasswordEvent(isDone: true)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { Void in
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    })
                    
                    strongSelf.displayMessage(title: "Reset Password",
                                              message: "Password set successfully.",
                                              alertAction1: okAction,
                                              alertAction2: nil)
                    
                }
            })
            return nil
        }
    }
}

extension ResetPasswordViewController {
    // MARK: Capture Reset Password Success Event
    func captureResetPasswordEvent(isDone : Bool)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.resetPassword)
        .addProperty(propertyName: AnalyticsAttributes.isResetPasswordDone, propertyValue: String.init(format: "%i", isDone))
        .build()
    }
}
