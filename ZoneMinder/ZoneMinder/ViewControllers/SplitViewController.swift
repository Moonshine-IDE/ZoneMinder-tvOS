//
//  SplitViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 22/12/22.
//

import Foundation
import UIKit

protocol SplitViewControllerDelegates: AnyObject
{
    func hideSidebar()
}

class SplitViewController:UISplitViewController, UISplitViewControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let sidebarController = (viewControllers[0] as! UINavigationController).viewControllers[0] as! SidebarRootMenuViewController
        sidebarController.sidebarDelegate = self
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

extension SplitViewController:SplitViewControllerDelegates
{
    func hideSidebar()
    {
        self.preferredDisplayMode = .secondaryOnly
    }
}
