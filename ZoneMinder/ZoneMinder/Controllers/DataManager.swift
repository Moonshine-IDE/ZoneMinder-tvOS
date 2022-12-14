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

let INSTANCE : DataManager = DataManager()
class DataManager: NSObject
{
    let jsonURL = "https://aggregatorz.prominic.net/aggregator-web/TransformServlet?summary=false&iamhuman=true&template=parameterized%2Fdashboard.xsl&title=Text&format=json&asxml=true&type=Text&reportType=dashboard&viewType=default&filter_field=CustomerID&filter_string=&targetType=engine&autoload=false&timer=60"
    //let jsonURL = "https://domino-49.prominic.net/SystemHealthAlertsTestData/DemoAlertsJSON.json"
    
    var countSuccess:Int = 0
    var countFailure:Int = 0
    
    fileprivate var _averageLoadingTime:Double = 0
    var averageLoadingTime:Double
    {
        get
        {
            return (_averageLoadingTime / Double(countSuccess)).roundToDecimal(2)
        }
        set
        {
            _averageLoadingTime += newValue
        }
    }
    
    weak var tvsDelegate: TVsDataManagerDelegates!
    
    lazy var jsonData:JSONDataVO! =
    {
        return JSONDataVO()
    }()
    lazy var reloadTimerUtil:ReloadTimer! =
    {
        var rtu = ReloadTimer.getInstance
        return rtu
    }()
    
    fileprivate var tvItems:TVItems!
    fileprivate var cameraItems:CameraItems!
    fileprivate var items:AlertItems!
    fileprivate var itemsNonFiltered:AlertItems!
    fileprivate var lastAutoReloadEventSeconds:ReloadSecondsOption!
    fileprivate var loadingStartTime:Date!
    
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
                    self.jsonData.reportedError = reportedJSONError
                }
                
                if let results = tvsJsonObj!["documents"] as? [AnyObject]
                {
                    var tvItem:TVItemVO!
                    var entries:[String]!
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
    
    func numberOfItemsInList() -> Int
    {
        return (items != nil ? items.count : 0)
    }
    
    func alertItem(itemAtIndex index: Int) -> AlertItemVO!
    {
        if index < items.count
        {
            return items[index]
        }
        
        return nil
    }
    
    func getItems() -> AlertItems
    {
        return items
    }
    
    // MARK: Methods auto-refresh
    
    func startAutoRefreshTimer()
    {
        if (!self.reloadTimerUtil.isReloadTimerRunning())
        {
            self.reloadTimerUtil.startingNewAutoRefreshBy(seconds: ConstantsVO.reloadInEvent.self.rawValue)
        }
    }
    
    func restartAutoRefreshTimer()
    {
        ConstantsVO.reloadInEvent = lastAutoReloadEventSeconds
        startAutoRefreshTimer()
        
        lastAutoReloadEventSeconds = nil
    }
    
    func stopAutoRefreshTimer()
    {
        lastAutoReloadEventSeconds = ConstantsVO.reloadInEvent
        ConstantsVO.reloadInEvent = .SECONDS_0
        self.reloadTimerUtil.stopRefreshCountTimer()
    }
}
