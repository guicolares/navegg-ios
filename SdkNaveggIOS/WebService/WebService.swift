//
//  WebService.swift
//  SdkNavegg
//
//  Created by Navegg on 14/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation
import Alamofire

class WebService {
    let headers: [String:String] = [
        "User-Agent":"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
        "content-type":"application/octet-stream"]
    let util = Util()
    let options : Data.Base64EncodingOptions = [
        .endLineWithLineFeed,
        .endLineWithCarriageReturn
    ]
    var sessionConfig:SessionManager
    let defineParams:[String] = ["prtusride","prtusridc","prtusridr","prtusridf", "prtusridt"]
    var runningCreateUser:Bool!
    
    init () {
        self.sessionConfig = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.navegg.SdkNaveggIOS"))
    }
    
    func ENDPOINTS(url : String) -> String {
        var URL : [String:String] = ["app":"app","request":"cdn","onboarding":"cd"]
        return URL[url]!
    }
    
    func getEndPoint(endPoint:String,param:String) -> String {
        return "https://"+ENDPOINTS(url: endPoint)+".navdmp.com/\(param)";
    }
    
    func getEndPointURLRequest(endPoint:String,param:String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: self.getEndPoint(endPoint: endPoint, param: param))!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("application/protobuf", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    public func createUser(user:User, acc:Int) {
        if self.runningCreateUser == true {
            return
        }
        self.runningCreateUser = true
        if util.isConnectedInternet() {
            self.sessionConfig.request(
                self.getEndPoint(endPoint: "app",param: "app"),
                parameters: ["acc":acc, "devid": util.getDeviceId()],
                headers: self.headers
            ).validate().responseJSON {
                response in
                switch (response.result) {
                case .success:
                    do {
                        var jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String:Any]
                        if let userIdData = jsonData!["nvgid"] {
                            let userId = userIdData as! String
                            let usr = user
                            usr.__set_user_id(userID: userId)
                            self.runningCreateUser = false
                            usr.setToDataMobileInfo(sendMobileinfo: true);
                            usr.sendDataMobileInfo()
                            self.getSegments(user: usr)
                            
                        } else {
                            self.runningCreateUser = false
                            print("catch createUser WebService...")
                            Thread.callStackSymbols.forEach{print($0)}
                        }
                    } catch {
                        self.runningCreateUser = false
                        print("catch createUser WebService...")
                        Thread.callStackSymbols.forEach{print($0)}
                    }
                
                break
                case .failure:
                    self.runningCreateUser = false
                    print("NavegAPI: warning - createUserId - something went wrong with endpoint, will retry later")
                break
                }
            }
        }
    }
    
