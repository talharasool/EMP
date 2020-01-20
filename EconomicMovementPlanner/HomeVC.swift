
//  HomeVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 24/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit
import KYDrawerController
import Firebase
import GoogleMobileAds

protocol PaceCellDelegate : class {
    func getData(arr  :[CoordinatesValue])
    func cancelRouter()
}

typealias valCompletion = (Bool)->()

class HomeVC: UIViewController  {
    
    @IBOutlet weak var signgletripCancelBtn: UIButton!
    @IBOutlet weak var gadView: GADBannerView!
    //Buttons
    @IBOutlet weak var okBtnOutlet: UIButton!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var endRouteBtnOutlet: UIButton!
    
    //Map
    @IBOutlet weak var googleMapView: GMSMapView!
    var zoom : Float = 16
    //View
    @IBOutlet weak var endRouteView: UIView!
    @IBOutlet weak var makingRoutesView: UIView!
    @IBOutlet weak var openGoogleSearchController: UIView!
    @IBOutlet weak var addLocationView: UIView!
    @IBOutlet weak var navigationBtnView: UIView!
    
    //ImgView
    @IBOutlet weak var goolePaceSerachBtn: UIImageView!
    @IBOutlet weak var navigationImgView: UIImageView!
   
    //Handling coordinates
    var currentCoordinateValue : CLLocationCoordinate2D!
    var previousCoordinateValue : CLLocationCoordinate2D!
    var pointerCoordinate : CLLocationCoordinate2D!
    var draggingCoordinate : CLLocationCoordinate2D!
   
    
    var placeTitle : String = ""
    //Coordinates Array
    var originalArr : [CoordinatesValue] = []
    var compareArr : [CoordinatesValue] = []
    
    //Google Maps and Marker
    var  marker : GMSMarker!
    var placesClient: GMSPlacesClient!
    var mainMarker  = GMSMarker()
    var GMSCamera : GMSCameraPosition!
    var Place : GMSPlace!

    //Strings
    var currentTime : String!
    var destinatioName : String = ""
    var startLocation : String = ""
    var currentDBKey : String = ""
    var startPoint : String = ""
    var titleCanel = "Trip Cancel"
    
    //Structs Object
    var serverObj : [tripServerData] = []
    var locArray : [CoordinatesValue] = []
    var placeName : [PlaceData] = []
    var listData : [TripData] = []
    var curretCar : CarModel!
    
    //Distance calculator and timer
    var timer : Timer!
    var currentCoordinate : CLLocation! = nil
    var selectedCoordinate : CLLocation! = nil
    
    var locationManger = CLLocationManager()
    
    //Double
    var lat : Double!
    var long : Double!
    var fuel : Double!
    var calculatedDistance :  Double!
    var distanceValue : Double = 0.0
    
    var tempArray : [[String : Any]] = [[:]]
    let activity = UIActivityIndicatorView()
    
    //Checks
    static var isFirst : Bool!
    var isTripStart : Bool = false
    
    //Time Differnce Calculation
    var startTime : Date!
    var endTime : Date!
    var isdragDisable = false
   func isHiddenEndRouteView(val : Bool){
         if val  {self.endRouteView.alpha = 0}else{self.endRouteView.alpha = 1}
     }
   func isHiddenOkBtn(val : Bool){
            if val  {self.okBtnOutlet.alpha = 0}else{self.okBtnOutlet.alpha = 1}
        }
   func isHiddenCancelBtn(val : Bool){
             if val  {self.cancelBtnOutlet.alpha = 0}else{self.cancelBtnOutlet.alpha = 1}
         }
   func isHiddenALV(val : Bool){
              if val  {self.addLocationView.alpha = 0}else{self.addLocationView.alpha = 1}
          }
   func isHiddenGS(val : Bool){
              if val  {self.openGoogleSearchController.alpha = 0}else{self.openGoogleSearchController.alpha = 1}
          }
   func isHiddenNV(val : Bool){
               if val  {self.navigationBtnView.alpha = 0}else{self.navigationBtnView.alpha = 1}
           }
   func isHiddenMRV(val : Bool){
                 if val  {self.makingRoutesView.alpha = 0}else{self.makingRoutesView.alpha = 1}
             }
   func isHiddenNBIV(val : Bool){
                   if val  {self.navigationImgView.alpha = 0}else{self.navigationImgView.alpha = 1}
               }
    
    func hideView<T:UIView>(v : T,val : Bool){
        if val  {v.alpha = 0}else{v.alpha = 1}
    }
    
