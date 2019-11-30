//
//  ForgotPasswordViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 20/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ForgotPasswordViewController: UIViewController {

    // MARK: Variables
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    // MARK: IBOutlets Variables
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: Prepare segue for Reset Password
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? ResetPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    
    // MARK: Back Button Event
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Forgot Password Event
    @IBAction func forgotPassword(_ sender: AnyObject) {
        guard let username = self.usernameTextField.text, !username.isEmpty else {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: "Missing UserName",
                           message: "Please enter a valid user name.",
                           alertAction1: okAction,
                           alertAction2: nil)
            return
        }
        
        GLOBAL().showLoadingIndicatorWithMessage("")
        
        self.user = self.pool?.getUser(self.usernameTextField.text!)
        
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                GLOBAL().hideLoadingIndicator()
                
                if let error = task.error as NSError? {
                    let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    strongSelf.displayAWSAPIErrorMessage(error: error, alertAction: retryAction)
                } else {
                    strongSelf.captureForgotPasswordEvent(userName: username)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { Void in
                        strongSelf.performSegue(withIdentifier: "confirmForgotPasswordSegue", sender: sender)
                    })
                    
                    strongSelf.displayMessage(title: "Forgot Password",
                                              message: "Reset code sent to email.",
                                              alertAction1: okAction,
                                              alertAction2: nil)
                }
            })
            return nil
        }
    }
}

// MARK: ForgotPasswordViewController : Analytics Forgot Password 
extension ForgotPasswordViewController {
    // MARK: Capture Forgot Password Success Event
    func captureForgotPasswordEvent(userName : String)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.forgotPassword)
            .addProperty(propertyName: AnalyticsAttributes.userName,
                         propertyValue: userName)
            .build()
    }
}
