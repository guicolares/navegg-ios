//
//  NaveggApi.swift
//  SdkNavegg
//
//  Created by Navegg on 01/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//
import Foundation
import Alamofire

public class NaveggApi:NSObject{
    private var defaults : UserDefaults
    private let util = Util()
    private var user : User
    private var appDelegate: AnyObject
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
  
    
    
    required public init(accountId:Int, context: AnyObject, idAppStore:Int?=0){
        
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(accountId)")!
        self.defaults.set(accountId, forKey: "NVGSDK_CODCONTA")
        self.defaults.set(idAppStore, forKey: "NVGSDK_IDAPPSTORE")
        self.user = User(accountId: accountId, context: context)
        self.appDelegate = context
        LocationPosition.sharedLocation.determineMyCurrentLocation()
        
        if (self.user.getUserId() == "0") {
            self.user.createUserId()
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
            self.user.sendDataMobileInfo()
        }
        
        user.makeAPageView(screen: screen)
        self.user.sendDataTrack()
    }
    
    public func setCustom(id_custom:Int){
        if(!user.hasToSendDataMobileInfo()){
            self.user.sendDataMobileInfo()
        }
        
        self.user.setCustom(id_custom: id_custom)
        self.user.sendCustomList()
    }
    
    public func getSegments(segments:String) -> String{
        do {
            return try self.user.getSegments(segments: segments);
        } catch {
            return "";
        }
    }
    
    public func setOnboarding (key:String, value:String){
        if self.user.setOnBoarding(key: key, value: value) {
            self.user.sendOnBoarding()
        }
    }
    
    public func getOnBoarding(key:String)->String{
        return self.user.getOnBoarding().getInfo(key: key)
    }
    
    public func getUserId()->String {
        return self.user.getUserId()
    }
    
    
}
