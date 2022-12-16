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
    
    func sortTVs()
    {
        tvItems.sort { (itemA, itemB) ->Bool in
            itemA.name < itemB.name
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
}
