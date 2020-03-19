//
//  MapExtensionVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 19/03/2020.
//  Copyright © 2020 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit
import KYDrawerController
import Firebase




class MapExtensionVC: UIViewController {
    
    var locationManager : LocManager!
    @IBOutlet weak var googleMapView: GMSMapView!

    
    var currentCoordinates = (lat : 0.0, lang : 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleMapView.delegate = self
        locationManager = LocManager(self)
        locationManager.currentLatLong = { (lat, lang) in
            print("\n\nThe current Lat and Lang",lat,lang)
            self.currentCoordinates = (lat: lat!, lang : lang!)
            DispatchQueue.main.async {
                self.callGoogleMap(lat: lat!, long: lang!)
            }
        }
        
        
    }
    
}


extension MapExtensionVC : StoryboardInitializable{
    
    
    func callCurrentLocation(){
        print("Back")
        
        self.callGoogleMap(lat: self.currentCoordinates.lat, long: self.currentCoordinates.lang)
    }
    
    func callGoogleMap(lat : Double, long : Double){
        
        print("ThE GoOglE MaP CoOrDiNate",lat,long)
        let camera = GMSCameraPosition.camera(withLatitude:lat, longitude: long, zoom: 15)
        // self.googleMapView.animate(toZoom: 40)
        self.googleMapView?.isMyLocationEnabled = true
        self.googleMapView.animate(to: camera)
        self.locationManager.stopUpdateLocation()
        
    }
}


extension MapExtensionVC : GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("good yarr")
    }
    
}