    public func sendDataMobileInfo(user:User, mobileInfo:MobileInfo) {
        if user.getUserId() == "0" {
            return
        }
        let usr = user
        if util.isConnectedInternet() {
            let usr = user
            var urlRequest = self.getEndPointURLRequest(endPoint: "request",param: "sdkinfo")

            let mobInfo = try! mobileInfo.serializedData().base64EncodedString(options: options).data(using: String.Encoding.utf8)
            urlRequest.httpBody = mobInfo
            sessionConfig.request(urlRequest).responseString{ response in
                switch (response.result) {
                case .success:
                    do {
                        var jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String:Any]
                        
                        if let statusData = jsonData!["status"] {
                            let status = statusData as! Bool
                            if status {
                                usr.setToDataMobileInfo(sendMobileinfo: true)
                            } else {
                                // status false
                                usr.setToDataMobileInfo(sendMobileinfo: false)
                            }
                        }
                    } catch {
                        usr.setToDataMobileInfo(sendMobileinfo: false)
                    }
                   break
                case .failure:
                    print("NavegAPI: warning - sendDataMobileInfo - something went wrong with endpoint, will retry later")
                break
                }
            }
        } else {
            usr.setToDataMobileInfo(sendMobileinfo: false)
        }
    }
    
    public func sendDataTrack(user:User, pageView : [PageViewer]) {
        if user.getUserId() == "0" {
            return
        }
        if util.isConnectedInternet() {
            let pageTrack = util.setDataTrack(user: user, pageView: util.setListDataPageTrack(pageView: pageView))
            let usr = user
            var urlRequest = self.getEndPointURLRequest(endPoint: "request",param: "sdkreq")
            let trackInfo = try! pageTrack.serializedData().base64EncodedString(options: options).data(using: String.Encoding.utf8)
            urlRequest.httpBody = trackInfo
            sessionConfig.request(urlRequest).responseString{ (response) in
                switch (response.result) {
                    case .success:
                        usr.clearListPageView()
                    break
                case .failure:
                        print("NavegAPI: warning - sendDataMobileInfo - something went wrong with endpoint, will retry later")
                    
                break
                }
            }
        }
    }
    
    public func sendCustomList(user:User, listCustom:[Int]) {
        if user.getUserId() == "0" {
            return
        }

        if util.isConnectedInternet() {
            let usr = user
            let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            for id_custom in listCustom{
            sessionConfig.request(
                self.getEndPoint(endPoint: "request",param: "cus"),
                parameters: ["acc":usr.getAccountId(), "cus": id_custom,"id":user.getUserId()],
                headers: self.headers).responseString(queue:queue,completionHandler:{(response) in
                    switch (response.result) {
                        case .success:
                            usr.removeCustom(id_custom: id_custom)
                        break
                    case .failure:
                            print("NavegAPI: warning - sendCustomList - something went wrong with endpoint, will retry later")
                        
                    break
                    }
                }
            )
            }
        }
    }
    
    public func getSegments(user:User) {
        if user.getUserId() == "0" {
            return
        }
        let usr = user
        if util.isConnectedInternet() {
            var parameters = Dictionary<String,Any>()
            parameters = [
                "acc":usr.getAccountId(),
                "wst": 0,
                "v":11,
                "id":user.getUserId(), 
                "asdk":util.getVersionLib(),
                "wct":1
            ] as [String : Any]

            for (key,value) in user.getOnBoarding().__get_hash_map() {
                if defineParams.contains(key) {
                    parameters.updateValue(value, forKey: key)
                }
            }
            
            Alamofire.request(self.getEndPoint(endPoint: "app", param: "app"),
              parameters: parameters,
              headers: self.headers).responseJSON {
                response in
                switch (response.result) {
                case .success:
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:String]
                        usr.saveSegments(segments: jsonData)
                    } catch {
                        print("catch getSegments WebService...")
                        Thread.callStackSymbols.forEach{print($0)}
                    }
                    
                    break
                case .failure:
                    print("NavegAPI: warning - getSegments - something went wrong with endpoint, will retry later")
                    break
                }
            }
        }
    }
    
    public func sendOnBoarding(user:User, onBoarding:OnBoarding) {
        if user.getUserId() == "0" {
            return
        }
        let usr = user
        if util.isConnectedInternet() {
            var parameters = Dictionary<String,Any>()
            parameters = ["prtid":usr.getAccountId(), "id":user.getUserId(), "DATA":[]] as [String : Any]
            var valueData = [String:Any]()
            for (key,value) in onBoarding.__get_hash_map() {
                if defineParams.contains(key) {
                    parameters.updateValue(value, forKey: key)
                } else {
                    valueData[key] = value
                }
            }
            
            parameters["DATA"] = valueData

            sessionConfig.request(
                self.getEndPoint(endPoint: "onboarding",param: "cd"),
                parameters:parameters,
                headers: self.headers
            ).responseString{ (response) in
                switch(response.result){
                case .success:
                    usr.getOnBoarding().__set_to_send_onBoarding(status: true)
                    usr.getOnBoarding().setDateLastSync(date: Date())
                break
                case .failure:
                    usr.getOnBoarding().__set_to_send_onBoarding(status: false)
                    print("NavegAPI: warning - sendOnBoarding - something went wrong with endpoint, will retry later")
                break
                }
            }
        } else {
            usr.getOnBoarding().__set_to_send_onBoarding(status: false)
        }
    }
}
