//
//  EditValueViewController.swift
//  HowMuchTrip
//
//  Created by david on 12/22/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import UIKit

protocol TripValueWasEditedDelegate
{
    func valueWasEdited(property: String, value: String?)
}

class EditValueViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var editTextField: UITextField!
    
    var delegate: TripValueWasEditedDelegate?
    
    var property: String!
    var value: Double!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ContextPopoverSetup.setup(confirmButton, cancelButton: cancelButton)
        
        topLabel.text = "Editing \(property)"
        if property == "Plane Ticket Cost"
        {
            topLabel.text = "Editing Transit Cost"
        }
        
        editTextField.delegate = self
        editTextField.placeholder = value.formatCostAsUSD()
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton)
    {
        if editTextField.text != ""
        {
            editTextField.resignFirstResponder()
            delegate?.valueWasEdited(property, value: editTextField.text!)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        editTextField.resignFirstResponder()
        delegate?.valueWasEdited(property, value: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.text != ""
        {
            delegate?.valueWasEdited(property, value: editTextField.text!)
            return true
        }
        return false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField.text != "" && confirmButton.alpha == 0 {
            confirmButton.appearWithFade(0.25)
//            textField.resignFirstResponder()
        }
        return testCharacters(textField, string: string)
    }
    
    func testCharacters(textField: UITextField, string: String) -> Bool
    {
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet //only includes 0-9
        
        if let _ = string
            .rangeOfCharacterFromSet(invalidCharacters, options: [],
                range:Range<String.Index>(start: string.startIndex, end: string.endIndex))
        {
            return false
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        addDoneButtonOnKeyboard(textField)
        return true
    }
    
    func addDoneButtonOnKeyboard(textField: UITextField!)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        //        doneToolbar.barStyle = .Black
        doneToolbar.barTintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:0.6)
        doneToolbar.translucent = false
        
//        let confirmations = [
//            "Okay",
//            "All set",
//            "Looks good"
//        ]
//        let confirmation = confirmations[Int(arc4random() % 3)]
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        flexSpace.tintColor = UIColor(red:0.18, green:0.435, blue:0.552, alpha:1)
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("doneButtonAction"))
        doneButton.tintColor = UIColor.whiteColor()
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction()
    {
        editTextField.resignFirstResponder()
    }
}
