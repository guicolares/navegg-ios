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
    // HASH COnta 666 = "29a359c0409a86dd64d03"
    
    let headers:[String:String] = ["User-Agent":"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", "content-type":"application/octet-stream"]
    let util = Util()
    let options : Data.Base64EncodingOptions = [
        .endLineWithLineFeed,
        .endLineWithCarriageReturn
    ]
    //let configuration = URLSessionConfiguration.background(withIdentifier: "com.navegg.SdkNaveggIOS")
    var sessionConfig:SessionManager
    
    let defineParams:[String] = ["prtusride","prtusridc","prtusridr","prtusridf", "prtusridt"]
    
    init (){
        print("no Init...")
        self.sessionConfig = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.navegg.SdkNaveggIOS"))
    }
    
    func ENDPOINTS(url : String) -> String {
        var URL : [String:String] = ["user":"usr","request":"cdn","onboarding":"cd"]
        return URL[url]!
    }
    
    func getEndPoint(endPoint:String,param:String)->String{
        print("getting end point: \(endPoint)")
        return "http://local.navdmp.com/\(param)";
        //return "https://"+ENDPOINTS(url: endPoint)+".navdmp.com/\(param)";
    }
    
    func getEndPointURLRequest(endPoint:String,param:String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: self.getEndPoint(endPoint: endPoint, param: param))!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/protobuf", forHTTPHeaderField: "Content-Type")
        request.setValue("application/protobuf", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    public func createUser (acc:Int) ->String {
        print("criando o user...")
        var userId = "0"
        if(util.isConnectedInternet()){
            print("tem internet...")
            self.sessionConfig.request(
                self.getEndPoint(endPoint: "user",param: "usr"),
                parameters: ["acc":acc, "devid": util.getDeviceId()],
                headers: self.headers
            ).validate().responseJSON {
                response in
                switch (response.result) {
                case .success:
                    do {
                        print("no result: ")
                        print(response.data!)
                        if let responseData =  String(data: response.data!, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "\'", with: "\"").data(using: String.Encoding.utf8)
                        {
                            var jsonData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String:Any]
                            userId = jsonData!["nvgid"] as! String
                        }
                    } catch {
                        print("catch createUser WebService...")
                        Thread.callStackSymbols.forEach{print($0)}
                    }
                
                break
                case .failure(let error):
                    print("error - > \n    \(error.localizedDescription) \n")
                    //let statusCode = response.response?.statusCode
                    //self.completionBlock?(statusCode, error)
                break
                }
            }
        }
        return userId
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
            let usr = user
            let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
            for id_custom in listCustom{
            sessionConfig.request(self.getEndPoint(endPoint: "request",param: "cus"),
                  parameters: ["acc":usr.getAccountId(), "cus": id_custom,"id":user.getUserID()],
                  headers: self.headers).response(queue:queue,completionHandler:{(response) in
                        //usr.removeCustom(id_custom: id_custom)
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
            var parameters = Dictionary<String,Any>()
            parameters = ["prtid":usr.getAccountId(), "id":user.getUserID(), "DATA":[]] as [String : Any]
            var valueData = [String:Any]()
            for (key,value) in onBoarding.__get_hash_map(){
                if(defineParams.contains(key)){
                    parameters.updateValue(value, forKey: key)
                }else{
                    valueData[key] = value
                }
            }
            
            parameters["DATA"] = valueData
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
