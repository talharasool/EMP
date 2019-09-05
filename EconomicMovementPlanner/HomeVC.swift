//
//  HomeVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 24/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit
import KYDrawerController


protocol PaceCellDelegate : class {
    func getData(arr  :[CoordinatesValue])
}

class HomeVC: UIViewController  {
    
    @IBOutlet weak var makingRoutesView: UIView!
    @IBOutlet weak var goolePaceSerachBtn: UIImageView!
    @IBOutlet weak var googleMapView: GMSMapView!
    var GMSCamera : GMSCameraPosition!
    var Place : GMSPlace!
    @IBOutlet weak var addLocationView: UIView!
    @IBOutlet weak var navigationBtnView: UIView!
    
    var  marker : GMSMarker!
    var placesClient: GMSPlacesClient!
    
    var locArray : [CoordinatesValue] = []
    
    var currentCoordinate : CLLocation! = nil
    var selectedCoordinate : CLLocation! = nil
    
    var locationManger = CLLocationManager()
    
    var lat : Double!
    var long : Double!
  
    @IBOutlet weak var openGoogleSearchController: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleMapView.delegate = self
      
    
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
        
        navigationBtnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getCurrentLoc(sender:))))
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        
        
        makingRoutesView.isUserInteractionEnabled = true
        makingRoutesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openLocationList)))
        
        openGoogleSearchController.isUserInteractionEnabled  =  true
        openGoogleSearchController.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPlacePicker)))

        
    }
    
    

    
    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.title = "Home"
     //   self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    

    @IBAction func menuButtonAction(_ sender: Any) {
        
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

//        self.searchBtnView.layer.cornerRadius =   self.searchBtnView.frame.width/2
        self.addLocationView.layer.cornerRadius = self.addLocationView.frame.width/2
        self.navigationBtnView.layer.cornerRadius = self.navigationBtnView.frame.width/2
        
    }
}


extension HomeVC : CLLocationManagerDelegate, GMSMapViewDelegate{
    
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
        
        if marker == nil
        {
            marker = GMSMarker()
            marker.position = coordinates
            let image = UIImage(named:"destinationmarker")
            marker.icon = image
            marker.map = googleMapView
           // destinationMarker.appearAnimation = kGMSMarkerAnimationPop
        }
        else
        {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            marker.position =  coordinates
            CATransaction.commit()
        }
        
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {

        print("good yarr")
        var destinationLocation = CLLocation()
        
    
        
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        print("Tapping On Map")
        return true
    }
    
    
  
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Placing Position")
        print(mapView.myLocation)
       
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            //
            if error != nil {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            } else {
                if let places = response?.results() {
                    
                    if let place = places.first {
                        
                        
                        if let lines = place.lines {
                            print("GEOCODE: Formatted Address: \(lines)")
                            
                            let temp = CoordinatesValue(lineString: lines.first ?? "", title: "", lat: coordinate.latitude, long: coordinate.longitude)
                            
                            self.locArray.append(temp)
                        }
                        
                        if let newPlace = place.postalCode{
                            print(newPlace)
                        }
                        
                    }else {
                        
                        print("GEOCODE: nil first in places")
                        
                    }
                } else {
                    
                    print("GEOCODE: nil in places")
                    
                }
            }
        }
        
        
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker = GMSMarker(position: position)
        marker.title = ""
        marker.map = mapView
        
        self.selectedCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
    let distanceInMeters : CLLocationDistance = self.currentCoordinate.distance(from: selectedCoordinate)
        
        print(distanceInMeters)
        print("The CURRENT LAT \(lat) & LONG \(long)")
    //    self.draw(src: CLLocationCoordinate2D(latitude: lat, longitude: long), dst: coordinate)
        
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        print("Map Is moving now")
        print(mapView.myLocation?.altitude)
        
    }
    
   
    @objc func openLocationList(){
        
        let vc = PacesTableXIB()
      vc.delegate = self
        vc.array = self.locArray
        
    
        self.present(vc,animated:  true)
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("The error in updating location :\(error)")
       
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            print("Good to go and use location")
            
        case .denied:
            print("DENIED to go and use location")
            
        case .restricted:
            print("RESTRICTED to go and use location")
            
        case .notDetermined:
            print("NOT DETERMINED to go and use location")
        default:
            print("Unable to read location :\(status)")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
   
        let location = locations.last
        print("The CURRENT location is :\(location)")
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 12)
       
        self.googleMapView?.isMyLocationEnabled = true
        self.googleMapView.animate(to: camera)
        lat = location?.coordinate.latitude
        long = location?.coordinate.longitude
        self.GMSCamera = GMSCameraPosition(latitude: location!.coordinate.latitude , longitude: location!.coordinate.longitude, zoom: 50)
        marker = GMSMarker()
        
        marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
        marker.title = ""
        marker.map = googleMapView
        
        googleMapView.animate(to: GMSCamera)
        marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: location!.coordinate.longitude)
        self.currentCoordinate = CLLocation(latitude: lat, longitude: long)
       // marker.map = googleMapView
        locationManger.stopUpdatingLocation()
    }
    
}


extension HomeVC {
    
//    override func loadView() {
//        // Create a GMSCameraPosition that tells the map to display the
//        // coordinate -33.86,151.20 at zoom level 6.
//
//        LocationManager.getGPSLocationIn { (location) in
//
//            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 6.0)
//            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//            view = mapView

    
//            // Creates a marker in the center of the map.
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            marker.title = "Sydney"
//            marker.snippet = "Australia"
//            marker.map = mapView
//        }
//
//    }
}


extension HomeVC : StoryboardInitializable{
    
    
    @objc func getCurrentLoc(sender : UITapGestureRecognizer){
        
        self.locationManger.startUpdatingLocation()
    }
    
    static var storyboardName: UIStoryboard.Storyboard {
        return .main
    }
    
    func draw(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dst.latitude),\(dst.longitude)&sensor=false&mode=walking&key=\(Keys.AppKeys.googleMapKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
        
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                   
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        print(json)
                        let preRoutes = json["routes"] as! NSArray
                        let routes = preRoutes[0] as! NSDictionary
                        let routeOverviewPolyline:NSDictionary = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let polyString = routeOverviewPolyline.object(forKey: "points") as! String
                        
                        DispatchQueue.main.async(execute: {
                            let path = GMSPath(fromEncodedPath: polyString)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 5.0
                            polyline.strokeColor = UIColor.red
                            polyline.map = self.googleMapView
                        })
                    }
                    
                } catch {
                    print("parsing error")
                }
            }
        })
        task.resume()
    }
}



extension HomeVC : GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print(place.name)
        
        marker = GMSMarker()
        marker.position = place.coordinate
        let image = UIImage(named:"destinationmarker")
        marker.icon = image
        marker.map = googleMapView
        
    
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {

        Alert.showLoginAlert(Message: "Sorry Something went wrong with location", title: "", window: self)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func openPlacePicker(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
}




extension HomeVC{
    
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
           
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                  //  self.nameLabel.text = place.name
                   // self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                     
                }
            }
        })
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if marker != nil {
             marker.position = position.target
            
        }
        
    }
}

extension HomeVC  {

    
}



struct CoordinatesValue{
    
    let lineString : String?
    let title : String?
    let lat : Double?
    let long : Double?
    
}


extension HomeVC : PaceCellDelegate{
    func getData(arr: [CoordinatesValue]) {
        
        
        for data in arr{
            
            self.draw(src: CLLocationCoordinate2D(latitude: lat, longitude: long), dst: CLLocationCoordinate2D(latitude: data.lat!, longitude: data.long!))
        }
    }
}