    func setUpLocationManager(){
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestAlwaysAuthorization()
    }
    
    
    func addCustomLocationAction(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionOnAdd))
        self.addLocationView.isUserInteractionEnabled = true
        self.addLocationView.addGestureRecognizer(tap)
    }
    
    @objc func actionOnAdd(){
        
        isHiddenALV(val: true)
        isHiddenMRV(val: true)
        isHiddenOkBtn(val: false)
        isHiddenCancelBtn(val: false)
        placeTempMarkerAtCoordinate(currentCoordinate: self.currentCoordinateValue)
        
    }
    
    @objc func actionOnPlaceVC(){
        
        isHiddenALV(val: true)
        isHiddenMRV(val: true)
        isHiddenOkBtn(val: false)
        isHiddenCancelBtn(val: false)
        
    }
    
    
    @objc func addActionOnCancel(sender : UIButton){
        
        if isTripStart {
            self.openVC()
        }else{
             manageLoctingView()
        }
    }
    
    func manageLoctingView(){
        self.isHiddenCancelBtn(val: true)
        self.isHiddenOkBtn(val: true)
        self.isHiddenALV(val: false)
        self.isHiddenMRV(val: false)
        
        self.mainMarker.map = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegates And Action
        googleMapView.delegate = self
        self.setUpLocationManager()
        self.setUpAction()
        self.googleMapView.settings.allowScrollGesturesDuringRotateOrZoom = true
        self.googleMapView.animate(toZoom: 16)
        let mapDrag = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(_:)))
        self.googleMapView.addGestureRecognizer(mapDrag)
        self.signgletripCancelBtn.backgroundColor = UIColor.red
        setUpAlpha(alpha: 0)
        hideViewsOnMainView()
      
        //Setup Navigation bar
        self.setUpNavigationBar()
        
        self.signgletripCancelBtn.addTarget(self, action: #selector(endSingleRoute(sender:)), for: .touchUpInside)
        
        hideView(v: self.signgletripCancelBtn, val: true)
        //Enabling Intractions and setup View
        navigationImgView.isUserInteractionEnabled = true
        makingRoutesView.isUserInteractionEnabled = true
        openGoogleSearchController.isUserInteractionEnabled  =  true
        self.endRouteBtnOutlet.bringSubviewToFront(self.googleMapView)
        self.gadView.bringSubviewToFront(self.googleMapView)
            // self.googleMapView.alpha = 0
        self.googleMapView.settings.consumesGesturesInView = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.addBanner()
        }
        
    }
    
    func hideViewsOnMainView(){
        isHiddenEndRouteView(val: true)
        isHiddenOkBtn(val: true)
        isHiddenCancelBtn(val: true)
        isHiddenMRV(val: true)
    }
    
    
    func setUpNavigationBar(){
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        self.setupNavigationBtn(alpha: 0)
    }
    
    //BtnActions
    func setUpAction(){
        
        self.openGM()
        self.addCustomLocationAction()
        
        self.okBtnOutlet.addTarget(self, action: #selector(placeMarkerPointOnDrag), for: .touchUpInside)
        navigationBtnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getCurrentLoc(sender:))))
        openGoogleSearchController.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPlacePicker)))
        makingRoutesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openLocationList)))
        self.cancelBtnOutlet.addTarget(self, action: #selector(addActionOnCancel(sender:)), for: .touchUpInside)
        self.endRouteBtnOutlet.addTarget(self, action: #selector(endRoute(sender:)), for: .touchUpInside)
        
        
    }
    
    func openGM(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(openGoogleMaps))
        self.navigationImgView.addGestureRecognizer(tap)
    }
    
     
    
    func setupNavigationBtn(alpha : CGFloat){
        self.navigationImgView.alpha = alpha
    }
    

    @objc func updateLOC(){
        print("Updating location")
        locationManger.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManger.startUpdatingLocation()
        

        
        // self.addBanner()
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
        self.makingRoutesView.layer.cornerRadius = self.makingRoutesView.frame.width/2
        self.openGoogleSearchController.layer.cornerRadius = self.openGoogleSearchController.frame.width/2
        self.addLocationView.layer.cornerRadius = self.addLocationView.frame.width/2
        self.navigationBtnView.layer.cornerRadius = self.navigationBtnView.frame.width/2
        self.endRouteBtnOutlet.getRoundedcorner(cornerRadius: self.endRouteBtnOutlet.frame.height/2)
        self.navigationImgView.getRoundedcorner(cornerRadius: self.navigationImgView.frame.height/2)
        self.cancelBtnOutlet.getRoundedcorner(cornerRadius: self.cancelBtnOutlet.frame.height/2)
        self.okBtnOutlet.getRoundedcorner(cornerRadius: self.okBtnOutlet.frame.height/2)
        self.signgletripCancelBtn.getRoundedcorner(cornerRadius: self.signgletripCancelBtn.frame.height/2)
        
        
    }
    
}

//Location Manager Function here you can handel the locatio

