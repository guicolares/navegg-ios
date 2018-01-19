//
//  OnBoarding.swift
//  SdkNaveggIOS
//
//  Created by Navegg on 18/01/18.
//  Copyright © 2018 Navegg. All rights reserved.
//

import Foundation


struct OnBoarding {
    var defaults : UserDefaults
    var data: NSMutableDictionary =  NSMutableDictionary()
    var valueData : [String:Any]
    
    
    init(defaults:UserDefaults){
        self.defaults = defaults
        self.valueData = self.defaults.dictionary(forKey: "onBoarding") ?? [:]
        if((self.valueData.count) != 0){
            self.data =  NSMutableDictionary()
        }
    }
    
    
    public func addInfo(key:String, value:String){
        self.data.setValue(value, forKey: key)
        self.defaults.set(self.data, forKey: "onBoarding")
    }
    
    public func __set_to_send_onBoarding(status:Bool){
        self.defaults.set(status, forKey: "toSendOnBoarding")
    }
    
    public func hasToSendOnBoarding()->Bool{
        return self.defaults.bool(forKey: "toSendOnBoarding")
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
}
