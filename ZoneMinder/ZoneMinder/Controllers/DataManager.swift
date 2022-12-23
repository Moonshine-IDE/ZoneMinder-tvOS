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
    var groups:[Group]!
    
    weak var tvsDelegate: TVsDataManagerDelegates!
    weak var camerasDelegate:CamerasDataManagerDelegates!
    
    fileprivate var tvItems:TVItems!
    fileprivate var cameraItems:CameraItems!
    fileprivate var cameraItemsNonFiltered:CameraItems!
    fileprivate var sidebarRootMenuData:[[Group]]!
    
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
                            cameras: obj["availableCameras"] as? [String]
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
        self.groups = [Group]()
        
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
                        self.parseGroupSubgroups(cameraItem: cameraItem)
                    }
                    
                    // 1st filter - by allowed cameras to presently selcted tv
                    self.filterCamerasByAllowedTV()
                    
                    self.rebuildSidebarMenu(group: self.groups[0], subGroup: self.groups[0].subGroups[0])
                    
                    // 2nd filter - by grouop/subgroup
                    self.filterCamerasByGroupSubGroups()
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
    
    func parseGroupSubgroups(cameraItem:CameraItemVO)
    {
        var tmpGroup:Group!
        for group in self.groups
        {
            if group.name.lowercased() == cameraItem.group.lowercased()
            {
                // get group if already exists
                tmpGroup = group
                break
            }
        }
        
        // if group is not available
        if tmpGroup == nil
        {
            tmpGroup = Group()
            tmpGroup.name = cameraItem.group
            tmpGroup.subGroups = []
            self.groups.append(tmpGroup)
        }
        
        // parse for subgroups
        var tmpSubgroup:Group!
        for subgrouop in tmpGroup.subGroups
        {
            if (subgrouop.name.lowercased() == cameraItem.subGroup.lowercased())
            {
                tmpSubgroup = subgrouop
                break
            }
        }
        
        // in case subgroup is not exists
        if tmpSubgroup == nil
        {
            let tmpSubgroup = Group()
            tmpSubgroup.name = cameraItem.subGroup
            tmpGroup.subGroups.append(tmpSubgroup)
        }
    }
    
    func filterCamerasByAllowedTV()
    {
        cameraItems = cameraItems.filter { (cameraItem) -> Bool in
            return Constants.selectedTV.cameras.contains(cameraItem.cameraID)
        }
    }
    
    func filterCamerasByGroupSubGroups()
    {
        self.releaseCameraFilterByGroupSubGroups()
        
        cameraItemsNonFiltered = self.cameraItems
        cameraItems = cameraItems.filter { (cameraItem) -> Bool in
            cameraItem.group == Constants.selectedGroup.name && cameraItem.subGroup == Constants.selectedSubGroup.name
        }
        
        self.sortCameras()
    
        if self.camerasDelegate != nil
        {
            DispatchQueue.main.async {
                self.camerasDelegate.dataUpdated()
            }
        }
    }
    
    func stopAllRunningStreams()
    {
        cameraItems = [CameraItemVO]()
        
        if self.camerasDelegate != nil
        {            
            self.camerasDelegate.dataUpdated()
        }
    }
    
    func releaseCameraFilterByGroupSubGroups()
    {
        if (cameraItemsNonFiltered != nil)
        {
            self.cameraItems = self.cameraItemsNonFiltered
            cameraItemsNonFiltered = nil
        }
    }
    
    func rebuildSidebarMenu(group:Group, subGroup:Group)
    {
        self.sidebarRootMenuData = [[Group]]()
        self.sidebarRootMenuData.append([group])
        self.sidebarRootMenuData.append([subGroup])
        
        Constants.selectedGroup = group
        Constants.selectedSubGroup = subGroup
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
    
    func numberOfCamerasInList() -> Int
    {
        return (cameraItems != nil ? cameraItems.count : 0)
    }
    
    func cameraItemAtIndex(itemAtIndex index: Int) -> CameraItemVO!
    {
        if index < cameraItems.count
        {
            return cameraItems[index]
        }
        
        return nil
    }
    
    func getCameraItems() -> CameraItems
    {
        return self.cameraItems
    }
    
    // MARK: Sidebar group and subgroup items
    
    func sidebarRootMenuItems() -> [[Group]]
    {
        return self.sidebarRootMenuData
    }
    
    func numberOfGroupInList() -> Int
    {
        return (self.groups != nil ? self.groups.count : 0)
    }
    
    func groupItemAtIndex(itemAtIndex index: Int) -> Group!
    {
        if index < self.groups.count
        {
            return self.groups[index]
        }
        
        return nil
    }
}
