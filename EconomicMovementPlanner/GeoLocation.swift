//
//  GeoLocation.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 24/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps

class LocationManager{
    
    static func getGPSLocationIn(completion: (_ location: CLLocation) -> Void) {
        let locManager = CLLocationManager()
        var currentLocation: CLLocation!
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location
            
            let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            
            completion(location)  // your block of code you passed to this function will run in this way
            
        }

}
}

