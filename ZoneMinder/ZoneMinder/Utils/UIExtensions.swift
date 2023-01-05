//
//  UIExtensions.swift
//  ZoneMinder
//
//  Created by Devsena on 16/12/22.
//

import Foundation
import UIKit

extension UIStoryboard
{
    class func mainStoryboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class func contentViewController() -> UISplitViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "listingZoneMinder") as? UISplitViewController
    }
    
    class func subMenuViewController() -> UITableViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "subMenuTableView") as? UITableViewController
    }
    
    class func cameraFSViewController() -> UIViewController?
    {
        return mainStoryboard().instantiateViewController(withIdentifier: "cameraFSView")
    }
}

extension UIView
{
    public func alignToSuperView()
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let margins = self.superview?.layoutMarginsGuide else {
            return
        }
        self.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        self.superview?.layoutIfNeeded()
    }
}

extension UIColor
{
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
