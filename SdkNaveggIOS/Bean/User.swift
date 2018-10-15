//
//  User.swift
//  SdkNavegg
//
//  Created by Navegg on 14/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation

class User {
    var userId : String?
    var accountId : Int
    var util = Util()
    var defaults  : UserDefaults
    let context : AnyObject
    var listPageView = [PageViewer]()
    var listCustom = [Int]()
    var onBoarding:OnBoarding
    let ws = WebService()
    var dateLastSync:Date?=nil
    var customListPermanent = [Int]()
    
    var jsonSegments = [String:String]()

    init(accountId : Int, context:AnyObject){
        
        self.accountId = accountId
        self.context = context
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(String(describing: accountId))")!
        self.userId = self.defaults.string(forKey: "NVGSDK_USERID")
        //self.userId = "0" //DEV
        self.onBoarding = OnBoarding(defaults: self.defaults)
        if self.userId == nil || self.userId == "0"{
            self.createUserId()
        }
        self.loadResourcesFromSharedObject()
    }
    
    func createUserId(){
        self.ws.createUser(user:self, acc:self.accountId)
    }
    
    func sendDataMobileInfo(){
        self.ws.sendDataMobileInfo(user: self, mobileInfo: try! self.getDataMobileInfo())
    }
    
    func sendDataTrack(){
        self.ws.sendDataTrack(user: self, pageView: self.getPageView())
    }
    
    func sendCustomList(){
        self.ws.sendCustomList(user: self, listCustom: self.getCustomList())
    }
    
    func sendOnBoarding(){
        self.ws.sendOnBoarding(user: self, onBoarding: self.getOnBoarding())
    }
    