extension HomeVC{
        
    

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            switch status {
            case .authorizedAlways,.authorizedWhenInUse:
                print("Good to go and use location")
                
            case .denied:
                print("DENIED to go and use location")
              //   Alert.showLoginAlert(Message: "Sorry Please Enable Location", title: "", window: self)
                self.setUpAlpha(alpha: 0)
            case .restricted:
                print("RESTRICTED to go and use location")
                 //Alert.showLoginAlert(Message: "Sorry Please Enable Location", title: "", window: self)
                self.setUpAlpha(alpha: 0)
            case .notDetermined:
                print("NOT DETERMINED to go and use location")
             //   Alert.showLoginAlert(Message: "Sorry Please Enable Location", title: "", window: self)
                self.setUpAlpha(alpha: 0)
                
            default:
                print("Unable to read location :\(status)")
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            
            print("Locatio  Is updating ther")
            let location = locations.last
            print("The CURRENT location is :\(location)")
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: zoom)
            
            // self.googleMapView.animate(toZoom: 40)
  
            self.googleMapView?.isMyLocationEnabled = true
            self.googleMapView.animate(to: camera)
            
            lat = location?.coordinate.latitude
            long = location?.coordinate.longitude
            
         
            //   self.currentCoordinate = CLLocation(latitude: lat, longitude: long)
            // marker.map = googleMapView

            UIView.animate(withDuration: 3) {
                self.setUpAlpha(alpha: 1)
            }
            
