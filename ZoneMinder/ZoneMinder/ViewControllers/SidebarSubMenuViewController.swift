//
//  SidebarSubMenuViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 19/12/22.
//

import Foundation
import UIKit

protocol SidebarSubMenuViewControllerDelegates: AnyObject
{
    func onSubMenuSelected(item:Group, type:MenuType)
}

class SidebarSubMenuViewController: UITableViewController
{
    var groups:[Group]!
    var type:MenuType!
    var delegates:SidebarSubMenuViewControllerDelegates!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subMenuTableCell", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row].name
        cell.backgroundColor = .lightGray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return type == .GROUP ? "Groups" : "SubGroups"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        DataManager.getInstance.removeRunningStreams()
        
        self.delegates.onSubMenuSelected(item: self.groups[indexPath.row], type: self.type)
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        return self.tableView.preferredFocusEnvironments
    }
    
    override func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        return IndexPath(row: 0, section: 0)
    }
}
