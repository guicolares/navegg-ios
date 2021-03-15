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
    let headers: HTTPHeaders = [
        "User-Agent":"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
        "content-type":"application/octet-stream"]
    let util = Util()
    let options : Data.Base64EncodingOptions = [
        .endLineWithLineFeed,
        .endLineWithCarriageReturn
    ]
    let defineParams:[String] = ["prtusride","prtusridc","prtusridr","prtusridf", "prtusridt"]
    var runningCreateUser:Bool!
    
    init () {}
    
    func ENDPOINTS(url : String) -> String {
        let URL : [String:String] = ["app":"app","request":"cdn","onboarding":"cd"]
        return URL[url]!
    }
    
    func getEndPoint(endPoint:String,param:String) -> String {
        return "https://"+ENDPOINTS(url: endPoint)+".navdmp.com/\(param)";
    }
    
    public func createUser(user:User, acc:Int) {
        if self.runningCreateUser == true {
            return
        }
        self.runningCreateUser = true
        if util.isConnectedInternet() {
            AF.request(
                self.getEndPoint(endPoint: "app",param: "app"),
                parameters: ["acc":acc, "devid": util.getDeviceId()],
                headers: self.headers
            ).validate().responseJSON {
                response in
                switch (response.result) {
                case .success:
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String:Any]
                        if let userIdData = jsonData!["nvgid"] {
                            let userId = userIdData as! String
                            let usr = user
                            usr.__set_user_id(userID: userId)
                            self.runningCreateUser = false
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
                "wct":1
            ] as [String : Any]

            for (key,value) in user.getOnBoarding().__get_hash_map() {
                if defineParams.contains(key) {
                    parameters.updateValue(value, forKey: key)
                }
            }
            
            AF.request(self.getEndPoint(endPoint: "app", param: "app"),
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

            AF.request(
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
