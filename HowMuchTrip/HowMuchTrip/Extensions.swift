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
    func nsDateShortStyleAsString() -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let formattedTime = formatter.stringFromDate(self)
        return formattedTime
    }
}

extension String
{
    func stringAsNSDate() -> NSDate
    {
        return NSDate()
    }
}

extension UIImageView
{
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

extension UIView
{
    func appearWithFade(duration: Double)
    {
        self.alpha = 0
        UIView.animateWithDuration(duration) { () -> Void in
            self.alpha = 1
        }
    }
    
    func hideWithFade(duration: Double)
    {
        self.alpha = 1
        UIView.animateWithDuration(duration) { () -> Void in
            self.alpha = 0
        }
    }
    
    func slideHorizontally(duration: Double, fromPointX: CGFloat)
    {
        let originalX = self.frame.origin.x
        self.frame.origin.x += fromPointX
        UIView.animateWithDuration(duration) { () -> Void in
            self.frame.origin.x = originalX
        }
    }
    
    func slideVertically(duration: Double, fromPointY: CGFloat)
    {
        let originalY = self.frame.origin.y
        self.frame.origin.y += fromPointY
        UIView.animateWithDuration(duration) { () -> Void in
            self.frame.origin.y = originalY
        }
    }
}

// Below via:

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

/* Usage for shuffle funcs: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

    [1, 2, 3].shuffle()
    // [2, 3, 1]
    
    let fiveStrings = 0.stride(through: 100, by: 5).map(String.init).shuffle()
    // ["20", "45", "70", "30", ...]
    
    var numbers = [1, 2, 3, 4]
    numbers.shuffleInPlace()
    // [3, 2, 1, 4]

*/
