//
//  File.swift
//  SdkNavegg
//
//  Created by Navegg on 08/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation
import Reachability
import UIKit
import WebKit
import Alamofire

class Util {
    
    
    
    func getIpMobile() -> String{
        var address : String!
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "" }
        guard let firstAddr = ifaddr else { return "" }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
//    func getTypeConnection() -> String {
//
//    }


    func getDeviceId()->String{
        return UIDevice.current.identifierForVendor?.uuidString as String!
    }
    
    func getTypeCategory() -> String {
        
        var typeCategory : String
        
        // 1. request an UITraitCollection instance
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        // 2. check the idiom
        switch (deviceIdiom) {
            
        case .pad:
            typeCategory = "Ipad"
        case .phone:
            typeCategory = "IPhone"
        case .tv:
            typeCategory = "TvOS"
        default:
            typeCategory = "Sem Categoria"
        }
        
        return typeCategory
    }
    
    func getLinkAppStore(appId:Int) -> String {
        return "http://itunes.apple.com/\(getCountryApp().lowercased())/app/\(getNameApp().lowercased())/id\(appId)?mt=8"
    }
    
    public func getNameApp() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    private func getCountryApp() -> String {
        return ((Locale.current as NSLocale).object(forKey: .countryCode) as? String)!
    }
    
    
    public func getTitleView(navigationItem : AnyObject) -> String {
        var title : String

        if navigationItem.title == "" {
            title = "Sem titulo"
        }else {
            title = navigationItem.title
        }
        return title
    }
    
    public func getIOSModel() -> String{
        
        return UIDevice.init().localizedModel
        
    }

    public func getIOSName() -> String{
        
        return UIDevice.current.systemName
        
    }
    
    public func getIOSVersionOS() -> Int32{
        
//        let cut1 = segments.index(after:segments.index(after:segments.index(after: segments.index(of: ",")!)))
//        let indexOf1 = segments[segments.index(segments.startIndex,offsetBy: segments.distance(from: segments.startIndex  , to: cut1) )...]
//
//        let indexOf2 = indexOf1[...indexOf1.index(indexOf1.endIndex,offsetBy: -4)]
//
//        let seg = indexOf2.split(separator: ":", omittingEmptySubsequences: false)
        
        let version = UIDevice.current.systemVersion
        var index8:Character=" "
        var v:String = ""
        let index1 = version.index(before:version.index(version.startIndex, offsetBy: version.distance(from: version.startIndex  , to: version.index(of: ".")!)))
        let index2 = version[...index1]
        let index3 = version.index(after:version.index(version.startIndex, offsetBy: version.distance(from: version.startIndex  , to: version.index(of: ".")!)))
        let index4 = version[index3...]
        
        v = "\(index2)\(index4)"
        if(version.count > 4){
            let index5 = index4.index(before:index4.index(index4.startIndex, offsetBy: index4.distance(from: index4.startIndex  , to: index4.index(of: ".")!)))
            let index6 = version[index5]
            let index7 = index4.index(after:index4.index(index4.startIndex, offsetBy: index4.distance(from: index4.startIndex  , to: index4.index(of: ".")!)))
            index8 = version[index7]
            v = "\(index2)\(index6)\(index8)"
        }
        return Int32(v)!
        
    }
    
    public func getVersionApp() -> String{
        var versionApp = ""
        versionApp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

        return versionApp
    }
    
    public func getVersionLib() -> String{
        var versionLib = ""
        versionLib = Bundle(for: NaveggApi.self).infoDictionary?["CFBundleShortVersionString"] as! String
        
        return versionLib
    }
    
    public func getVersionCodeLib() -> String{
        var versionCodeLib = ""
        versionCodeLib = Bundle(for: NaveggApi.self).infoDictionary?["CFBundleVersion"] as! String
        
        return versionCodeLib
    }
    
    public func getUserAgent() -> String{
        return (UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent"))!
    }
    
    public func getLanguageApp() -> String {
        return Locale.preferredLanguages[0]
    }
    
    
    public func isConnectedInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func getTodayString() -> Int64{
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
//        let dateString = dateFormatter.string(from: date)
//        let interval = date.timeIntervalSince1970


    
        return Int64(((date.timeIntervalSince1970) * 1000.0).rounded())
    }
    
    func setDataTrack (user:User,pageView:[PageView]) -> Track {
        
        var trackProto = Track()
        trackProto.acc = user.getAccountId()
        trackProto.userID = "12d450cac700b4f1f7491806"
        trackProto.nameApp = getNameApp()
        trackProto.deviceIp = getIpMobile()
        trackProto.typeConnection = ReachabilityManager.shared.getTypeConnection()
        trackProto.pageViews = pageView
        
        return trackProto
    }
    
    func setListDataPageTrack(pageView : [PageViewer]) -> [PageView]{
        
        var listPageView = [PageView]()
        
        for pageView in pageView{
            
            var pageViewProto = PageView()
            pageViewProto.activity = pageView.view
            pageViewProto.dateTime = UInt64(pageView.dateTime)
            pageViewProto.titlePage = pageView.titlePage
            pageViewProto.callPage = pageView.callPage
            
            listPageView.append(pageViewProto)
        }
        return listPageView
    }
    
    
    func StringToDate(dateString : String)-> Date {
        let dateFormatter = DateFormatter()
        //2018-02-08 17:40:18
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        return dateFormatter.date(from: dateString)! //according to date format your date string
    }
    
    func DateToString(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your New Date format as per requirement change it own
        return dateFormatter.string(from: date) //pass Date here
    }
    
    func dayBetweenDates(firstDate:Date, secondDate:Date)->Int{
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day!
    }
    

    
    
}
