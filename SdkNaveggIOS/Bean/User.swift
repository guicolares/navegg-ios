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
    var defaults : UserDefaults
    let context : AnyObject
    var listCustom = [Int]()
    var onBoarding:OnBoarding
    let ws = WebService()
    var dateLastSync:Date?=nil
    var customListPermanent = [Int]()
    var jsonSegments = [String:String]()

    init(accountId : Int, context:AnyObject) {
        
        self.accountId = accountId
        self.context = context
        self.defaults = UserDefaults.init(suiteName:"NVGSDK\(String(describing: accountId))")!
        self.userId = self.defaults.string(forKey: "NVGSDK_USERID")

        self.onBoarding = OnBoarding(accountId: self.accountId, util: self.util, defaults: self.defaults)
        if self.userId == nil || self.userId == "0" {
            self.createUserId()
        }
        self.loadResourcesFromSharedObject()
    }
    
    func createUserId() {
        self.ws.createUser(user:self, acc:self.accountId)
    }
    
    func sendOnBoarding() {
        self.ws.sendOnBoarding(user: self, onBoarding: self.getOnBoarding())
    }
    
    private func loadResourcesFromSharedObject() {
        if self.defaults.dictionary(forKey: "jsonSegments") != nil {
            self.jsonSegments = self.defaults.dictionary(forKey: "jsonSegments") as! [String:String]
        }
    }
    
    func __set_user_id(userID :String?) {
        
        self.userId = userID
        self.defaults.set(self.userId, forKey: "NVGSDK_USERID")
        self.defaults.synchronize()
    }
    
    public func getUserId() -> String {
        if self.userId == nil || self.userId == "0" {
            return "0"
        }
        return self.userId!
    }
    
    func getAccountId() -> UInt32 {
        return UInt32(self.accountId)
    }
    
    /* Segments */
    func getSegments(segments:String) throws -> String {
        var idSegments:String = ""
        let currentDate = Date()
        let stringDate = defaults.string(forKey: "dateLastSync")
        distintcCustomSegment()
        if stringDate != nil {
            self.dateLastSync = util.StringToDate(dateString: stringDate!)
            if util.dayBetweenDates(firstDate: currentDate, secondDate: dateLastSync!) >= 1 {
                ws.getSegments(user: self)
            } else {
                let stringDateOnBoarding = defaults.string(forKey: "dateLastSyncOnBoarding")
                if stringDateOnBoarding != nil {
                    let dateLastSync = util.StringToDate(dateString: stringDate!)
                    let dateOnBoarding = util.StringToDate(dateString: stringDateOnBoarding!)
                    if(dateLastSync < dateOnBoarding){
                        ws.getSegments(user: self)
                    }
                }
            }
        } else {
            ws.getSegments(user: self)
        }
        
        if self.jsonSegments[segments] != nil {
            idSegments = self.jsonSegments[segments]!
        }
        
        return idSegments
    }

    func saveSegments(segments:[String:String]) {
        self.jsonSegments = segments
        self.defaults.setValue(segments, forKey: "jsonSegments")
        self.defaults.setValue(util.DateToString(date: Date()), forKey: "dateLastSync")
    }
    
    /* OnBoarding */
    func setOnBoarding(key:String, value:String) -> Bool {
        return self.onBoarding.addInfo(key: key, value: value)
    }
    
    func getOnBoarding() -> OnBoarding {
        return self.onBoarding
    }
    
    /* Send Data when user lay app in background or close app and after open the app */
    func sendDataSaveInDefault() {
        if util.isConnectedInternet() {
            if !getOnBoarding().hasToSendOnBoarding() {
                self.ws.sendOnBoarding(user: self, onBoarding: getOnBoarding())
            }
        }
    }
    
    func distintcCustomSegment() {
        
        var customs:[String] = [String]()
        
        if self.jsonSegments["custom"] != nil {
            customs = (self.jsonSegments["custom"]!).components(separatedBy: "-")
        }
        
        for value in customListPermanent {
            if !customs.contains(where:{$0 == "\(value)"}) { // if not in custom segments
                customs.append("\(value)")
            }
        }
        
        self.jsonSegments["custom"] = customs.joined(separator: "-")
    }
}