            print(self.currentCoordinateValue)
            if self.currentCoordinateValue == nil {
                
                HomeVC.isFirst = true
                self.currentCoordinateValue  = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                var geocoder = CLGeocoder()

                
                locationManger.stopUpdatingLocation()
                
            }else{
                
                
                
             
                self.previousCoordinateValue = self.currentCoordinateValue
                self.selectedCoordinate = CLLocation(latitude: self.previousCoordinateValue.latitude, longitude: self.previousCoordinateValue.longitude)
                
                
                self.currentCoordinateValue  = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.currentCoordinate = CLLocation(latitude: self.currentCoordinateValue.latitude, longitude: self.currentCoordinateValue.longitude)
                
                let distanceInMeters : CLLocationDistance = self.currentCoordinate.distance(from: selectedCoordinate)
                
                print("Difference coordinates", currentCoordinateValue,previousCoordinateValue)
                
                print("\n\n\ndistande in meters")
                print(distanceInMeters)
            

                if self.startLocation.isEmpty{
                             
                             var geoCoder = CLGeocoder()
                             geoCoder.reverseGeocodeLocation(self.currentCoordinate) { (places, err) in
                                 print(places)
                                 if err != nil{return}
                                 
                                 guard let placeMark = places?.first else { return }

                                 // Location name
                                 if let locationName = placeMark.location {
                                     print("The location Name is here")
                                     print(locationName)
                                     self.startLocation = String(describing: locationName)
                                    print("The location Name is here")
                                                                    print( self.startLocation)
                                 }
                                 
                                 // Street address
                                 if let street = placeMark.thoroughfare {
                                    print("Address Street")
                                     print(street)
                                 }
                             
                                 
                                 
                             }
                         }
                
                
                if !compareArr.isEmpty{
                    //      self.selectedCoordinate = CLLocation(latitude: self.previousCoordinateValue.latitude, longitude: self.previousCoordinateValue.longitude)
                    //        let first =  CLLocation(latitude: self.currentCoordinate.latitude, longitude: self.currentCoordinate.longitude)
                    
                    //  let pointingDistance
                    
                    let filterCompreArr = self.compareArr.filter({$0.isCompleted ==  false})
                  //  31.4846739,74.3064136,14z
                    
                    let current  = CLLocation(latitude:self.currentCoordinateValue.latitude, longitude: self.currentCoordinateValue.longitude)
                    
                    print("The current", current)
                    let pointer = CLLocation(latitude:self.compareArr[0].lat!, longitude: self.compareArr[0].long!)
                    
                    let previousPointer = CLLocation(latitude:self.previousCoordinateValue.latitude, longitude: self.previousCoordinateValue.longitude)
                    let pointing = current.distance(from: pointer)
                    
                    let nowtheDistance  =  previousPointer.distance(from: current)
                    print("Now the distance value is here" , nowtheDistance )
                    print("Pointing values are here", pointing)
                    
                    self.distanceValue =  self.distanceValue + Double(pointing)
                    
                  //  self.title = String(describing: self.distanceValue)
                    
                   print("DIstance values are here", self.distanceValue)
                
                    if pointing < 100{
                        self.timer.invalidate()
                        self.locationManger.stopUpdatingLocation()
                        self.isHiddenCancelBtn(val: true)
                        self.setCancelBtn(isSet: false)
                         hideView(v: self.signgletripCancelBtn, val: true)
                        let alert = UIAlertController(title: "You have reaced your destination", message: "Do you want to continue?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                            
                        }))
                        
                        self.present(alert,animated: true,completion: {
                            self.endRouteView.alpha = 1
                            self.timer.invalidate()
                            self.locationManger.stopUpdatingLocation()
                              // self.distanceValue = 0
                            print("Comparing")
                        })
                        
                        
                    }else{
                        print("Pointing value is grea")
                        self.locationManger.stopUpdatingLocation()
                    }
                }else{
                     self.locationManger.stopUpdatingLocation()
                }
                
            }
            
    //        let image = #imageLiteral(resourceName: "menu-button (1).png")
    //
    //        self.mainMarker = GMSMarker(position: self.currentCoordinateValue)
    //        mainMarker.isDraggable = true
    //        mainMarker.icon = image
    //        mainMarker.map = self.googleMapView
    //        locationManger.stopUpdatingLocation()
    //        print("The Current Lat and Long", self.currentCoordinateValue)
    //
            
        }
}
//MAPVIEW DELEGATES
extension HomeVC : CLLocationManagerDelegate, GMSMapViewDelegate{
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        print("good yarr")
        
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        print("Tapping On Map")
        return true
    }
        
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Placing Position")
        print(mapView.myLocation)
        
    }

    
    func placeMarkerOnMapOnButtonTap(coordinate : CLLocationCoordinate2D){
        
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
                            print(self.placeTitle)
                            if self.placeTitle == ""{
                                self.placeTitle = lines.first ?? ""
                            }
                            
                            let temp = CoordinatesValue(lineString: lines.first ?? "", title:  self.placeTitle, lat: coordinate.latitude, long: coordinate.longitude, isSelect: false, isCompleted: false)
                            
                            self.locArray.append(temp)
                            self.placeTitle = ""
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
        let  marker = GMSMarker(position: position)
        marker.title = ""
        marker.map = self.googleMapView
     
        self.manageLoctingView()
        
        self.selectedCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        print("The CURRENT LAT \(lat) & LONG \(long)")
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        print("Map Is moving now")
        print(mapView.myLocation?.coordinate.latitude, mapView.myLocation?.coordinate.longitude)
    }
    
    
    func getCurrentDateTime()-> String {
        let now = Date()
        let formatter = DateFormatter()
       // formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd MMMM YYYY HH:mm:ss"
       return formatter.string(from: now)
       
    }
    
    
    func getCurrentDateTimeWithVal(_ date : Date)-> String {
        let now = Date()
        let formatter = DateFormatter()
       // formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd MMMM YYYY HH:mm:ss"
       return formatter.string(from: now)
       
    }
    
    //Action -- End_Route
    
    
    
    //New
    @objc func endSingleRoute(sender : UIButton){
        
        let currentTime  = getCurrentDateTime()
        let currdate = String(describing: Date.timeIntervalSinceReferenceDate)
        print("The Current Date is here", currentTime)
      //  self.present(info,animated: true)
        if self.compareArr.count > 0{
            
            self.endTime = Date()
            print("The Start and End time is ", self.startTime,self.endTime)
            let difference  = Calendar.current.dateComponents([.hour, .minute,.second], from: startTime, to: endTime)
         //       let formattedString = String(format: "%02ld%02ld", difference.hour!, difference.minute!)
            let formattedString = String(format: "%02ld", difference.minute!)
            print("The formatted string",formattedString)
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: difference)!
            
            let diffFormatString = getCurrentDateTimeWithVal(date)
            print(diffFormatString)
            //print(timeConversion24(time12: diffFormatString))
            if self.compareArr.count == 1{
                
                self.isHiddenCancelBtn(val: true)
                self.setCancelBtn(isSet: false)
                 hideView(v: self.signgletripCancelBtn, val: true)
                let milage =  Int(CarManger.shared.singleCarData.Mileage!)
                
                print("The new distande",self.distanceValue)
                print("The milage", milage)
                self.fuel = distanceValue/Double(milage!)
                print("fuel", self.fuel!)
                let temp = tripServerData(date_record: currentTime, distance: String(describing: distanceValue), endpoint: self.destinatioName, fuel: String(describing: fuel!), startpoint: self.startLocation, time: diffFormatString)
                
                print("Data for database", temp)
                //self.serverObj.append(temp)
                
//                self.addDataToServer { (succes) in
//                    self.distanceValue = 0
//                    print(succes)
//
//                    if succes{
//                        self.getDataTripDataFromFirebase(dbID: self.currentDBKey, count: 0)
//                    }else{
//                        print("Unable to  get list")
//                    }
//
//                }
                 self.distanceValue = 0
               // self.updateLOC()
                self.googleMapView.clear()
                self.compareArr.removeFirst()
                self.locArray.removeAll()
                self.locationManger.stopUpdatingLocation()
                
                
               // Alert.showLoginAlert(Message: "", title: "You Have completed your destination", window: self)
            }else{
                
                
                
                self.endTime = Date()
                print("The Start and End time is ", self.startTime,self.endTime)
                let difference  = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)
                //    let formattedString = String(format: "%02ld%02ld", difference.hour!, difference.minute!)
                let formattedString = String(format: "%02ld", difference.minute!)
                print("The formatted string",formattedString)
                     
            
                self.isHiddenCancelBtn(val: true)
                self.setCancelBtn(isSet: false)
                 hideView(v: self.signgletripCancelBtn, val: true)
                let milage = Int(CarManger.shared.singleCarData.Mileage!)
                let myFuel = distanceValue/Double(milage!)
                
               // let temp = tripServerData(date_record: currdate, distance: String(describing: distanceValue), endpoint: self.destinatioName, fuel: String(describing: myFuel), startpoint: self.startLocation, time: formattedString)
                
                print("\n\nThe temp of data is here")
               // print(temp)
                print("\n\n")
               // self.serverObj.append(temp)
                
    
//                self.addDataToServer { (succes) in
//
//                    print(succes)
//
//                    if succes{
//                        self.distanceValue = 0.0
//                        self.locationManger.stopUpdatingLocation()
//                        self.getDataTripDataFromFirebase(dbID: self.currentDBKey, count: self.compareArr.count)
//
//
//                    }
//                }
                
                self.endRouteHandling()
                            
            }
            
        }else{
            
            print("reached")
            Alert.showLoginAlert(Message: "", title: "You Have reached your destination", window: self)
        }
        
    }
    
    
    
    
    @objc func endRoute(sender : UIButton){
        
        let currentTime  = getCurrentDateTime()
        let currdate = String(describing: Date.timeIntervalSinceReferenceDate)
        print("The Current Date is here", currentTime)
      //  self.present(info,animated: true)
        if self.compareArr.count > 0{
            
            self.endTime = Date()
            print("The Start and End time is ", self.startTime,self.endTime)
            let difference  = Calendar.current.dateComponents([.hour, .minute,.second], from: startTime, to: endTime)
         //       let formattedString = String(format: "%02ld%02ld", difference.hour!, difference.minute!)
            let formattedString = String(format: "%02ld", difference.minute!)
            print("The formatted string",formattedString)
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: difference)!
            
            let diffFormatString = getCurrentDateTimeWithVal(date)
            print(diffFormatString)
            //print(timeConversion24(time12: diffFormatString))
            if self.compareArr.count == 1{
                
                self.isHiddenCancelBtn(val: true)
                self.setCancelBtn(isSet: false)
                 hideView(v: self.signgletripCancelBtn, val: true)
                let milage =  Int(CarManger.shared.singleCarData.Mileage!)
                
                print("The new distande",self.distanceValue)
                print("The milage", milage)
                self.fuel = distanceValue/Double(milage!)
                print("fuel", self.fuel!)
                let temp = tripServerData(date_record: currentTime, distance: String(describing: distanceValue), endpoint: self.destinatioName, fuel: String(describing: fuel!), startpoint: self.startLocation, time: diffFormatString)
                
                print("Data for database", temp)
                self.serverObj.append(temp)
                
                self.addDataToServer { (succes) in
                    self.distanceValue = 0
                    print(succes)
                    
                    if succes{
                        self.getDataTripDataFromFirebase(dbID: self.currentDBKey, count: 0)
                    }else{
                        print("Unable to  get list")
                    }
                    
                }
                
                //self.updateLOC()
                self.googleMapView.clear()
                self.compareArr.removeFirst()
                self.locArray.removeAll()
                self.locationManger.stopUpdatingLocation()
                
                
               // Alert.showLoginAlert(Message: "", title: "You Have completed your destination", window: self)
            }else{
                
                
                
                self.endTime = Date()
                print("The Start and End time is ", self.startTime,self.endTime)
                let difference  = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)
                //    let formattedString = String(format: "%02ld%02ld", difference.hour!, difference.minute!)
                let formattedString = String(format: "%02ld", difference.minute!)
                print("The formatted string",formattedString)
                     
            
                self.isHiddenCancelBtn(val: true)
                self.setCancelBtn(isSet: false)
                 hideView(v: self.signgletripCancelBtn, val: true)
                let milage = Int(CarManger.shared.singleCarData.Mileage!)
                let myFuel = distanceValue/Double(milage!)
                
                let temp = tripServerData(date_record: currdate, distance: String(describing: distanceValue), endpoint: self.destinatioName, fuel: String(describing: myFuel), startpoint: self.startLocation, time: formattedString)
                
                print("\n\nThe temp of data is here")
                print(temp)
                print("\n\n")
                self.serverObj.append(temp)
    
                self.addDataToServer { (succes) in
                    
                    print(succes)
                    
                    if succes{
                        self.distanceValue = 0.0
                        self.locationManger.stopUpdatingLocation()
                        self.getDataTripDataFromFirebase(dbID: self.currentDBKey, count: self.compareArr.count)
                                            
                        
                    }
                }
                
                
                
            }
            
        }else{
            
            print("reached")
            Alert.showLoginAlert(Message: "", title: "You Have reached your destination", window: self)
        }
        
    }
    
    

    func timeConversion24(time12: String) -> String {
        let dateAsString = time12
        let df = DateFormatter()
        df.dateFormat = "hh:mm:ss"

        let date = df.date(from: dateAsString)
        df.dateFormat = "HH:mm:ss"

        let time24 = df.string(from: date!)
        print(time24)
        return time24
    }
    
    @objc func openLocationList(){
        
        let vc = PacesTableXIB()
        vc.delegate = self
        
//        self.locArray.sort (by: { (value, valu2) -> Bool in
//
//            let ditance = CLLocation(latitude: value.lat ?? 0.0, longitude: value.long ?? 0.0)
//            let comparing = CLLocation(latitude: valu2.lat ?? 0.0, longitude: valu2.long ?? 0.0)
//            print(ditance)
//
//            let result = ditance.distance(from: comparing)
//            let result2 = comparing.distance(from: ditance)
//
//            if (result<result2){
//
//                return true
//            }
//
//
//            //            if (ditance < comparing){
//            //                return true
//            //            }
//            return false
//        })
       
        
        vc.array = self.locArray.sorted(by: { (value, valu2) -> Bool in
            
            let ditance = CLLocation(latitude: value.lat ?? 0.0, longitude: value.long ?? 0.0)
            let comparing = CLLocation(latitude: valu2.lat ?? 0.0, longitude: valu2.long ?? 0.0)
            print(ditance)
            
            let result = ditance.distance(from: comparing)
            let result2 = comparing.distance(from: ditance)
            
            if (result>result2){
                
                return true
            }
            
            
            //            if (ditance < comparing){
            //                return true
            //            }
            return false
        })
        
        self.present(vc,animated:  true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("The error in updating location :\(error)")
        
    }
        
    //Marker Placement
    @objc   func placeTempMarkerAtCoordinate(currentCoordinate : CLLocationCoordinate2D){
        
        let image = UIImage(named: "pins")
        self.mainMarker = GMSMarker(position: currentCoordinate)
        mainMarker.isDraggable = true
        mainMarker.icon = image
        mainMarker.map = self.googleMapView
        locationManger.stopUpdatingLocation()
        print("The Current Lat and Long", currentCoordinate)
        
    }
    
    
    
}

