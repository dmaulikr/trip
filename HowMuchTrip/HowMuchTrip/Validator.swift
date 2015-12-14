//
//  Validator.swift
//  Contacts
//
//  Created by david on 11/21/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import Foundation

class Validator
{
    func validate(var regEx: String, string: String) -> Bool
    {
        switch regEx
        {
        case "phone": regEx = "^\\(\\d{3}\\) \\d{3}-\\d{4}$"
        case "email": regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        case "name": regEx = "^[A-Za-z]{1,10}$"
        case "birthday": regEx = "^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](19|20)\\d\\d$"
        default: print("unknown regEx: " + regEx)
        }
        
        let test = NSPredicate(format: "SELF MATCHES %@", regEx)
        let result =  test.evaluateWithObject(string)
        return result
    }
    
    /*
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

