//
//  OnBoarding.swift
//  SdkNaveggIOS
//
//  Created by Navegg on 18/01/18.
//  Copyright © 2018 Navegg. All rights reserved.
//

import Foundation

class OnBoarding{
    var defaults : UserDefaults
    var util :Util
    var accountId : Int
    var data: NSMutableDictionary
    var valueData : [String:Any]
    var dateLastSync:String?=nil

    init(accountId:Int, util:Util, defaults:UserDefaults){
        //self.valueData = Dictionary<String,Any>()
        self.data =  NSMutableDictionary()
        self.defaults = defaults
        self.accountId = accountId
        self.util = util
        
        self.dateLastSync = self.defaults.string(forKey: "dateLastSyncOnBoarding") ?? nil
        
        self.valueData = self.defaults.dictionary(forKey: "onBoarding" + String(self.accountId)) ?? [:]

        if((self.valueData.count) == 0){
            self.valueData = [String:Any]()
        }
    }
    
    public func addInfo(key:String, value:String)->Bool{
        self.valueData = self.defaults.dictionary(forKey: "onBoarding" + String(self.accountId)) ?? [:]

        if let _check_value = valueData[key] as? String {
            if _check_value == value {
                let currentDate = Date()
                let stringDate = defaults.string(forKey: "dateLastSyncOnBoarding")
                if(stringDate != nil){
                    let dateLastSync = util.StringToDate(dateString: stringDate!)
                    if(util.dayBetweenDates(firstDate: currentDate, secondDate: dateLastSync) == 0){
                        return false
                    }
                }
            }
        }

        self.valueData[key] = value
        self.defaults.set(self.valueData, forKey: "onBoarding" + String(self.accountId))
        self.defaults.synchronize()

        return true
    }
    
    public func __set_to_send_onBoarding(status:Bool){
        self.defaults.set(status, forKey: "toSendOnBoarding")
    }
    
    public func hasToSendOnBoarding()->Bool{
        return self.defaults.bool(forKey: "toSendOnBoarding") ? false : true
    }
    
    public func getInfo(key:String)->String{
        var info = ""
        let value = self.valueData.index(forKey: key)
        if(value != nil){
            info = valueData[value!].value as! String
        }
        return info
    }
    
    public func __get_hash_map()->Dictionary<String,Any>{
        return self.valueData
    }

    public func getDateLastSync()->String{
        return self.dateLastSync!
    }
    
    public func setDateLastSync(date:Date){
        self.dateLastSync = self.util.DateToString(date: date)
        self.defaults.set(self.dateLastSync, forKey: "dateLastSyncOnBoarding")
    }
}