//Map Dragging Delgates And Function
extension HomeVC {
    
    
    
    

    @objc func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
           print("Map drag began")
           self.locationManger.stopUpdatingLocation()
       }
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
           print("Map drag ended")
           updateLOC()
       }
    }
    
    
     func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
         print("drag doing")
         print(mapView.myLocation?.coordinate)
     }
     
     func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
         
         print("End dragging")
         let coordinate = mapView.myLocation!.coordinate
         print(coordinate)
         self.draggingCoordinate = marker.position
       
        // self.placeMarkerOnMapOnButtonTap(coordinate: marker.position)
     
     }
     
     func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("End dragging")
         self.draggingCoordinate = marker.position
     }
     
    
    @objc func placeMarkerPointOnDrag(){
        
        
        if self.draggingCoordinate == nil{
             self.placeMarkerOnMapOnButtonTap(coordinate: self.currentCoordinateValue)
        }else{
             self.placeMarkerOnMapOnButtonTap(coordinate: self.draggingCoordinate)
        }
        
    }

}


extension HomeVC : StoryboardInitializable{
    
    
    @objc func getCurrentLoc(sender : UITapGestureRecognizer){
        
        self.locationManger.startUpdatingLocation()
    }
    
    static var storyboardName: UIStoryboard.Storyboard {
        return .main
    }
    
