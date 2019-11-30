//
//  AWSUserLoginViewModel.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class AWSUserLoginViewModel {
    
    // MARK: Password Authentication Completion Handler
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    init() {
        
    }
    
    func verifyLogin(userName : String,
                     password: String) {
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: userName,
                                                                          password: password)
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
}