    private func loadResourcesFromSharedObject(){
        /* Page View */
        if(self.defaults.object(forKey: "listAppPageView") != nil){
            let jsonSerData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "listAppPageView") as! Data)!)
            if(jsonSerData != nil){
                self.listPageView = try! JSONDecoder().decode([PageViewer].self, from: jsonSerData!)
                if(self.listPageView.count == 0){
                    self.listPageView = [PageViewer]()
                }
            }
        }else{
            self.listPageView = [PageViewer]()
        }
            /* Custom List */
        if(defaults.object(forKey: "customList") != nil){
            let jsonCustomData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "customList") as! Data)!)
            if(jsonCustomData != nil){
                self.listCustom = try! JSONDecoder().decode([Int].self, from: jsonCustomData!)
                if(self.listCustom.count == 0){
                    self.listCustom = [Int]()
                }
            }
        }else{
            self.listCustom = [Int]()
        }
        
        if(self.defaults.dictionary(forKey: "jsonSegments") != nil){
            self.jsonSegments = self.defaults.dictionary(forKey: "jsonSegments") as! [String:String]
        }
        
        if(defaults.array(forKey: "customListAux") != nil){
            self.customListPermanent = defaults.array(forKey: "customListAux") as! [Int]
        }
    }
    
    func __set_user_id(userID :String?){
        
        self.userId = userID
        self.defaults.set(self.userId, forKey: "NVGSDK_USERID")
        self.defaults.synchronize()
    }
    
    /* MobileInfo */
    func getDataMobileInfo() throws ->MobileInfo{
        var mobInfo = MobileInfo()
        mobInfo.deviceID = util.getDeviceId() // Device ID e IMEI são os mesmos
        mobInfo.platform = "IOS"
        mobInfo.longitude = LocationPosition.sharedLocation.getPositionLongitude()
        mobInfo.latitude = LocationPosition.sharedLocation.getPositionLatitude()
        mobInfo.androidName = util.getIOSName()
        mobInfo.androidBrand = ""
        mobInfo.androidModel = util.getIOSModel()
        mobInfo.versionRelease = util.getVersionApp()
        mobInfo.manufacturer = ""
        mobInfo.versionLib = util.getVersionApp()
        mobInfo.versionCode = Int32(Int(util.getVersionCodeLib())!)
        mobInfo.versionOs = util.getIOSVersionOS()
        mobInfo.androidFingerPrint = util.getDeviceId()
        mobInfo.userAgent = util.getUserAgent()
        mobInfo.linkPlayStore = util.getLinkAppStore(appId: (self.defaults.integer(forKey: "NVGSDK_IDAPPSTORE")))
        mobInfo.imei = util.getDeviceId() // IOS não permite pegar o imei, e recomenda usar o Device ID como IMEI
        mobInfo.softwareVersion = ""
        mobInfo.languageApp = util.getLanguageApp()
        mobInfo.userID = self.getUserId()
        mobInfo.acc = getAccountId()
        
        return mobInfo
    }
    
    public func getUserId()->String{
        if self.userId == nil || self.userId == "0"{
            return "0"
        }
        return self.userId!
    }
    
    func getAccountId()->UInt32{
        return UInt32(self.accountId)
    }
    
    func setToDataMobileInfo(sendMobileinfo : Bool){
        defaults.set(sendMobileinfo, forKey: "sendDataMobileInfo")
    }
    
    func hasToSendDataMobileInfo()->Bool{
        return defaults.bool(forKey: "sendDataMobileInfo") != true ? false : true
    }
    
    /* Track */
    func makeAPageView(screen:String){
        
        let pageView = PageViewer(
            view: screen,
            dateTime: Int64(util.getTodayString()),
            titlePage: util.getTitleView(navigationItem: context),
            callPage: "")
        
        listPageView.append(pageView)
        listPageView = listPageView.sorted(by: { $0.dateTime < $1.dateTime })

        let JsonDataSerialied = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(listPageView), options: .allowFragments)
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: JsonDataSerialied), forKey: "listAppPageView")
        defaults.synchronize()
        
    }
    
    func getPageView()->[PageViewer]{

        if(defaults.object(forKey: "listAppPageView") != nil){
            let jsonSerData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "listAppPageView") as! Data)!)
            listPageView = try! JSONDecoder().decode([PageViewer].self, from: jsonSerData!)
        }
        return listPageView
    }
    
    func clearListPageView(){
        defaults.removeObject(forKey: "listAppPageView")
        listPageView.removeAll()
    }
    
    /* Custom */
    func setCustom(id_custom:Int){
        self.listCustom.append(id_custom)
        
        self.setCustomInPositionSegment(custom: id_custom)
        
        let JsonDataSerialied = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(self.listCustom), options: .allowFragments)
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: JsonDataSerialied), forKey: "customList")
        defaults.synchronize()
    }
    
    func getCustomList() -> [Int]{
        if(defaults.object(forKey: "customList") != nil){
            let jsonSerData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "customList") as! Data)!)
            listCustom = try! JSONDecoder().decode([Int].self, from: jsonSerData!)
        }
        return listCustom
    }
    
    func removeCustom(id_custom:Int){
        if let index = self.listCustom.index(of: id_custom) {
            self.listCustom.remove(at: index)
        }
        if self.listCustom.count > 0 {
            let JsonDataSerialied = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(self.listCustom), options: .allowFragments)
            defaults.set( NSKeyedArchiver.archivedData(withRootObject: JsonDataSerialied), forKey: "customList")
            defaults.synchronize()
        }else{
            defaults.removeObject(forKey: "customList")
        }
    }
    
    /* Segments */
    func getSegments(segments:String) throws ->String{
        var idSegments:String = ""
        let currentDate = Date()
        let stringDate = defaults.string(forKey: "dateLastSync")
        distintcCustomSegment()
        if(stringDate != nil){
            self.dateLastSync = util.StringToDate(dateString: stringDate!)
            if(util.dayBetweenDates(firstDate: currentDate, secondDate: dateLastSync!) >= 1){
                ws.getSegments(user: self)
            }
        }
        
        if self.jsonSegments[segments] != nil {
            idSegments = self.jsonSegments[segments]!
        }
        
        return idSegments
    }
    
    func setCustomInPositionSegment(custom:Int){
        if(!self.customListPermanent.contains(custom)){
                self.customListPermanent.append(custom)
                defaults.setValue(self.customListPermanent , forKey: "customListAux")
                defaults.synchronize()
        }
    }

    func saveSegments(segments:[String:String]){
        self.jsonSegments = segments
        self.defaults.setValue(segments, forKey: "jsonSegments")
        self.defaults.setValue(util.DateToString(date: Date()), forKey: "dateLastSync")
        //self.defaults.synchronize()
    }
    
    
    /* OnBoarding */
    func setOnBoarding(key:String, value:String){
        self.onBoarding.addInfo(key: key, value: value)
    }
    
    func getOnBoarding()->OnBoarding{
        return self.onBoarding
    }
    
    /* Send Data when user lay app in background or close app and after open the app */
    func sendDataSaveInDefault(){
        if(util.isConnectedInternet()){
            if(getPageView().count > 0 ){
                self.ws.sendDataTrack(user: self, pageView: getPageView())
            }
            if(getCustomList().count > 0){
                self.ws.sendCustomList(user: self, listCustom: getCustomList())
            }
            if(!getOnBoarding().hasToSendOnBoarding()){
                self.ws.sendOnBoarding(user: self, onBoarding: getOnBoarding())
            }
        }
    }
    
    func distintcCustomSegment(){
        
        var customs:[String] = [String]()
        
        if self.jsonSegments["custom"] != nil {
            customs = (self.jsonSegments["custom"]!).components(separatedBy: "-")
        }
        
        for value in customListPermanent{
            if !customs.contains(where:{$0 == "\(value)"}) { // if not in custom segments
                customs.append("\(value)")
            }
        }
        
        self.jsonSegments["custom"] = customs.joined(separator: "-")
    }
}
