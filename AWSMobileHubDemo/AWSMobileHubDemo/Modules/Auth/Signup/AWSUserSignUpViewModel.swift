//
//  AWSUserSignUpViewModel.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSCore

typealias CompletionHandler = (_ successResponse : AWSTask<AnyObject>) -> Void

class AWSUserSignUpViewModel {
    
    // MARK: Password Authentication Completion Handler
    var pool: AWSCognitoIdentityUserPool?
    
    init() {
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)

    }
    
    func signUpUser(userName : String,
                     password: String,
                     userAttributes: [AWSCognitoIdentityUserAttributeType],
                     completionHandler: @escaping CompletionHandler) {
        self.pool?.signUp(userName, password: password, userAttributes: userAttributes, validationData: nil).continueWith { (task) -> Any? in
            completionHandler(task as! AWSTask<AnyObject>)
            return nil
        }
    }
    
    func getAWSCognitoAttributes(phoneValue : String,
                                             emailValue: String) -> [AWSCognitoIdentityUserAttributeType]
    {
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = phoneValue
            attributes.append(phone!)
        }
        
        if !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        return attributes
    }
}
