//
//  MultiFactorAuthViewController.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 20/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class MultiFactorAuthViewController: UIViewController {
    // MARK: Variables
    var destination: String?
    var mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>?
    
    // MARK: IBOutlets Variables
    @IBOutlet weak var sentTo: UILabel!
    @IBOutlet weak var confirmationCode: UITextField!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // perform any action, if required, once the view is loaded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sentTo.text = "Code sent to: \(self.destination!)"
        self.confirmationCode.text = nil
    }
    
    // MARK: Login Button Action
    @IBAction func signIn(_ sender: AnyObject) {
        // check if the user is not providing an empty authentication code
        guard let authenticationCodeValue = self.confirmationCode.text, !authenticationCodeValue.isEmpty else {
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            displayMessage(title: "Authentication Code Missing",
                           message: "Please enter the authentication code you received by E-mail / SMS.",
                           alertAction1: okAction,
                           alertAction2: nil)
            
            return
        }
        self.mfaCodeCompletionSource?.set(result: authenticationCodeValue as NSString)
    }

}

// MARK :- AWSCognitoIdentityMultiFactorAuthentication delegate

extension MultiFactorAuthViewController : AWSCognitoIdentityMultiFactorAuthentication {
    // Did Complete Multi Factor Authentication Error Handler
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        DispatchQueue.main.async(execute: {
            if let error = error as NSError? {
                self.captureMultifactorFailedEvent()
                let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                self.displayAWSAPIErrorMessage(error: error, alertAction: retryAction)
            } else {
                self.captureMultifactorSuccessEvent()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // Get Authentication Code
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        self.mfaCodeCompletionSource = mfaCodeCompletionSource
        self.destination = authenticationInput.destination
    }
    
}

extension MultiFactorAuthViewController {
    // MARK: Capture Analytics event : Multi Factor Success
    func captureMultifactorSuccessEvent() {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.MultiFactorSuccess)
        .build()
    }
    
    // MARK: Capture Analytics event : Multi Factor Failed
    func captureMultifactorFailedEvent() {
        AnalyticsBuilder.init(withEventName: AnalyticsEvent.MultiFactorFailed)
            .build()
    }
}
