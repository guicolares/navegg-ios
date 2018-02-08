//
//  WebService.swift
//  SdkNavegg
//
//  Created by Navegg on 14/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation
import Alamofire


class WebService{
    let headers:[String:String] = ["User-Agent":"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", "content-type":"application/octet-stream"]
    let util = Util()
    let options : Data.Base64EncodingOptions = [
        .endLineWithLineFeed,
        .endLineWithCarriageReturn
    ]
    let sessionConfig:SessionManager
    
    init (){
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.navegg.SdkNaveggIOS")
        sessionConfig = Alamofire.SessionManager(configuration: configuration)
    }
    
    func ENDPOINTS(url : String) -> String {
        var URL : [String:String] = ["user":"usr","request":"cdn","onboarding":"cd"]
        return URL[url]!
    }
    
    func getEndPoint(endPoint:String,param:String)->String{
        return "https://"+ENDPOINTS(url: endPoint)+".navdmp.com/\(param)";
    }
    
    func getEndPointURLRequest(endPoint:String,param:String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: "http://"+ENDPOINTS(url: endPoint)+".navdmp.com/\(param)")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("application/protobuf", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    public func createUser (user: User, acc:Int) {
        if(util.isConnectedInternet()){
            var usr = user
            sessionConfig.request(self.getEndPoint(endPoint: "user",param: "usr"),
                              parameters: ["acc":acc, "devid": util.getDeviceId()],
                              headers: self.headers).response{ (response) in
                do {
                    if let responseData =  String(data: response.data!, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "\'", with: "\"").data(using: String.Encoding.utf8)
                    {
                        var jsonData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String:Any]
                        usr.__set_user_id(userID:jsonData!["nvgid"]! as! String)
                        usr.setToDataMobileInfo(sendMobileinfo: true);
                        self.sendDataMobileInfo(user: usr, mobileInfo: try usr.getDataMobileInfo())
                        self.getSegments(user: usr)
                    }
                } catch {
                    
                }
            }
        }
    }
    
    public func sendDataMobileInfo(user:User, mobileInfo:MobileInfo){
        if (user.getUserID() == "0"){
            return
        }
        let usr = user
        if (util.isConnectedInternet()){
            let usr = user
            var urlRequest = self.getEndPointURLRequest(endPoint: "request",param: "sdkinfo")

            let mobInfo = try! mobileInfo.serializedData().base64EncodedString(options: options).data(using: String.Encoding.utf8)
            urlRequest.httpBody = mobInfo
            sessionConfig.request(urlRequest).responseString{ (response) in
                usr.setToDataMobileInfo(sendMobileinfo: true)
            }
        }else{
           usr.setToDataMobileInfo(sendMobileinfo: false)
        }
    }
    
    public func sendDataTrack(user:User, pageView : [PageViewer]) {
        if (user.getUserID() == "0"){
            return
        }
        if (util.isConnectedInternet()){
            let pageTrack = util.setDataTrack(user: user, pageView: util.setListDataPageTrack(pageView: pageView))
            var usr = user
            var urlRequest = self.getEndPointURLRequest(endPoint: "request",param: "sdkreq")
            let trackInfo = try! pageTrack.serializedData().base64EncodedString(options: options).data(using: String.Encoding.utf8)
            urlRequest.httpBody = trackInfo
            sessionConfig.request(urlRequest).responseString{ (response) in
                usr.clearListPageView()
            }
        }
        
    }
    
    public func sendCustomList(user:User, listCustom:[Int]){
        if (user.getUserID() == "0"){
            return
        }

        if (util.isConnectedInternet()){
            var usr = user
            let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            for id_custom in listCustom{
            sessionConfig.request(self.getEndPoint(endPoint: "request",param: "cus"),
                  parameters: ["acc":usr.getAccountId(), "cus": id_custom,"id":user.getUserID()],
                  headers: self.headers).response(queue:queue,completionHandler:{(response) in
                        usr.removeCustom(id_custom: id_custom)
                        }
                )
            }
        }else{
            
        }
        
    }
    
    public func getSegments(user:User){
        if (user.getUserID() == "0"){
            return
        }
        var usr = user
        if (util.isConnectedInternet()){
            /* wst = Want in String
               wst 0 String 1 in ID
               v = 10 Tag Navegg Version
             */
            Alamofire.request(self.getEndPoint(endPoint: "user",param: "usr"),
                      parameters: ["acc":usr.getAccountId(), "wst": 0,"v":10, "id":user.getUserID(), "asdk":util.getVersionLib()],
                      headers: self.headers).responseString{ (response) in
                        usr.saveSegments(segments: response.result.value!)
            }
        }
    }
    
    public func sendOnBoarding(user:User, onBoarding:OnBoarding){
        if (user.getUserID() == "0"){
            return
        }
        let usr = user
        if (util.isConnectedInternet()){
            var parameters = ["prtid":usr.getAccountId(), "id":user.getUserID()] as [String : Any]
            for (key,value) in onBoarding.__get_hash_map(){
                parameters.updateValue(value, forKey: key)
            }
//
//            var urlRequest = self.getEndPointURLRequest(endPoint: "onboarding",param: "cd")
//            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
//            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: jsonData)
            sessionConfig.request(self.getEndPoint(endPoint: "onboarding",param: "cd"),parameters:parameters,headers: self.headers).responseString{ (response) in
                user.getOnBoarding().__set_to_send_onBoarding(status: true)
            }
        }
    }
    
    
    
}
