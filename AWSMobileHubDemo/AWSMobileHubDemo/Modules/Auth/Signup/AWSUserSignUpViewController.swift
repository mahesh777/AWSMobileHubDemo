//
//  AWSUserSignUpViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class AWSUserSignUpViewController: UIViewController {

    // MARK: Variables
    var sentTo: String?
    var viewModel : AWSUserSignUpViewModel?
    
    // MARK: IBOutlets Variables
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AWSUserSignUpViewModel.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: Prepare Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? VerifyUserViewController {
            signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.viewModel?.pool?.getUser(self.usernameTextField.text!)
        }
    }
    
}

// MARK: AWSUserSignUpViewController Extension
extension AWSUserSignUpViewController {
    // MARK: Login Action Button event
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Signup Action Button event
    @IBAction func signUpButtonPressed(_ sender: Any) {
        // Basic Validation
        guard let userNameValue = self.usernameTextField.text, !userNameValue.isEmpty,
            let passwordValue = self.passwordTextField.text, !passwordValue.isEmpty else {
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                               message: "Username / Password are required for registration.", alertAction1: okAction,
                               alertAction2: nil)
                return
        }
        
        // Complete Validation
        if usernameTextField.text?.count == 0  {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter your valid username.",
                           alertAction1: okAction,
                           alertAction2: nil)
            
            usernameTextField.becomeFirstResponder()
        } else if emailTextField.text?.count == 0 {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter your valid email address.",
                           alertAction1: okAction,
                           alertAction2: nil)
            
            emailTextField.becomeFirstResponder()
        }  else if passwordTextField.text?.count == 0 {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter valid password.",
                           alertAction1: okAction,
                           alertAction2: nil)

            passwordTextField.becomeFirstResponder()
        } else if !((emailTextField.text?.isValidEmail)!){
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter your valid email address.",
                           alertAction1: okAction,
                           alertAction2: nil)

            emailTextField.becomeFirstResponder()
        }
        /*else if !((phoneTextField.text?.isValidPhoneNumber)!){
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            displayMessage(title: CommonAlertMessages.RequiredFieldValidationMessage,
                           message: "Please enter valid mobile number.",
                           alertAction1: okAction,
                           alertAction2: nil)

            phoneTextField.becomeFirstResponder()
        }
        */
        else {
            registerUserInAWS(username: usernameTextField.text!,
                              emailId: emailTextField.text!,
                              password: passwordTextField.text!,
                              mobile: phoneTextField.text!)
        }
    }
    
    // MARK: Register User in AWS
    /**
     Required Params : Username, Password
     Attributes: Phone No and Email
    */
    
    func registerUserInAWS(username: String,
                           emailId:String,
                           password:String,
                           mobile: String) {
        /*
        // Check for internet connection
        if (GLOBAL.sharedInstance.isInternetReachable == false) {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            displayMessage(title: CommonAlertMessages.NoInternetTitle,
                           message: CommonAlertMessages.NoInternetMessage,
                           alertAction1: okAction,
                           alertAction2: nil)
            
            return
        }
        */
        
        if let viewModel = viewModel {
            GLOBAL().showLoadingIndicatorWithMessage("")
            
            let attributes = viewModel.getAWSCognitoAttributes(phoneValue: self.phoneTextField.text ?? "",
                                                                emailValue: self.emailTextField.text ?? "")
            
            viewModel.signUpUser(userName: username,
                                 password: password,
                                 userAttributes: attributes,
                                 completionHandler: { [weak self] (task) in
                guard let strongSelf = self else { return  }
                                    
                DispatchQueue.main.async(execute: {
                    
                    GLOBAL().hideLoadingIndicator()
                    
                    if let error = task.error as NSError? {
                        strongSelf.captureSignupFailEvent(userName: strongSelf.usernameTextField.text ?? "",
                                                          emailAddress: strongSelf.emailTextField.text ?? "")
                        let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        strongSelf.displayAWSAPIErrorMessage(error: error,
                                                             alertAction: retryAction)
                    } else if let result = task.result  {
                        strongSelf.manageSignUpResponse(user: result.user,
                                             sentToType: result.codeDeliveryDetails?.destination ?? nil)
                    }
                })
                return
            })
        }
    }
    
    // MARK: Manage Signup Response
    func manageSignUpResponse(user : AWSCognitoIdentityUser,
                              sentToType : String?) {
        // handle the case where user has to confirm his identity via email / SMS
        if (user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
            sentTo = sentToType
            performSegue(withIdentifier: "confirmSignUpSegue",
                         sender:nil)
            self.captureSignupSuccessEvent(userName: usernameTextField.text ?? "",
                                           emailAddress: emailTextField.text ?? "")

        } else {
            self.captureSignupFailEvent(userName: usernameTextField.text ?? "",
                                        emailAddress: emailTextField.text ?? "")
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: AWSUserLoginViewController : Analytics Login Screen
extension AWSUserSignUpViewController {
    // MARK: Capture Signup Success Event
    func captureSignupSuccessEvent(userName : String,
                                   emailAddress: String)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.signUpSuccess)
            .addProperty(propertyName: AnalyticsAttributes.userName,
                         propertyValue: userName)
            .addProperty(propertyName: AnalyticsAttributes.emailAddress,
                         propertyValue: emailAddress)
            .build()
    }
    
    // MARK: Capture Signup Failure Event
    func captureSignupFailEvent(userName : String,
                                emailAddress: String)  {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.signUpSuccess)
            .addProperty(propertyName: AnalyticsAttributes.userName,
                         propertyValue: userName)
            .addProperty(propertyName: AnalyticsAttributes.emailAddress,
                         propertyValue: emailAddress)
            .build()
    }
}
