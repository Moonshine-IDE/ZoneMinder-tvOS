//
//  WelcomeController.swift
//  ZoneMinder
//
//  Created by Santanu Karar on 07/12/22.
//

import UIKit

class WelcomeController: UIViewController
{
    @IBOutlet weak var allowedTVsMenuTable: UITableView!
    
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
        
        self.allowedTVsMenuTable.backgroundColor = UIColor.clear
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

extension WelcomeController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataManager.numberOfTVsInList()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tvTableViewCell") as? TVTableCellRenderer
        if let item = self.dataManager.tvItemAtIndex(itemAtIndex: indexPath.row)
        {
            cell?.textLabel?.text = item.name
            cell?.backgroundColor = UIColor.white
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        DataManager.getInstance.requestCamerasData()
        present(UIStoryboard.contentViewController()!, animated: false)
    }
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        return IndexPath(row: 0, section: 0)
    }
}

extension WelcomeController:TVsDataManagerDelegates
{
    func dataUpdated()
    {
        DispatchQueue.main.async{
            self.allowedTVsMenuTable.reloadData()
            DispatchQueue.main.async
            {
                if self.dataManager.numberOfTVsInList() > 0
                {
                    // keep first row fucused
                    self.allowedTVsMenuTable.cellForRow(at: IndexPath(row: 0, section: 0))
                }
                
                self.updateSpinnerView(show: false)
            }
        }
    }
}
