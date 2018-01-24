//
//  LocationPostion.swift
//  SdkNaveggIOS
//
//  Created by Navegg on 24/01/18.
//  Copyright © 2018 Navegg. All rights reserved.
//

import Foundation
import CoreLocation

class LocationPosition:NSObject,CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    public static let sharedLocation = LocationPosition()
    var latitude:String = ""
    var longitude:String = ""
    
    func determineMyCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
        
        //        locationManager.delegate = self
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.requestWhenInUseAuthorization()
        //        locationManager.startUpdatingLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied: break
//                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
//                print("Access")
                locationManager.startUpdatingLocation()
            }
        } else {
//            print("Location services are not enabled")
        }
        
//        if CLLocationManager.locationServicesEnabled() {
//            print("Atualizando Localizacao")
//              locationManager.startUpdatingLocation()
//
//            //locationManager.startUpdatingHeading()
//        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            self.locationManager = CLLocationManager();
        }
    }
    
    
    public func getPositionLatitude()->String{
        return self.latitude
    }
    
    public func getPositionLongitude()->String{
        return self.longitude
    }
    
}
