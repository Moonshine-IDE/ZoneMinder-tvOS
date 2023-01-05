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
    fileprivate var spinner:UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgb: 0x333333)
        
        let sidebarController = (viewControllers[0] as! UINavigationController).viewControllers[0] as! SidebarRootMenuViewController
        sidebarController.sidebarDelegate = self
        
        let listingController = (viewControllers[1] as! UINavigationController).viewControllers[0] as! ListingViewController
        listingController.sidebarDelegate = self
        
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(menuButtonAction))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        get
        {
            let sidebarController = viewControllers[0] as! UINavigationController
            return sidebarController.preferredFocusEnvironments
        }
    }
    
    @objc func menuButtonAction()
    {
        if displayMode == .secondaryOnly
        {
            self.preferredDisplayMode = .automatic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
        else
        {
            self.updateSpinnerView(show: true)
            DataManager.getInstance.stopAllRunningStreams()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateSpinnerView(show: false)
                self.dismiss(animated: true)
            }
        }
    }
    
    fileprivate func updateSpinnerView(show:Bool)
    {
        if (show)
        {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = UIColor.darkGray
            view.addSubview(spinner)

            spinner.translatesAutoresizingMaskIntoConstraints = false
            
            spinner.centerXAnchor.constraint(equalTo: (view.centerXAnchor)).isActive = true
            spinner.centerYAnchor.constraint(equalTo: (view.centerYAnchor)).isActive = true
            spinner.startAnimating()
        }
        else if (!show)
        {
            DispatchQueue.main.async{
                self.spinner.stopAnimating()
                self.view.willRemoveSubview(self.spinner)
            }
        }
    }
}

extension SplitViewController:SplitViewControllerDelegates
{
    func hideSidebar()
    {
        if self.displayMode != .secondaryOnly
        {
            self.preferredDisplayMode = .secondaryOnly
        }
    }
}
