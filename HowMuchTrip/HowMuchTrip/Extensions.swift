//
//  Extensions.swift
//  HowMuchTrip
//
//  Created by david on 12/13/15.
//  Copyright © 2015 HowMuchTrip. All rights reserved.
//

import Foundation

extension NSDate
{
    /// Function to format a date or time to .ShortStyle
    /// - Returns: Date as a String
    func nsDateShortStyleAsString() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let formattedTime = formatter.stringFromDate(self)
        return formattedTime
    }
}

extension Double
{
    /// Function to format a number to US currency style
    /// - Returns: Amount of $, as a String
    func formatAsUSCurrency() -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let formattedNumber = formatter.stringFromNumber(self)
        
        return formattedNumber!
    }
}

extension UIImageView
{
    /// Helper function to make downloading and formatting an image simpler and consistent
    func downloadImgFrom(imageURL: String, contentMode: UIViewContentMode)
    {
        if let url = NSURL(string: imageURL)
        {
            var task: NSURLSessionDataTask!
            task = NSURLSession.sharedSession().dataTaskWithURL(url,
                completionHandler: { (data, response, error) -> Void in
                    if data != nil
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let image = UIImage(data: data!)
                            self.image = image
                            self.contentMode = contentMode
                            task.cancel()
                        })
                    }
            })
            
            task.resume()
        }
        else
        {
            print("url \(imageURL) was invalid")
        }
    }
}

/// Extension with functions related to animation of view
extension UIView
{
    /// Function that allows a view to appear with fade animation
    func appearWithFade(duration: Double)
    {
        self.hidden = false
        self.alpha = 0
        UIView.animateWithDuration(duration) { () -> Void in
            self.alpha = 1
        }
    }
    
    /// Function that allows a view to disappear with fade animation
    func hideWithFade(duration: Double)
    {
        self.alpha = 1
        UIView.animateWithDuration(duration) { () -> Void in
            self.alpha = 0
        }
    }
    
    /// Function to horizontally slide a view from current position to original position
    func slideHorizontallyToOrigin(duration: Double, fromPointX: CGFloat)
    {
        let originalX = self.frame.origin.x
        self.frame.origin.x += fromPointX
        UIView.animateWithDuration(duration) { () -> Void in
            self.frame.origin.x = originalX
        }
    }
    
    /// Function to vertically slide a view from current position to original position
    func slideVerticallyToOrigin(duration: Double, fromPointY: CGFloat)
    {
        let originalY = self.frame.origin.y
        self.frame.origin.y += fromPointY
        UIView.animateWithDuration(duration) { () -> Void in
            self.frame.origin.y = originalY
        }
    }
    
    /// Removes an overlay view that is dimming the main view display
    func removeDimmedOverlayView()
    {
        if let dimmedOverlayView = self.viewWithTag(100)
        {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                dimmedOverlayView.alpha = 0
                }, completion: { (_) -> Void in
                    dimmedOverlayView.removeFromSuperview()
            })
        }
    }
    
    /// Adds an overlay layer to a view, dimming the view's appearance
    func addDimmedOverlayView()
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let dimmedOverlayView = UIView()
            dimmedOverlayView.frame = self.bounds
            dimmedOverlayView.backgroundColor = UIColor.blackColor()
            dimmedOverlayView.alpha = 0
            dimmedOverlayView.tag = 100
            self.addSubview(dimmedOverlayView)
            
            UIView.animateWithDuration(0.25) { () -> Void in
                dimmedOverlayView.alpha = 0.6
            }
        }
    }
    
}

extension UIViewController
{
    func addContextPopover(controllerToAdd: UIViewController)
    {
        let width = self.view.frame.width
        let height = width * 0.9
        
        let center = self.view.center
        
        controllerToAdd.view.frame = CGRect(
            x: 0, y: 0,
            width: height, height: width)
        
        controllerToAdd.view.center = CGPoint(x: center.x, y: center.y - 40)
        
        controllerToAdd.view.layer.cornerRadius = height / 30
        controllerToAdd.view.layer.masksToBounds = true
        
        self.view.addDimmedOverlayView()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.addChildViewController(controllerToAdd)
            self.view.addSubview(controllerToAdd.view)
        }
    }
    
    func dismissContextPopover(contextPopover: AnyClass) -> Bool
    {
        self.view.removeDimmedOverlayView()
        
        for viewController in self.childViewControllers
        {
            if object_getClass(viewController) == contextPopover
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    viewController.view.alpha = 0
                    }, completion: { (_) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                viewController.removeFromParentViewController()
                        })
                })
                return true
            }
        }
        
        
        
        return false
    }
}

extension Double
{
    func formatCostAsUSD() -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromNumber(self)!
    }
}


// Below via: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

/* Usage for shuffle funcs

    [1, 2, 3].shuffle()
    // [2, 3, 1]
    
    let fiveStrings = 0.stride(through: 100, by: 5).map(String.init).shuffle()
    // ["20", "45", "70", "30", ...]
    
    var numbers = [1, 2, 3, 4]
    numbers.shuffleInPlace()
    // [3, 2, 1, 4]

*/
