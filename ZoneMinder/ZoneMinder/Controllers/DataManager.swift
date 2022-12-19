//
//  DataManager.swift
//  ZoneMinder
//
//  Created by Devsena on 13/12/22.
//

import Foundation

typealias TVItems = [TVItemVO]
typealias CameraItems = [CameraItemVO]

@objc protocol TVsDataManagerDelegates: AnyObject
{
    func dataUpdated()
    @objc optional func dataUpdateFailed(error:String)
    @objc optional func jsonHasReportedError(error:String)
}

@objc protocol CamerasDataManagerDelegates: AnyObject
{
    func dataUpdated()
    @objc optional func dataUpdateFailed(error:String)
    @objc optional func jsonHasReportedError(error:String)
}

let INSTANCE : DataManager = DataManager()
class DataManager: NSObject
{
    //let jsonURL = "https://domino-49.prominic.net/SystemHealthAlertsTestData/DemoAlertsJSON.json"
    
    var countSuccess:Int = 0
    var countFailure:Int = 0
    
    weak var tvsDelegate: TVsDataManagerDelegates!
    weak var camerasDelegate:CamerasDataManagerDelegates!
    
    fileprivate var tvItems:TVItems!
    fileprivate var cameraItems:CameraItems!
    fileprivate var groups:[String]!
    fileprivate var subgroups:[String]!
    fileprivate var sidebarRootMenuData:[[String]]!
    
    class var getInstance: DataManager
    {
        return INSTANCE
    }
    
    func requestTVsData()
    {
        self.tvItems = [TVItemVO]()
        
        // local resource
        if let localAllowedTVFile = Bundle.main.path(forResource: "AllowedTVs", ofType: "json")
        {
            guard let allowedTVsContent = NSData(contentsOfFile: localAllowedTVFile) else { return }
            do
            {
                let tvsJsonObj = try JSONSerialization.jsonObject(with: allowedTVsContent as Data, options: .allowFragments) as? Dictionary<String, AnyObject>
                
                if let reportedJSONError = tvsJsonObj!["errorMessage"] as? String
                {
                    //self.jsonData.reportedError = reportedJSONError
                }
                
                if let results = tvsJsonObj!["documents"] as? [AnyObject]
                {
                    var tvItem:TVItemVO!
                    for obj in results
                    {
                        tvItem = TVItemVO(
                            name: obj["tvName"] as? String,
                            ID: obj["ID"] as? String,
                            dominoUniversalID: obj["DominoUniversalID"] as? String,
                            cameras: obj["message"] as? [String]
                        )
                        
                        self.tvItems.append(tvItem)
                    }
                    
                    self.sortTVs()
                }
                
                if self.tvsDelegate != nil
                {
                    DispatchQueue.main.async {
                        self.tvsDelegate.dataUpdated()
                    }
                }
            }
            catch _
            {
                self.tvsDelegate.dataUpdateFailed!(error: "JSON conversion failed! You can contact to the Administrator, or wait until a reload.")
            }
        }
    }
    
    func requestCamerasData()
    {
        self.cameraItems = [CameraItemVO]()
        self.groups = [String]()
        self.subgroups = [String]()
        self.sidebarRootMenuData = [[String]]()
        
        // local resource
        if let localCameraFile = Bundle.main.path(forResource: "Cameras", ofType: "json")
        {
            guard let camerasContent = NSData(contentsOfFile: localCameraFile) else { return }
            do
            {
                let camerasJsonObj = try JSONSerialization.jsonObject(with: camerasContent as Data, options: .allowFragments) as? Dictionary<String, AnyObject>
                
                if let reportedJSONError = camerasJsonObj!["errorMessage"] as? String
                {
                    //self.jsonData.reportedError = reportedJSONError
                }
                
                if let results = camerasJsonObj!["documents"] as? [AnyObject]
                {
                    var cameraItem:CameraItemVO!
                    for obj in results
                    {
                        cameraItem = CameraItemVO(
                            dominoUniversalID: obj["DominoUniversalID"] as? String,
                            cameraID: obj["CameraID"] as? String,
                            cameraName: obj["Name"] as? String,
                            url: obj["URL"] as? String,
                            frequency: Int((obj["Frequency"] as? String)!),
                            group: obj["Group"] as? String,
                            subGroup: obj["SubGroup"] as? String
                        )
                        
                        self.cameraItems.append(cameraItem)
                        if !self.groups.contains(cameraItem.group)
                        {
                            self.groups.append(cameraItem.group)
                        }
                        if !self.subgroups.contains(cameraItem.subGroup)
                        {
                            self.subgroups.append(cameraItem.subGroup)
                        }
                    }
                    
                    self.sidebarRootMenuData.append([self.groups[0]])
                    self.sidebarRootMenuData.append([self.subgroups[0]])
                    self.sortCameras()
                }
                
                if self.camerasDelegate != nil
                {
                    DispatchQueue.main.async {
                        self.camerasDelegate.dataUpdated()
                    }
                }
            }
            catch _
            {
                self.camerasDelegate.dataUpdateFailed!(error: "JSON conversion failed! You can contact to the Administrator, or wait until a reload.")
            }
        }
    }
    
    func sortTVs()
    {
        tvItems.sort { (itemA, itemB) ->Bool in
            itemA.name < itemB.name
        }
    }
    
    func sortCameras()
    {
        cameraItems.sort { (itemA, itemB) ->Bool in
            itemA.cameraName < itemB.cameraName
        }
    }
    
    // MARK: Methods practical for a table-view
    
    func numberOfTVsInList() -> Int
    {
        return (tvItems != nil ? tvItems.count : 0)
    }
    
    func tvItemAtIndex(itemAtIndex index: Int) -> TVItemVO!
    {
        if index < tvItems.count
        {
            return tvItems[index]
        }
        
        return nil
    }
    
    func getTVItems() -> TVItems
    {
        return self.tvItems
    }
    
    // MARK: Sidebar group and subgroup items
    
    func sidebarRootMenuItems() -> [[String]]
    {
        return self.sidebarRootMenuData
    }
    
    func numberOfGroupInList() -> Int
    {
        return (self.groups != nil ? self.groups.count : 0)
    }
    
    func groupItemAtIndex(itemAtIndex index: Int) -> String!
    {
        if index < self.groups.count
        {
            return self.groups[index]
        }
        
        return nil
    }
    
    func numberOfSubGroupInList() -> Int
    {
        return (self.subgroups != nil ? self.subgroups.count : 0)
    }
    
    func subGroupItemAtIndex(itemAtIndex index: Int) -> String!
    {
        if index < self.subgroups.count
        {
            return self.subgroups[index]
        }
        
        return nil
    }
}
