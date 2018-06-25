//
//  NaveggApi.swift
//  SdkNavegg
//
//  Created by Navegg on 01/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//
import Foundation
import Alamofire
import Reachability


public class NaveggApi:NSObject{
    private var defaults : UserDefaults
    private let util = Util()
    private let ws = WebService()
    private var user : User
    private let reachability = Reachability()!
    private var appDelegate: AnyObject
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
  
    
    
    required public init(accountId:Int, context: AnyObject, idAppStore:Int?=0){
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        print("CLEANDED SDK")
        
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(accountId)")!
        self.defaults.set(accountId, forKey: "NVGSDK_CODCONTA")
        self.defaults.set(idAppStore, forKey: "NVGSDK_IDAPPSTORE")
        self.user = User(accountId: accountId, context: context)
        self.appDelegate = context
        LocationPosition.sharedLocation.determineMyCurrentLocation()
        
        if (self.user.getUserID() == "0") {
            self.ws.createUser(user: user, acc:accountId)
        }
        super.init()
        registerReceiverAndAccountSdk(cod: accountId)
        
    }
    

    func registerReceiverAndAccountSdk(cod:Int){
        
        if(!ReachabilityManager.shared.isCreateNotificationCenter()){
            ReachabilityManager.shared.createNotificationCenter(create: true)
            ReachabilityManager.shared.startMonitoring(user: self.user)
            ReachabilityManager.shared.startApplicationDidEnterBackground(user: self.user)
        }
        
//        var accounts = defaults.array(forKey: "accounts") as? [Int] ?? [Int]()
        var accounts = defaults.array(forKey: "accounts")?.count == 0 ?  [Int]() : defaults.array(forKey: "accounts") as? [Int] ?? [Int]()
        if(accounts.contains(cod) == false){
            accounts.append(cod)
            defaults.set(accounts, forKey: "accounts")
        }
        
    }
    
    public func setTrackPage(screen:String){
        if(!user.hasToSendDataMobileInfo()){
            ws.sendDataMobileInfo(user: user, mobileInfo: try! user.getDataMobileInfo())
        }
        
        user.makeAPageView(screen: screen)
        ws.sendDataTrack(user: user, pageView: user.getPageView())
    }
    
    public func setCustom(id_custom:Int){
        if(!user.hasToSendDataMobileInfo()){
            ws.sendDataMobileInfo(user: user, mobileInfo: try! user.getDataMobileInfo())
        }
        
        self.user.setCustom(id_custom: id_custom)
        self.ws.sendCustomList(user: self.user, listCustom: self.user.getCustomList())
    }
    
    public func getSegments(segments:String) -> String{
        return self.user.getSegments(segments: segments);
    }
    
    public func setOnboarding (key:String, value:String){
        self.user.setOnBoarding(key: key, value: value)
        self.ws.sendOnBoarding(user: self.user, onBoarding: self.user.getOnBoarding())
    }
    
    public func getOnBoarding(key:String)->String{
        return self.user.getOnBoarding().getInfo(key: key)
    }
    
    
}
