//
//  AnalyticsConstants.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 21/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation

// Event Names
struct AnalyticsEvent {
    static var signUpSuccess = "signup_success"
    static var loginSuccess = "signin_success"
    static var signUpFailed = "signup_failed"
    static var loginFailed = "signin_failed"
    static var forgotPassword = "forgotpassword"
    static var resetPassword = "resetpassword"
    static var verifyUserSuccess = "verifyuser_success"
    static var verifyUserFailed = "verifyuser_failed"
    static var logout = "logout"
    static var websiteTrack = "websitetrack"
    static var tapResendCode = "tapresentcode"
    static var MultiFactorSuccess = "multifactor_success"
    static var MultiFactorFailed = "multifactor_failed"
    static var MultiFactorSettings = "multifactor_settings"
}

// Event Attributes
struct AnalyticsAttributes {
    static var userName = "username"
    static var emailAddress = "emailaddress"
    static var isverified = "isverified"
    static var websiteURL = "websiteURL"
    static var isResetPasswordDone = "is_reset_password_done"
    static var multifactorOption = "multifactor_option"
}