    func draw(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D){
        
        
        self.startAnimating()
        self.locationManger.startUpdatingLocation()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dst.latitude),\(dst.longitude)&sensor=false&mode=walking&key=\(Keys.AppKeys.googleMapKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            
            DispatchQueue.main.async {
                
                self.stopAnimating()
                if error != nil {
                    self.isTripStart = false
                    self.stopAnimating()
                    print(error!.localizedDescription)
                } else {
                    do {
                        
                        if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                            let preRoutes = json["routes"] as! NSArray
                            let routes = preRoutes[0] as! NSDictionary
                            let routeOverviewPolyline:NSDictionary = routes.value(forKey: "overview_polyline") as! NSDictionary
                            let polyString = routeOverviewPolyline.object(forKey: "points") as! String
                            print(preRoutes)
                            let address = preRoutes[0] as! NSDictionary
                            
                            let legs = address["legs"] as! NSArray
                            let addLeg = legs[0] as! NSDictionary
                           
                           // self.startLocation = address["start_address"] as! String
                            print(address["legs"])
                            
                            let newAddess = legs[0] as! NSDictionary
                            print(newAddess)
                            print(newAddess["start_address"])
                            let addVal = newAddess["start_address"] as! String
                            self.startLocation = addVal
//                            let stateAddres  = preRoutes.firstObject["legs"]
//                            let firstdata = stateAddres[0] as! NSDictionary
//                            let loc = firstdata["start_address"] as! String
//                            print("Loc",loc)
                            DispatchQueue.main.async(execute: {
                                self.setupNavigationBtn(alpha: 1)
                                let path = GMSPath(fromEncodedPath: polyString)
                                let polyline = GMSPolyline(path: path)
                                polyline.strokeWidth = 8.0
                                polyline.strokeColor = UIColor.blue
                                polyline.map = self.googleMapView
                                self.isTripStart = true
                                self.setCancelBtn(isSet: true)
                                self.hideView(v: self.signgletripCancelBtn, val: false)
                                self.isHiddenCancelBtn(val: false)
                                self.startTime = Date()
                                print("The Start time is ", self.startTime)
                                
                            })
                        }
                        
                    } catch {
                         self.isTripStart = false
                        print("parsing error")
                    }
                }
            }

        })
        task.resume()
    }
    
    func setCancelBtn(isSet : Bool){
        if isSet{
            self.cancelBtnOutlet.setTitleColor(UIColor.white, for: .normal)
            self.cancelBtnOutlet.backgroundColor  = UIColor.red
            self.cancelBtnOutlet.setTitle(titleCanel, for: .normal)
            self.cancelBtnOutlet.titleLabel?.font  = UIFont.systemFont(ofSize: 10)
          
        }else{
            self.cancelBtnOutlet.setTitleColor(UIColor.white, for: .normal)
            self.cancelBtnOutlet.backgroundColor  = UIColor.init(netHex: 0x6F7179)
            self.cancelBtnOutlet.setTitle("Cancel", for: .normal)
            self.cancelBtnOutlet.titleLabel?.font  = UIFont.systemFont(ofSize: 10)
        }
        
    }
}


