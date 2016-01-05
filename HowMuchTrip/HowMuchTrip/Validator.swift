//
//  Validator.swift
//  Contacts
//
//  Created by david on 11/21/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

/// Class used to validate and format various text field entries.
public class Validator
{
    /**
     Function that validates various entries into text fields.
     
     - Parameters:
        - regEx: Format to be used for validation
        - string: String to be validated

     Formats available for validation:
        - phone
        - email
        - name
        - birthday
     
     - Returns: True if 'string' passes the validation, false if the 'string' fails.
    */
    class func validate(var regEx: String, string: String) -> Bool
    {
        switch regEx
        {
            // Allow only a number in '(xxx) xxx-xxxx format'
            case "phone": regEx = "^\\(\\d{3}\\) \\d{3}-\\d{4}$"
            // Allow only numbers, letters and some characters, followed by and '@', the letters and numbers, then a '.', then 2-6 letters.
            case "email": regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            // Allow only 1-20 letters
            case "name": regEx = "^[A-Za-z]{1,20}$"
            // Allow only numbers in xx/xx/(19|20)xx format
            case "date": regEx = "^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](19|20)\\d\\d$"
            default: print("unknown regEx: " + regEx)
        }
        
        let test = NSPredicate(format: "SELF MATCHES %@", regEx)
        // Test string against regEx requirements
        let result =  test.evaluateWithObject(string)
        return result
    }
    
    /*
    
    /// Function to format a phone number as the user enters the numbers
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        //http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number
        if textField == numberTextField
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
    */
}

