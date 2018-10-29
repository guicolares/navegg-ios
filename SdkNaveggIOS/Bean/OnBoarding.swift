//
//  OnBoarding.swift
//  SdkNaveggIOS
//
//  Created by Navegg on 18/01/18.
//  Copyright © 2018 Navegg. All rights reserved.
//

import Foundation
import 

class OnBoarding{
    var defaults : UserDefaults
    var util :Util
    var accountId : Int
    var data: NSMutableDictionary
    var valueData:[String:Any]
    
    
    init(accountId:Integer, Util:util, defaults:UserDefaults){
        //self.valueData = Dictionary<String,Any>()
        self.data =  NSMutableDictionary()
        self.defaults = defaults
        self.accountId = accountId
        self.util = util

        
        self.valueData = self.defaults.dictionary(forKey: "onBoarding" + accountId) ?? [:]

        if((self.valueData.count) == 0){
            self.valueData = [String:Any]()
        }
    }
    
    
    public func addInfo(key:String, value:String)->Bool{
        self.valueData = self.defaults.dictionary(forKey: "onBoarding" + accountId) ?? [:]

        if let _check_value = valueData[key] {
            if _check_value == value {
                let currentDate = Date()
                let stringDate = defaults.string(forKey: "dateLastSyncOnBoarding")
                if(stringDate != nil){
                    self.dateLastSync = util.StringToDate(dateString: stringDate!)
                    if(util.dayBetweenDates(firstDate: currentDate, secondDate: dateLastSync!) == 0){
                        return false
                    }
                }
            }
        }

        self.valueData[key] = value
        self.defaults.set(self.valueData, forKey: "onBoarding" + accountId)
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

    public getDateLastSync()->Int{

    }
    public void setDateLastSync(){

    }
}



  public long getDateLastSync() {
        return this.dateLastSync;
    }

    public void setDateLastSync() {
        try {
            this.shaPref.edit().putLong("dateLastSyncOnBoarding", Calendar.getInstance().getTime().getTime()).apply();
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }