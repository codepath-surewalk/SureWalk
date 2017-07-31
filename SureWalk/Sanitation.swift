//
//  Sanitation.swift
//  SureWalk
//
//  Created by SureWalk Team on 5/21/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import UITextField_Shake

class Sanitation: NSObject {
    
    class func checkCorrectness(username: UITextField) -> UITextField? {
        //Check that UT EID contains digits
        var hasNumber = false
        var hasLetter = false
        for chr in username.text!.characters {
            if (chr >= "0" && chr <= "9") {
                hasNumber = true
            }
            if ((chr >= "a" && chr <= "z") || (chr >= "A" && chr <= "Z")) {
                hasLetter = true
            }
        }
        if !hasNumber || !hasLetter {
            return username
        }
        
        return nil
    }
    
    class func checkCorrectness(phoneNumber: UITextField) -> UITextField? {
        //Check that phone number is has 10 digits
        let sanitizedPhoneNumber = sanitizedPhone(phoneNumber: phoneNumber.text!)
        if sanitizedPhoneNumber / 1000000000 < 1 {
            return phoneNumber
        }
        
        return nil
    }
    
    class func checkCompletion(firstName: UITextField, lastName: UITextField, username: UITextField, phoneNumber: UITextField) -> UITextField? {
        var toShake: UITextField?
        
        if textFieldEmpty(textField: firstName) {
            toShake = firstName
        } else if textFieldEmpty(textField: lastName) {
            toShake = lastName
        } else if textFieldEmpty(textField: username) {
            toShake = username
        } else if textFieldEmpty(textField: phoneNumber) {
            toShake = phoneNumber
        }
        
        return toShake
    }
    
    class func checkCompletion(firstName: UITextField, lastName: UITextField, username: UITextField, phoneNumber: UITextField, password: UITextField) -> UITextField? {
        var toShake: UITextField?
        
        if textFieldEmpty(textField: firstName) {
            toShake = firstName
        } else if textFieldEmpty(textField: lastName) {
            toShake = lastName
        } else if textFieldEmpty(textField: username) {
            toShake = username
        } else if textFieldEmpty(textField: phoneNumber) {
            toShake = phoneNumber
        } else if textFieldEmpty(textField: password) {
            toShake = password
        }
        
        return toShake
    }
    
    class func textFieldEmpty(textField: UITextField) -> Bool {
        return textField.text == nil || textField.text?.characters.count == 0
    }
    
    class func sanitizedPhone(phoneNumber: String) -> Int {
        return Int(String(phoneNumber.characters.filter { "0123456789".characters.contains($0) }))!
    }
}
