//
//  SidebarRootMenuViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 16/12/22.
//

import UIKit

enum MenuType:String
{
    case GROUP = "Group"
    case SUBGROUP = "Subgroup"
}

class SidebarRootMenuViewController: UITableViewController
{
    fileprivate var requireFocusedSection = 0

    var sidebarDelegate:SplitViewControllerDelegates!
    
    @objc func onHideButtonPressed()
    {
        sidebarDelegate.hideSidebar()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.remembersLastFocusedIndexPath = true
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onHideButtonPressed))
        
        self.adjustNavigationTitle()
        self.addInformationView()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        return self.tableView.preferredFocusEnvironments
    }
    
    fileprivate func addInformationView()
    {
        let informationView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 440, width: 540, height: 200))
        let informationText = UILabel()
        informationText.text = "Related information can be displayed at here. Related information can be displayed at here."
        informationText.textColor = .darkGray
        informationText.numberOfLines = 4
        informationText.font = informationText.font.withSize(30)
        informationText.textAlignment = .left
        informationView.addSubview(informationText)
        informationText.alignToSuperView()
        
        self.view.addSubview(informationView)
    }
    
    fileprivate func adjustNavigationTitle()
    {
        guard let navFrame = navigationController?.navigationBar.frame else
        {
            return
        }
            
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))
        self.navigationItem.titleView = parentView
        
        let label = UILabel(frame: .init(x: parentView.frame.minX - 60, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 40)
        label.textAlignment = .left
        label.textColor = UIColor(rgb: 0x990033)
        label.text = "CATEGORIES"
        
        parentView.addSubview(label)
    }
       
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return DataManager.getInstance.sidebarRootMenuItems().count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.getInstance.sidebarRootMenuItems()[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rootMenuTableCell", for: indexPath)
        cell.textLabel?.text = DataManager.getInstance.sidebarRootMenuItems()[indexPath.section][indexPath.row].name
        cell.insetsLayoutMarginsFromSafeArea = false
        cell.backgroundColor = .lightGray
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
       
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 0)
        {
            return "Group"
        }
            
        return "SubGroup"
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let subMenu = UIStoryboard.subMenuViewController() as! SidebarSubMenuViewController
        subMenu.groups = (indexPath.section == 0) ? DataManager.getInstance.groups : DataManager.getInstance.sidebarRootMenuItems()[0][0].subGroups
        subMenu.type = (indexPath.section == 0) ? .GROUP : .SUBGROUP
        subMenu.delegates = self
        
        self.navigationController?.pushViewController(subMenu, animated: true)
    }
    
    override func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        return IndexPath(row: 0, section: self.requireFocusedSection)
    }
}

extension SidebarRootMenuViewController: SidebarSubMenuViewControllerDelegates
{
    func onSubMenuSelected(item:Group, type:MenuType)
    {
        // this will ensure the correct menu to be
        // focused when collection reloaded next
        self.requireFocusedSection = type == .SUBGROUP ? 1 : 0
        
        if (type == .GROUP)
        {
            DataManager.getInstance.rebuildSidebarMenu(group: item, subGroup: item.subGroups[0])
        }
        else
        {
            DataManager.getInstance.rebuildSidebarMenu(group: DataManager.getInstance.sidebarRootMenuItems()[0][0], subGroup: item)
        }
        
        self.tableView.reloadData()
        DataManager.getInstance.filterCamerasByGroupSubGroups()
        DispatchQueue.main.async {
            self.tableView.selectRow(at: IndexPath(row: 0, section: self.requireFocusedSection), animated: false, scrollPosition: .none)
            self.tableView.setNeedsFocusUpdate()
            self.tableView.updateFocusIfNeeded()
        }
    }
}
