//
//  Extensions.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 06/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    var length: Int {
        return self.count
    }
    
    //To check text field or String is blank or not
    var isStringBlank: Bool {
        get {
            let trimmed =
                self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return trimmed.isEmpty
        }
    }
    
    //Validate Email
    var isValidEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^((\\w+)|(\\w+[!#$%&\'*+\\-,./=?^_`{|}~\\w]*[!#$%&\'*+\\-,/=?^_`{|}~\\w]))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,10}|[0-9]{1,3})(\\]?)$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    //validate PhoneNumber
    var isValidPhoneNumber: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^+(?:[0-9] ?){9,14}[0-9]$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    
    var isValidUserName : Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-z0-9_-]{3,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
            
        } catch {
            return false
        }
    }
    
    var isValidPassword : Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^(?=.*\\d)[A-Za-z\\d]{4,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
            
        } catch {
            return false
        }
    }
    
    func getBlankValidationMessage() -> String {
        return String.init(format: "Please enter %@.", self)
    }
    
    func getInvalidFieldValidationMessage() -> String {
        return String.init(format: "Please enter valid %@.",self)
    }
    
    func getMinCharsValidationMessage(_ length : Int) -> String {
        return String.init(format: "Please enter minimum %ld characters in %@.",length,self)
    }
    
    func getInvalidFieldValidationMessageWithSuggestion(_ suggestionRequired : String) -> String {
        return String.init(format: "Please enter valid %@ %@.", self,suggestionRequired)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension UIViewController {
    // MARK: Display Alert Message
    func displayMessage(title: String?,
                        message: String?,
                        alertAction1 : UIAlertAction,
                        alertAction2 : UIAlertAction?) {
        let alertController = UIAlertController(title: title ?? "AWS",
                                                message: message ?? "Something went wrong!",
                                                preferredStyle: .alert)
        alertController.addAction(alertAction1)
        
        if let alertAction2 = alertAction2 {
            alertController.addAction(alertAction2)
        }
        
        self.present(alertController, animated: true, completion:  nil)
    }
    
    // MARK: Display AWS API Alert message 
    func displayAWSAPIErrorMessage(error: NSError, alertAction : UIAlertAction) {
        self.displayMessage(title: error.userInfo["__type"] as? String,
                                  message: error.userInfo["message"] as? String,
                                  alertAction1: alertAction,
                                  alertAction2: nil)
    }
}
