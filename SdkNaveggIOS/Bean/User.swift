//
//  User.swift
//  SdkNavegg
//
//  Created by Navegg on 14/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation

struct User {
    var userId : String?
    var accountId : Int
    var util = Util()
    private let defaults : UserDefaults
    let context : AnyObject
    var listPageView = [PageViewer]()
    var listCustom = [Int]()
    var valueData = [String:Any]()
    let listSegments:[String] = [
    "gender", "age", "education", "marital",
    "income", "city", "region", "country",
    "connection", "brand", "product",
    "interest", "career", "cluster",
    "", "custom", "industry", "everybuyer" //empty one was prolook
    ];
    var onBoarding:OnBoarding
    let ws = WebService()
    var dateLastSync:Date?=nil
    var customListPermanent = [Int]()
    
    var jsonSegments = [String:Any]()

    init(accountId : Int, context:AnyObject){
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        self.accountId = accountId
        self.context = context
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(String(describing: accountId))")!
        self.userId = defaults.string(forKey: "NVGSDK_USERID")
        self.onBoarding = OnBoarding(defaults: defaults)
        self.loadResourcesFromSharedObject()
        
        
    }
    
    mutating func createUserId(){
        let userId = self.ws.createUser(acc:self.accountId)
        self.__set_user_id(userID: userId)
        self.setToDataMobileInfo(sendMobileinfo: true);
        self.sendDataMobileInfo()
        //self.getSegments()
    }
    
    mutating func sendDataMobileInfo(){
        self.ws.sendDataMobileInfo(user: self, mobileInfo: try! self.getDataMobileInfo())
    }
    
    mutating func sendDataTrack(){
        self.ws.sendDataTrack(user: self, pageView: self.getPageView())
    }
    
    
    mutating func sendCustomList(){
        self.ws.sendCustomList(user: self, listCustom: self.getCustomList())
    }
    
    mutating func sendOnBoarding(){
        self.ws.sendOnBoarding(user: self, onBoarding: self.getOnBoarding())
    }
    
    private mutating func loadResourcesFromSharedObject(){
        /* Page View */
        if(defaults.object(forKey: "listAppPageView") != nil){
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
        
        
        if(defaults.dictionary(forKey: "jsonSegments") != nil){
            self.jsonSegments = defaults.dictionary(forKey: "jsonSegments")!
        }
        
        if(defaults.array(forKey: "customListAux") != nil){
            self.customListPermanent = defaults.array(forKey: "customListAux") as! [Int]
        }
    }
    
    mutating func __set_user_id(userID :String?){
        
        self.userId = userID
        defaults.set(self.userId, forKey: "NVGSDK_USERID")
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
//        mobInfo.userID = getUserID()
        mobInfo.userID = "12d450cac700b4f1f7491806"
        mobInfo.acc = getAccountId()
        
        return mobInfo
    }
    
    func getUserID()->String{
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
    mutating func makeAPageView(screen:String){
        
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
    
    
    
    mutating func getPageView()->[PageViewer]{

        if(defaults.object(forKey: "listAppPageView") != nil){
            let jsonSerData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "listAppPageView") as! Data)!)
            listPageView = try! JSONDecoder().decode([PageViewer].self, from: jsonSerData!)
        }
        return listPageView
    }
    
    mutating func clearListPageView(){
        defaults.removeObject(forKey: "listAppPageView")
        listPageView.removeAll()
    }
    
    /* Custom */
    mutating func setCustom(id_custom:Int){
        self.listCustom.append(id_custom)
        
        self.setCustomInPositionSegment(custom: id_custom)
        
        let JsonDataSerialied = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(self.listCustom), options: .allowFragments)
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: JsonDataSerialied), forKey: "customList")
        defaults.synchronize()
    }
    
    mutating func getCustomList() -> [Int]{
        if(defaults.object(forKey: "customList") != nil){
            let jsonSerData = try? JSONSerialization.data(withJSONObject: NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "customList") as! Data)!)
            listCustom = try! JSONDecoder().decode([Int].self, from: jsonSerData!)
        }
        return listCustom
    }
    
    mutating func removeCustom(id_custom:Int){
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
    mutating func getSegments(segments:String)->String{
        var idSegments:String = ""
        let currentDate = Date()
        let stringDate = defaults.string(forKey: "dateLastSync")
        distintcCustomSegment()
        if(stringDate != nil){
            self.dateLastSync = util.StringToDate(dateString: stringDate!)
            if(util.dayBetweenDates(firstDate: currentDate, secondDate: dateLastSync!) == 1){
                ws.getSegments(user: self)
            }
        }
      
//        self.jsonSegments = defaults.dictionary(forKey: "jsonSegments")
        
        if((self.jsonSegments.count) > 0){
            let segment = self.jsonSegments.index(forKey: segments)
            if(segment != nil){
                idSegments = jsonSegments[segment!].value as! String
            }
        }
        return idSegments
    }
    
    
   mutating func setCustomInPositionSegment(custom:Int){
        if(!self.customListPermanent.contains(custom)){
                self.customListPermanent.append(custom)
                defaults.setValue(self.customListPermanent , forKey: "customListAux")
                defaults.synchronize()
        }
    }
    

    mutating func saveSegments(segments:String){
        let date = Date()
        let cut1 = segments.index(after:segments.index(after:segments.index(after: segments.index(of: ",")!)))
        let indexOf1 = segments[segments.index(segments.startIndex,offsetBy: segments.distance(from: segments.startIndex  , to: cut1) )...]
        
        let indexOf2 = indexOf1[...indexOf1.index(indexOf1.endIndex,offsetBy: -4)]
        
        let seg = indexOf2.split(separator: ":", omittingEmptySubsequences: false)
        let jsonObject : NSMutableDictionary = NSMutableDictionary()
        for (index,segment) in listSegments.enumerated(){
            if(seg[index].count>0){
                jsonObject.setValue(String(describing: seg[index]), forKey: segment)
            }
        }
        defaults.setValue(jsonObject, forKey: "jsonSegments")
        defaults.setValue(util.DateToString(date: date), forKey: "dateLastSync")
    }
    
    
    /* OnBoarding */
    mutating func setOnBoarding(key:String, value:String){
        self.onBoarding.addInfo(key: key, value: value)
    }
    
    func getOnBoarding()->OnBoarding{
        return self.onBoarding
    }
    
    /* Send Data when user lay app in background or close app and after open the app */
    mutating func sendDataSaveInDefault(){
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
    
    mutating func distintcCustomSegment(){
        
        let segment = self.jsonSegments.index(forKey: "custom")
        var idSegments : String = ""
        if(segment != nil){
            idSegments = self.jsonSegments[segment!].value as! String
        }else{
            self.jsonSegments["custom"] = [String:Any]();
        }
        
        for value in customListPermanent{
            if idSegments.range(of:"\(value)") == nil {
                if(idSegments.count > 0){
                    idSegments += "-\(value)"
                }else{
                    idSegments += "\(value)"
                }
            }
        }
        
        self.jsonSegments.updateValue(idSegments, forKey: "custom")
    
    }
    
}
