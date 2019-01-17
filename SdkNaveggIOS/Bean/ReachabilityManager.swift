//
//  ReachabilityManager.swift
//  SdkNaveggIOS
//
//  Created by Navegg on 22/01/18.
//  Copyright © 2018 Navegg. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityManager {
    
    static let shared = ReachabilityManager()
    var hasCreateNotificationCenter : Bool = false
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var user:User?
    var defaults:UserDefaults?
    
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
    
    public func getTypeConnection()->String{
        var type : String = ""
        switch reachability.connection {
        case .wifi:
            type = "Wi-Fi"
        case .cellular:
            type = "4G"
        case .none:
            type = "Sem Internet"
        }
        
        do {
            try reachability.startNotifier()
        } catch {

        }
        return type
    }
    
    @objc
    private func reachabilityChanged(_ note: Notification) {
        
        DispatchQueue.main.async {
            self.reachability.whenReachable = { reachability in
                    
                if reachability.connection == .wifi {
                    self.user?.sendDataSaveInDefault()
                } else {

                }
            }
            self.reachability.whenUnreachable = { _ in
                DispatchQueue.main.async {
                    //Sem conexao
                }
            }
        }
    }
    
    @objc
    private func backGroundReachabilityChanged(_ note: Notification) {
        self.user?.sendDataSaveInDefault()
    }
    
    func startApplicationDidEnterBackground(user:User) {
        self.user = user;
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backGroundReachabilityChanged(_:)),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        do {
            try reachability.startNotifier()
        } catch {
            // "could not start reachability notifier"
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring(user:User) {
        self.user = user;
        self.stopMonitoring()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: Notification.Name.reachabilityChanged,
            object: reachability
        )
        do {
            try reachability.startNotifier()
        } catch {
           //"could not start reachability notifier"
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name.reachabilityChanged,
            object: reachability
        )
    }
    
    func isCreateNotificationCenter() -> Bool {
        return hasCreateNotificationCenter
    }
    
    func createNotificationCenter(create:Bool) {
        self.hasCreateNotificationCenter = create
    }
}