//Autocompte GMSMapView
extension HomeVC : GMSAutocompleteViewControllerDelegate{
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("The Current Address is Here")
        print(place.name)
        print(place.addressComponents)
        self.placeTitle = place.name ?? ""
        //self.placeName.append(PlaceData(placeName: place.name, placeAddress: place.name, TimeFormat: ""))
//        let temp = CoordinatesValue(lineString:  place.name!, title: place.name!, lat: place.coordinate.latitude, long: place.coordinate.longitude, isSelect: false, isCompleted: false)
//
//        self.locArray.append(temp)
//
//        let tempMarker = GMSMarker()
//        tempMarker.title = place.name
//        tempMarker.position = place.coordinate
//        // tempMarker.v  self.googleMapView.
//        let image = UIImage(named:"destinationmarker")
//        tempMarker.icon = image
//        tempMarker.map = googleMapView
       // self.draggingCoordinate = place.coordinate
    
        viewController.dismiss(animated: true, completion: {
           // self.actionOnPlaceVC()
            
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16)
            self.googleMapView.animate(to: camera)
            self.draggingCoordinate = place.coordinate
   
            let image = UIImage(named: "pins")
            self.mainMarker = GMSMarker(position: place.coordinate)
            self.mainMarker.isDraggable = true
            self.mainMarker.icon = image
            self.mainMarker.map = self.googleMapView
            self.actionOnPlaceVC()
        })
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

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        var zoom : Float = mapView.camera.zoom
    
        print("\n\n :: New zoom value ::\t",mapView.camera.zoom)
        
//        if mapView.camera.zoom < 16{
//            self.zoom = 16
//        }else{
//             self.zoom = zoom
//        }
        print(mapView.camera.zoom)
       
    }
}

extension HomeVC : PaceCellDelegate{
    
    func openVC(){
        let drawerVC = DrawerVC.instantiateViewController() as? DrawerVC
    
        
        let MainSB = KYDrawerController.instantiateViewController()
        
        //     AppDelegate.allUser = filter.first!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = MainSB
    }
    
    func getData(arr: [CoordinatesValue]) {
        
        print("The Current Array \(arr)")
        self.isdragDisable = true
        print("The Current Coordiante after Point", self.currentCoordinateValue)
        self.isHiddenMRV(val: true)
        self.compareArr = arr
        self.destinatioName = self.compareArr[0].lineString!
        self.draw(src: CLLocationCoordinate2D(latitude: lat, longitude: long), dst: CLLocationCoordinate2D(latitude: arr[0].lat!, longitude: arr[0].long!))
        
        self.pointerCoordinate = CLLocationCoordinate2D(latitude: compareArr[0].lat!, longitude: compareArr[0].lat!)
        print("The Radius is here", self.googleMapView.getRadius())
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateLOC), userInfo: nil, repeats: false)
        
    }
    
    func cancelRouter() {
        
        self.isHiddenMRV(val: true)
        self.googleMapView.clear()
        self.locArray.removeAll()
    }
    
    
    
    func setUpAlpha(alpha : CGFloat){
    
        self.openGoogleSearchController.alpha = alpha
        self.addLocationView.alpha = alpha
        self.navigationBtnView.alpha = alpha
    }
}


//DB AND ACTIVITY ACTIONS
extension HomeVC {

