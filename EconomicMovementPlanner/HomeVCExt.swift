//
//  HomeVCExt.swift
//  EconomicMovementPlanner
//
//  Created by talha on 22/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit
import KYDrawerController


extension HomeVC { 
    
    func getDataTripDataFromFirebase(dbID : String, count : Int){
    
        print("Getting List From Car")
        print(AuthServices.shared.userValue, AuthServices.shared.carId,dbID)
        
        
        if let userID =  AuthServices.shared.userValue, let carID  =  AuthServices.shared.carId{
            
            let dbRef =   Database.database().reference().child("Routes").child( userID)
               let dbRefForCar =   Database.database().reference().child("Car Details").child( userID)
               let carvalue = dbRefForCar.child(carID).observe(.value) { (snap) in
                   
                   print(snap.value)
                   
                   if let data = snap.value as? [String : Any]{
                       
                       let temp = CarModel(data: data)
                       print(temp.Car_Id)
                       self.curretCar = temp
                       
                       let values = dbRef.child( carID).observe(.value) { (snap) in
                           
                           print(snap.value)
                           
                           
                           if let newData = snap.value{
                               
                               if let parser = newData as? [String : Any]{
                                   print(parser.count)
                                   
                                   for data in parser{
                                       
                                       do {
                                           
                                           let model = try FirebaseDecoder().decode(TripData.self, from: data.value)
                                           print(model.trip_date)
                                           self.listData.append(model)
                                           
                                       } catch let error {
                                           print(error)
                                       }
                                   }

                                   
                                   DispatchQueue.main.async {
                                       
                                      self.endRouteView.alpha = 0
                                       self.googleMapView.clear()
                                       self.navigationImgView.alpha = 0
                                       
                                       let controller = RoutesViewController()
                                       controller.listData = self.listData
                                       controller.curretCar = self.curretCar
                                      // controller.newCount = count
                                    
                                           controller.newCount = count
                                       controller.customCompletion = {
                                           
                                           self.endRouteView.alpha  = 0
                                           
                                           if !(self.compareArr.isEmpty){
                                               self.compareArr.removeFirst()
                                               self.compareArr.sort { (val1, val2) -> Bool in
                                                   
                                                   let d1  = CLLocation(latitude: val1.lat!, longitude: val1.long!)
                                                   let d2  = CLLocation(latitude: val2.lat!, longitude: val2.long!)
                                                   let result = d1.distance(from: d2)
                                                   let result2 = d2.distance(from: d1)
                                                   
                                                   if (result>result2){
                                                       
                                                       return true
                                                   }
                                                   return false
                                               }
                                               self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateLOC), userInfo: nil, repeats: true)
                                               self.googleMapView.clear()
                                               let marker  = GMSMarker()
                                               marker.position = CLLocationCoordinate2D(latitude:  self.compareArr[0].lat!, longitude:  self.compareArr[0].long!)
                                               marker.map = self.googleMapView
                                               
                                               self.locArray = self.compareArr
                                               
                                               self.destinatioName = self.compareArr[0].lineString!
                                               let dst = CLLocationCoordinate2D(latitude: self.compareArr[0].lat!, longitude:  self.compareArr[0].long!)
                                               let src = self.currentCoordinateValue
                                               self.draw(src: src!, dst:dst)
                                               
                                               
                                               
                                           }else{
                                               
                                               HomeVC.instantiateViewController()
                                           }
                                           
                                             
                   
                                           }
                                   
                                       
                                       
                                       self.present(controller,animated: true,completion: nil)
                                   }
                                   
                               }else{
                                   print("Parser is not working")
                               }
                           }
                       }
                   }
               }
        }else{
            
            print("\n\n The trip data is nil here \n\n")
        }
   
    }
    
    
    
        
}



extension HomeVC{
    
    func endRouteHandling(){
        self.endRouteView.alpha  = 0
        
        if !(self.compareArr.isEmpty){
            self.compareArr.removeFirst()
            self.compareArr.sort { (val1, val2) -> Bool in
                
                let d1  = CLLocation(latitude: val1.lat!, longitude: val1.long!)
                let d2  = CLLocation(latitude: val2.lat!, longitude: val2.long!)
                let result = d1.distance(from: d2)
                let result2 = d2.distance(from: d1)
                
                if (result>result2){
                    
                    return true
                }
                return false
            }
            self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateLOC), userInfo: nil, repeats: true)
            self.googleMapView.clear()
            let marker  = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:  self.compareArr[0].lat!, longitude:  self.compareArr[0].long!)
            marker.map = self.googleMapView
            
            self.locArray = self.compareArr
            
            self.destinatioName = self.compareArr[0].lineString!
            let dst = CLLocationCoordinate2D(latitude: self.compareArr[0].lat!, longitude:  self.compareArr[0].long!)
            let src = self.currentCoordinateValue
            self.draw(src: src!, dst:dst)
            
            
            
        }else{
            
            HomeVC.instantiateViewController()
        }
    }
}
