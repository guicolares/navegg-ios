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
    private let ws = WebService()
    private var user : User
    
    required public init(cod:Int, context: AnyObject, idAppStore:Int?=0){
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(cod)")!
        self.defaults.set(cod, forKey: "NVGSDK_CODCONTA")
        self.defaults.set(idAppStore, forKey: "NVGSDK_IDAPPSTORE")
        self.user = User(accountId: cod, context: context)
    
        if (self.user.getUserID() == "0") {
            self.ws.createUser(user: user, acc:cod)
        }
        
        super.init()
        registerReceiverAndAccountSdk(cod: cod)
        
    }
    
    
    func registerReceiverAndAccountSdk(cod:Int){
        
        if(!(defaults.bool(forKey: "NVGSDK_RECEIVER"))){
            print("Receiver Criado")
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
    
//    func NaveggApiPrint (cod:Int, context : AnyObject){
//
//
//        //        Track(userId: <#String#>, acc: <#String#>, nameApp: <#String#>, deviceIP: <#String#>, typeConnection: <#String#>)
//        print(self.util.getIpMobile())
//        print(self.util.getDeviceId())
//        //        print("https://itunes.apple.com/app/id"+util.getDeviceId()+"?mt=8")
//        print(self.util.getTypeCategory())
//        print(util.getLinkAppStore(appId: 3203947))
//        print(util.getTitleView(navigationItem: context))
//        print(util.getNameApp())
//
//        print(util.getIOSModel())
//        print(util.getIOSName())
//        print(util.getIOSVersionOS())
//        print(util.getVersionApp())
//        print(util.getVersionCodeLib())
//        print(util.getUserAgent())
//        print(util.getLanguageApp())
//
//
//        if let codConta = defaults?.integer(forKey: "NVGSDK_CODCONTA") {
//            print(codConta) // Some String Value
//        }
//    }
    
}