    func startAnimating(){
        
        //   UIApplication.shared.beginIgnoringInteractionEvents()
        let width  = self.view.frame.width/2
        let height = self.view.frame.height/2
        activity.style = .whiteLarge
        activity.color = UIColor.black
        activity.backgroundColor = UIColor.white
        activity.frame = CGRect(x: width , y: height, width: 100, height: 100)
        let label  = UILabel()
        activity.layer.cornerRadius = 4
        activity.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        label.center = CGPoint(x:activity.frame.width/2, y: activity.frame.height/2 + 30)
        
    
        label.text =  "Please wait making route for you"
        label.textAlignment  = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 8, weight: .semibold)
        activity.addSubview(label)
        activity.startAnimating()
        self.navigationController!.view.addSubview(activity)
        
    }
    
    func stopAnimating(){
        
        UIApplication.shared.endIgnoringInteractionEvents()
        activity.stopAnimating()
    }
}


//Dealing With Server
extension HomeVC{
    
    func addDataToServer(completion : @escaping (Bool)->()){
        
        self.tempArray.removeAll()
        print("\n\n")
        print("The server Object is here to display")
        print("\n\n")
        
        let DBRef = Database.database().reference()
        print("\n\n")
        print("The saving data is here")
        print(AuthServices.shared.userValue,AuthServices.shared.carId)
         print("\n\n")
        
        if let userID = AuthServices.shared.userValue , let carID = AuthServices.shared.carId{
            
            
            var newDB =   DBRef.child("Routes").child(userID).child(carID)
            if self.currentDBKey.isEmpty{
                newDB = newDB.childByAutoId()
            }else{
                newDB = newDB.child(self.currentDBKey)
            }
            
            let newID = DBRef.child("Routes").child(userID).child(carID).childByAutoId()
            
            print("The New Id Is here :: \(newID)")
            let milage = Int(CarManger.shared.singleCarData.Mileage!)
            
            let fuel = self.distanceValue/Double(milage!)
            
            let values  = ["trip_date:" : Date().timeIntervalSinceNow,"trip_endpoint:":self.destinatioName,"trip_startpoint:":compareArr.first!.lineString!,"trip_totaldistance":"0","trip_totalfuel" : fuel,"trip_totlatime":"9"] as [String : Any]
            print("Here are the values of data ")
            print(values)
            
            newDB.updateChildValues(values) { (error, refrence) in
                
                if error != nil{
                    completion(false)
                    return
                }
                
                for (index , val) in self.serverObj.enumerated(){
                    
                    self.tempArray.append(val.valDict())
                }
                
                print(self.tempArray)
                let arryVal = newDB.child("list")
                // let arrayDict : [[:]] = []
                self.currentDBKey = newDB.key ?? ""
                
                let mapVal = self.serverObj.map({_ in NSArray(array: self.serverObj)})
                print(mapVal)
                arryVal.setValue(self.tempArray)
                completion(true)
            }
            
        }else{
            
            print("\n\n CarId and UserId at the HOME \n\n\n")
        }
  
    }

    
}


//Open Google Maps From APP
extension HomeVC{
    
    @objc func openGoogleMaps(){
        let newLat  =  self.locArray.first!.lat!
        let newLang  = self.locArray.first!.long!
        print(newLat,newLang)
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(newLat),\(newLang)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}


//Others
extension GMSMapView{
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.center
        let centerCoordinate = self.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.convert(CGPoint(x: self.frame.size.width, y: 0), from: self)
        let point = self.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
}



//        self.selectedCoordinate = CLLocation(latitude: arr[0].lat!, longitude:  arr[0].long!)
  //        self.currentCoordinate = CLLocation(latitude: self.currentCoordinateValue.latitude, longitude:  self.currentCoordinateValue.longitude)
  //
  //        print("The Selected Coordinates", self.selectedCoordinate,self.currentCoordinate)
  
  
  //   let distanceInMeters : CLLocationDistance = self.currentCoordinate.distance(from: selectedCoordinate)
  //    print("The Coordinates after changing ", distanceInMeters)
  
  //        if  CGFloat(distanceInMeters) <= 100{
  //
  //            Alert.showLoginAlert(Message: "You have reached your destination", title: "", window: self)
  //        }else{
  //
  //            Alert.showLoginAlert(Message: "you are ub able to reach it", title: "", window: self)
  //        }

    //Extras
//    @IBAction func getCurrentPlace(_ sender: UIButton) {
//
//        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//            if let error = error {
//                print("Current Place error: \(error.localizedDescription)")
//                return
//            }
//
//
//
//            if let placeLikelihoodList = placeLikelihoodList {
//                let place = placeLikelihoodList.likelihoods.first?.place
//                if let place = place {
//                    //  self.nameLabel.text = place.name
//                    // self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
//
//                }
//            }
//        })
//    }



extension HomeVC : GADBannerViewDelegate{
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width - 20, height: 30))

      //  var bannerView: GADBannerView! = GADBannerView(adSize: adSize)
        //addBannerViewToView(bannerView)
        
        gadView.adUnitID = "ca-app-pub-5725707446720007/1443645625"
        gadView.rootViewController = self
        gadView.delegate = self
    
        gadView.load(GADRequest())

          
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
        view.bringSubviewToFront(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    
}



extension HomeVC{
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
    
}


