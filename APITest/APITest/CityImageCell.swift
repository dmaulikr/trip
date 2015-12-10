//
//  CityImageCell.swift
//  APITest
//
//  Created by david on 12/9/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit

class CityImageCell: UITableViewCell
{
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y >= 0
        {
            // scrolling up
            containerView.clipsToBounds = true
            bottomSpaceConstraint?.constant = -scrollView.contentOffset.y / 2
            topSpaceConstraint?.constant = scrollView.contentOffset.y / 2
        }
        else
        {
            // scrolling down
            topSpaceConstraint?.constant = scrollView.contentOffset.y
            containerView.clipsToBounds = false
        }
    }
}

extension UIImageView
{
    func downloadImgFrom(imageURL: String, contentMode: UIViewContentMode)
    {
        print(imageURL)
        if let url = NSURL(string: imageURL)
        {
            var task: NSURLSessionDataTask!
            task = NSURLSession.sharedSession().dataTaskWithURL(url,
                completionHandler: { (data, _, error) -> Void in
                    if data != nil
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let image = UIImage(data: data!)
                            self.image = image
                            self.contentMode = contentMode
                            task.cancel()
                        })
                    }
                    else
                    {
                        print(error?.localizedDescription)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let image = UIImage(named: "image_not_found.png")
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