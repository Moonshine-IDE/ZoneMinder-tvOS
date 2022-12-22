//
//  SplitViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 22/12/22.
//

import Foundation
import UIKit

class SplitViewController:UISplitViewController, UISplitViewControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        get
        {
            let sidebarController = viewControllers[0] as! UINavigationController
            return sidebarController.preferredFocusEnvironments
        }
    }
}
