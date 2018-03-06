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
    var data: NSMutableDictionary
    var valueData:[String:Any]
    
    
    init(defaults:UserDefaults){
        self.valueData = Dictionary<String,Any>()
        self.data =  NSMutableDictionary()
        self.defaults = defaults
        if((self.valueData.count) != 0){
            self.valueData = [String:Any]()
        }
    }
    
    
    public func addInfo(key:String, value:String){
        self.valueData = self.defaults.dictionary(forKey: "onBoarding") ?? [:]
        self.valueData[key] = value
        self.defaults.set(self.valueData, forKey: "onBoarding")
        self.defaults.synchronize()
        
//
//        let JsonDataSerialied = try! JSONEncoder().encode(self.valueData)
//        defaults.set(NSKeyedArchiver.archivedData(withRootObject: JsonDataSerialied), forKey: "onBoarding")
//        defaults.synchronize()
//
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
}
