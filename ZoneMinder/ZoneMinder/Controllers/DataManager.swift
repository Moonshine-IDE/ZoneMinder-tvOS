//
//  DataManager.swift
//  ZoneMinder
//
//  Created by Devsena on 13/12/22.
//

import Foundation

typealias AlertItems = [AlertItemVO]

@objc protocol DataManagerDelegates: AnyObject
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
    
    weak var delegate: DataManagerDelegates!
    
    lazy var jsonData:JSONDataVO! =
    {
        return JSONDataVO()
    }()
    lazy var reloadTimerUtil:ReloadTimer! =
    {
        var rtu = ReloadTimer.getInstance
        return rtu
    }()
    
    fileprivate var items:AlertItems!
    fileprivate var itemsNonFiltered:AlertItems!
    fileprivate var lastAutoReloadEventSeconds:ReloadSecondsOption!
    fileprivate var loadingStartTime:Date!
    
    class var getInstance: DataManager
    {
        return INSTANCE
    }
    
    func requestData()
    {
        loadingStartTime = Date()
        items = [AlertItemVO]()
        URLSession.shared.dataTask(with: URL(string: jsonURL)!) { (data, response, err) in
            
            if (err != nil)
            {
                self.countFailure += 1
                self.delegate.dataUpdateFailed!(error: err!.localizedDescription)
            }
            else
            {
                guard let data = data else { return }
                do
                {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>
                    
                    if let reportedJSONError = jsonObj!["TextDashboard"]!["errormessage"] as? String
                    {
                        self.jsonData.reportedError = reportedJSONError
                    }
                    
                    self.delegate.jsonHasReportedError!(error: self.jsonData.reportedError)
                    
                    if let results = jsonObj!["TextDashboard"]!["report"] as? [AnyObject]
                    {
                        var alertItem:AlertItemVO!
                        var entries:[String]!
                        for obj in results
                        {
                            // json returns as non-array when it contains
                            // single item entry
                            if let singleEntry = obj["entry"] as? String
                            {
                                entries = [singleEntry]
                            }
                            else
                            {
                                entries = obj["entry"] as? [String]
                            }
                            
                            alertItem = AlertItemVO(
                                name: obj["name"] as? String,
                                message: obj["message"] as? String,
                                entries: entries,
                                critical: ((obj["critical"] as? String) == "true" ? true : false)
                            )
                            
                            self.items.append(alertItem)
                        }
                        
                        // set filteration if available
                        self.filterCriticalAlerts()
                    }
                    
                    // average loading time/seconds
                    self.countSuccess += 1
                    self.averageLoadingTime = Date().timeIntervalSince(self.loadingStartTime).roundToDecimal(2)
                    
                    if let jsonMessage = jsonObj!["TextDashboard"]!["message"] as? String
                    {
                        self.jsonData.message = jsonMessage
                    }
                    
                    if self.delegate != nil
                    {
                        DispatchQueue.main.async {
                            self.delegate.dataUpdated()
                            self.startAutoRefreshTimer()
                        }
                    }
                    
                } catch _
                {
                    self.countFailure += 1
                    if let _ = String(data: data, encoding: String.Encoding.utf8) {
                        self.delegate.dataUpdateFailed!(error: "JSON conversion failed! You can contact to the Administrator, or wait until a reload.")
                    }
                }
            }
            
        }.resume()
    }
    
    func filterCriticalAlerts()
    {
        if !ConstantsVO.showNonCriticalAlerts
        {
            itemsNonFiltered = self.items
            items = items.filter { (alertItem) -> Bool in
                alertItem.critical == true
            }
        }
    }
    
    func releaseFilterCriticalAlerts()
    {
        if (itemsNonFiltered != nil) && ConstantsVO.showNonCriticalAlerts
        {
            self.items = self.itemsNonFiltered
            itemsNonFiltered = nil
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
