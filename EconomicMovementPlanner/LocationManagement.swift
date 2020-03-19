//
//  LocationManagement.swift
//  Boxeyi
//
//  Created by talha on 03/10/2019.
//  Copyright © 2019 Boxeyi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class LocManager : NSObject{
    
    var permission : ((Bool?)->())?
    var currentLatLong : ((Double?, Double?)->())?
    var distanceFigure : ((Double?, Double?)->())?
    
    private var locationManager : CLLocationManager!
    
    private var c_Coordinates  : CLLocationCoordinate2D!
    private var p_Coordinates  : CLLocationCoordinate2D!
    
    
    init(_ vc : UIViewController) {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = vc as? CLLocationManagerDelegate
        setUpLocationManagerDelegate()
    }
    
}

extension LocManager : CLLocationManagerDelegate {
    
    fileprivate func setUpLocationManagerDelegate(){
           locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestWhenInUseAuthorization()
         locationManager.requestLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
         
       }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lat  = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude{
            print("\n\nThe current Lat/Long Is Here\n\n")
            
            
            if self.p_Coordinates != nil{
               
                print("\n\n Previous Corrdinate is not NIL \n\n")
                self.c_Coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                print("\n The Coordinates is here",self.c_Coordinates,self.p_Coordinates)
                var c_Distance  = CLLocation(latitude: self.c_Coordinates.latitude, longitude:  self.c_Coordinates.longitude)
                var p_Distance  = CLLocation(latitude: self.p_Coordinates.latitude, longitude:  self.p_Coordinates.longitude)
                
                var difference : CGFloat = CGFloat(c_Distance.distance(from: p_Distance))
                
                print("\n\n Both coordinates are here")
                print("\n\nPrevious coordinates ",self.p_Coordinates)
                print("\n\nCurrent Coordinates",self.c_Coordinates)
                
                print("The currenent differnce is here",difference)
               // self.stopUpdateLocation()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    
                    guard let self  = self else {return}
                    print("\n\n Global SYNC DATA \n\n")
                    self.currentLatLong!(lat,long)
                    self.p_Coordinates = self.c_Coordinates
                    
                }
                
                
//                if (difference > 50){
//                    
//             
//                }else{
//                    
                   //currentLatLong!(nil,nil)
//                }
                
            }else{
                print("\n\n Previous Corrdinate is NIL \n\n")
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.p_Coordinates = coordinates
                let param = ["currentLocation": ["lat" : lat, "lng" : long]]
                print("params are", param)
                currentLatLong!(lat,long)
             
            }
            
            
            self.stopUpdateLocation()
                         
           
         //   LocationManagement.updateLocationOnServer(param: param)
            
        }else{
            print("Unable To Access Locaion")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            print("Good to go and use location")
            locationManager.startUpdatingLocation()
            self.callPermisssionCompletion(val: true)
            
        case .denied:
            print("DENIED to go and use location")
            self.callPermisssionCompletion(val: false)
            
        case .restricted:
            print("DENIED to go and use location")
           // self.callPermisssionCompletion(val: false)
            
        case .notDetermined:
            print("DENIED to go and use location")
            //self.callPermisssionCompletion(val: false)
            
        default:
            print("Unable to read location :\(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error in fetching Location", error.localizedDescription)
    }
    
    
    fileprivate func callPermisssionCompletion(val : Bool?){
     
        guard let comp = self.permission else {
            print("\n\n Unable to  locate completions \n\n")
            return
        }
        if let val =  val{
            comp(val)
        }
        
    }
    
    fileprivate func getDistance(lat : Double, long : Double){
        
    }
    
    open func updateLocation(){
        self.locationManager.startUpdatingLocation()
    }
    open func stopUpdateLocation(){
          self.locationManager.stopUpdatingLocation()
      }
    
    
}
