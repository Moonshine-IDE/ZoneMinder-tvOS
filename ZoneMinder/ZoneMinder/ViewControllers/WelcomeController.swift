//
//  WelcomeController.swift
//  ZoneMinder
//
//  Created by Santanu Karar on 07/12/22.
//

import UIKit

class WelcomeController: UIViewController
{
    @IBOutlet weak var allowedTVsMenu: UITableView!
    
    var spinner:UIActivityIndicatorView!
    
    lazy var dataManager: DataManager! =
    {
        var dm = DataManager.getInstance
        dm.tvsDelegate = self
        return dm
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.requestData()
    }
    
    func requestData()
    {
        DispatchQueue.main.async {
            self.updateSpinnerView(show: true)
            self.dataManager.requestTVsData()
        }
    }
    
    fileprivate func updateSpinnerView(show:Bool)
    {
        if (show)
        {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = UIColor.lightGray
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

extension WelcomeController:TVsDataManagerDelegates
{
    func dataUpdated()
    {
        DispatchQueue.main.async{
            self.allowedTVsMenu.reloadData()
            DispatchQueue.main.async{
                if self.dataManager.numberOfItemsInList() > 0
                {
                    self.allowedTVsMenu.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                }

                self.updateSpinnerView(show: false)
                
                guard let tabBarController = self.tabBarController as? MenuTabBarControllerViewController else { return }
                tabBarController.dataUpdated()
            }
        }
    }
