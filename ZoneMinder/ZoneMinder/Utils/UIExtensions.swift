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
}
