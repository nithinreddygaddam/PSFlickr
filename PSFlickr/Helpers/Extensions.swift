//
//  Extensions.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/25/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit

extension Date {
    func timeAgoDisplay() -> String {
        let secondAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        let quotient: Int
        let unit: String
        
        if secondAgo < minute {
            quotient = secondAgo
            unit = "s"
        } else if secondAgo < hour {
            quotient = secondAgo / minute
            unit = "mi"
        } else if secondAgo < day {
            quotient = secondAgo / hour
            unit = "h"
        } else if secondAgo < week {
            quotient = secondAgo / day
            unit = "d"
        } else if secondAgo < month {
            quotient = secondAgo / week
            unit = "w"
        } else if secondAgo < week{
            quotient = secondAgo / month
            unit = "mo"
        } else {
            quotient = secondAgo / year
            unit = "y"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "": "s")"
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right:NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
}
