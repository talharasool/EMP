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
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    var placeMarker  = GMSMarker()
    var dragMarker  = GMSMarker()
    var searchMarker  = GMSMarker()
    let geoCoder = GMSGeocoder()
    var locationManager : LocManager!
    
    var placesClient: GMSPlacesClient!
    
    var draggingCoordinate : CLLocationCoordinate2D!
    var searchCoordinate : CLLocationCoordinate2D!
    
    var currentCoordinates = (lat : 0.0, lang : 0.0)
    var locationCoordinates = (lat : 0.0, lang : 0.0)
    var userLocationArray : [CoordinatesValue?] = []
    var temporaryArrayForTapLocations : [CoordinatesValue?] = []
    var placeName : String? = ""
    var isPinDropEnable : Bool = false
    var isDraggigMarkerOnMap : Bool = false
    var isTripSrated : Bool  = false
    
    var mapCancelCompletion  : (()->())?
    var mapRouteCompletion  : (()->())?
    var distanceCompletion  : (()->())?
    var distanceRemainCompletion  : (()->())?
    var resetOutletCompletion  : ((Bool)->())?
    var dummyCompletion  : ((String)->())?
    var ismine : Bool = false
    
    var polyline = GMSPolyline()
    
    var timer : Timer?
    var curretDiatance : Double? = 0.0
    var coveredDiatance : Double? = 0.0
    var currentTime : Double? = nil
    var currentDBKey : String = ""
    var userPinLocation : String = ""
    
    var startTime : Double? = nil
    var endTime : Double?  = nil
    
    
    var curretCar : CarModel!
    var tripData : [TripData] = []
    var serverObj : [tripServerData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        googleMapView.delegate = self
        locationManager = LocManager(self)
        locationManager.currentLatLong = { (lat, lang) in
            print("\n\nThe current Lat and Lang",lat,lang)
            self.currentCoordinates = (lat: lat!, lang : lang!)
            let position =  CLLocation(latitude: lat!, longitude: lang!)
            self.getCurrentPositionName(coordinates: position) { (placeName, PlaceAddress) in
                self.userPinLocation = placeName ?? ""
            }
            DispatchQueue.main.async {
                self.callGoogleMap(lat: lat!, long: lang!)
                self.setDragOnMap()
            }
        }
    }
    
}

extension MapExtensionVC{
    
    
    func getCurrentPositionName(coordinates : CLLocation,comp : ((String?, String?)->())?){
        
        var coreLocGeoCoder = CLGeocoder()
        
        coreLocGeoCoder.reverseGeocodeLocation(coordinates) { (places, err) in
            if err != nil{return}
            guard let placeName  = places?.first else {return}
            print("\n\nThe CLGeocoder are here",placeName.name,placeName,placeName.addressDictionary,placeName.locality,placeName.location)
            if let location = placeName.location , let name = placeName.name{
                let loc = String(describing: location)
                guard  let placeComp = comp else {
                    return
                }
                print("\nThe fetching place and line",name,loc)
                placeComp(name,loc)
            }
        }
    }
    
    
    func getUnixDate()->Double{
        let date = NSDate() // current date
        let unixtime = date.timeIntervalSince1970
        //   self.curretDiatance = unixtime
        print("\n\n The current unix time",unixtime)
        let timeStamp = Date.init(timeIntervalSinceNow: unixtime)
        print("\n\n The New Time Stamp here",timeStamp)
        print("\n\n The ",   getDateFromUNIX(myDate: timeStamp))
        return unixtime
        
    }
}

//Geocoding value
extension MapExtensionVC {
    
    
    
    func getLocationNameFromGeoCode(_ coordinate : CLLocationCoordinate2D, completion  :@escaping ((CoordinatesValue?)->())){
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { (placeValue, err) in
            
            if err != nil {completion(nil);return}
            
            switch placeValue?.results(){
                
            case .some(let val):
                guard let singleAddress = val.first else {print("Unable to fetch place");return}
                print(singleAddress)
                let placeAddress = singleAddress.lines?.first ?? ""
                var placeTitle = self.placeName ?? singleAddress.lines?.first ?? ""
                if placeTitle.isEmpty{
                    placeTitle = singleAddress.locality ?? ""
                }
                
                let tempAddress = CoordinatesValue(lineString: placeAddress, title: placeTitle, startPoint: "", lat: coordinate.latitude, long: coordinate.longitude,isSelect: false, isCompleted: false, timeAndDate: self.getUnixDate())
                
                
                self.placeName = ""
                completion(tempAddress)
                
                break
                
            case .none:
                print("Hello ")
            }
        }
    }
}

extension MapExtensionVC : StoryboardInitializable{
    
    
    func callCurrentLocation(){
        print("Back")
        self.callGoogleMap(lat: self.currentCoordinates.lat, long: self.currentCoordinates.lang)
    }
    
    func callGoogleMap(lat : Double, long : Double,completion : (()->())? = nil){
        print("ThE GoOglE MaP CoOrDiNate",lat,long)
        let camera = GMSCameraPosition.camera(withLatitude:lat, longitude: long, zoom: 15)
        // self.googleMapView.animate(toZoom: 40)
        self.googleMapView?.isMyLocationEnabled = true
        self.googleMapView.animate(to: camera)
        if let comp = completion{
            comp()
        }
    }
}


//Function On Place Delegates
extension MapExtensionVC{
    
    func setMarkerFromTapAction(locCoordinate : CLLocationCoordinate2D){
        
        let camera = GMSCameraPosition.camera(withLatitude: locCoordinate.latitude, longitude: locCoordinate.longitude, zoom: 16)
        self.googleMapView.animate(to: camera)
        //   self.callGoogleMap(lat: locCoordinate.latitude, long: locCoordinate.longitude)
        self.getLocationNameFromGeoCode(locCoordinate) { (response) in
            guard let resp = response else{print("\n\n :: Unable to get location name");return}
            _ = #imageLiteral(resourceName: "pins")
            let marker = GMSMarker(position: locCoordinate)
            marker.icon = nil
            marker.map = self.googleMapView
            self.userLocationArray.append(resp)
            //self.placeMarker.icon = UIImage()
            print("\n\nThe count of the located array is here", self.getCountOfLocArray() ?? 0)
        }
    }
    
    func setMarkerFromSearchLocation(locCoordinate : CLLocationCoordinate2D){
        
        print("The location coordinate for placement", locCoordinate.latitude,locCoordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: locCoordinate.latitude, longitude: locCoordinate.longitude, zoom: 16)
        self.googleMapView.animate(to: camera)
        // self.callGoogleMap(lat: locCoordinate.latitude, long: locCoordinate.longitude)
        //   self.draggingCoordinate = locCoordinate
        let image = UIImage(named: "pins")
        //        self.placeMarker = GMSMarker(position: locCoordinate)
        //        self.placeMarker.isDraggable = true
        //        self.placeMarker.icon = image
        //        self.placeMarker.map = self.googleMapView
        
//        let marker = GMSMarker(position: locCoordinate)
//        marker.icon = nil
//        marker.icon = image
//        marker.isDraggable = true
//        marker.userData = "Search"
//        marker.title = "Search"
//        marker.tracksViewChanges = true
//        marker.map = self.googleMapView
        
        self.searchMarker = GMSMarker(position: locCoordinate)
       // self.searchMarker.icon = nil
        self.searchMarker.icon = image
        self.searchMarker.isDraggable = true
        self.searchMarker.userData = "Search"
        self.searchMarker.title = "Search"
      //  self.searchMarker.tracksViewChanges = true
        self.searchMarker.map = self.googleMapView
        
        
    }
    
    
    
    func setMarkerFromLocation(locCoordinate : CLLocationCoordinate2D){
        
        print("The location coordinate for placement", locCoordinate.latitude,locCoordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: locCoordinate.latitude, longitude: locCoordinate.longitude, zoom: 16)
        self.googleMapView.animate(to: camera)
        // self.callGoogleMap(lat: locCoordinate.latitude, long: locCoordinate.longitude)
        //   self.draggingCoordinate = locCoordinate
        let image = UIImage(named: "pins")
        self.dragMarker = GMSMarker(position: locCoordinate)
        self.dragMarker.isDraggable = true
        self.dragMarker.icon = image
        self.dragMarker.title = "Drag"
        self.dragMarker.map = self.googleMapView
        
    }
    
    func addPlaceValueOnOkButton(){}
    
}


extension MapExtensionVC{
    
    func setMarkerOnCoordinates(){
        
        locationManager.updateLocation()
        locationManager.currentLatLong = {  (lat, lang) in
            
            DispatchQueue.main.async {
                self.currentCoordinates = (lat: lat!, lang : lang!)
                let cuurentPosition  = CLLocationCoordinate2D(latitude: lat!, longitude: lang!)
                self.setMarkerFromLocation(locCoordinate: cuurentPosition )
            }
            
        }
    }
}


extension MapExtensionVC {
    
    func addCorrdinateValues(){
        
        if self.isDraggigMarkerOnMap {
            
        }
    }
}
//Map View Delegates
extension MapExtensionVC : GMSMapViewDelegate{
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        
        if isPinDropEnable{
            
            self.setMarkerFromTapAction(locCoordinate: coordinate)
            //   self.setMarkerFromSearchLocation(locCoordinate: coordinate)
        }else{print("Pin drop is not enabled yet")}
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("\nYeh to drag ho ga")
        print(mapView.myLocation?.coordinate)
        self.isDraggigMarkerOnMap = true
        //  print("The name of the coordinate is here",mapView.selectedMarker?.userData,mapView.selectedMarker?.title)
    }
    
    func resetPointers(){
        
        self.isDraggigMarkerOnMap = false
        self.draggingCoordinate = nil
        self.searchCoordinate = nil
        self.searchMarker.map = nil
        self.placeMarker.isDraggable = false
        self.dragMarker.map = nil
        
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        print("End dragging")
        
        //          if self.isDragg{
        //
        //          }else{
        //              print("Dragging is not working")
        //          }
        //
        print("The name of the coordinate is here",marker.title,marker.userData)
        
        if let title  = marker.title{
        
            if title ==  "Drag"{
                if  let coordinate = mapView.myLocation?.coordinate{
                    print(coordinate)
                    self.draggingCoordinate = marker.position
                }
            }else{
               // self.searchCoordinate = nil
                if  let coordinate = mapView.myLocation?.coordinate{
                    print(coordinate)
                    self.searchCoordinate = marker.position
                    
                }
            }
        }
//        if  let coordinate = mapView.myLocation?.coordinate{
//            print(coordinate)
//            self.draggingCoordinate = marker.position
//
//        }
        
        //
        // self.placeMarkerOnMapOnButtonTap(coordinate: marker.position)
        
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("\n Ye to ho ga",mapView.myLocation?.description)
      //  self.draggingCoordinate = marker.position
    }
    
    @objc func placeTempMarkerAtCoordinate(geoCoordinates : CLLocationCoordinate2D){
        
        self.getLocationNameFromGeoCode(geoCoordinates) { (response) in
            guard let resp = response else{print("\n\n :: Unable to get location name");return}
            _ = #imageLiteral(resourceName: "pins")
            let marker = GMSMarker(position: geoCoordinates)
            
            marker.icon = nil
            marker.map = self.googleMapView
            self.placeMarker.icon = UIImage()
            
            self.userLocationArray.append(resp)
            print("\n\nThe count of the located array is here", self.getCountOfLocArray() ?? 0)
        }
    }
    
    
    func getCountOfLocArray()-> Int?{
        return self.userLocationArray.count
    }
    
    func getCountOfTempArray()-> Int?{
        return self.temporaryArrayForTapLocations.count
    }
}



extension MapExtensionVC {
    
    
    func calculateRemainDistance(_ curr : CLLocationCoordinate2D,_  dest : CLLocationCoordinate2D )-> String?{
        
        print("\n\n Distance remaining Calulation Started")
        let coordinate₀ = CLLocation(latitude: curr.latitude, longitude: curr.longitude)
        let coordinate₁ = CLLocation(latitude:dest.latitude , longitude: dest.longitude)
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        self.coveredDiatance = distanceInMeters
        print("The distance is here",distanceInMeters)
        
        if let com = self.dummyCompletion{
            let values = String(describing: self.coveredDiatance ?? 0.0)
            com(values)
        }
        if coveredDiatance! < 60.0{
            print("You have reached your location")
            
            if let comp = self.distanceRemainCompletion{
                comp()
            }else{print("Distance completion is nil here")}
            
            
        }else{
            print("You are going")
        }
        return String(format:"%.3f", distanceInMeters) ?? nil
    }
    
    
    
    func calculateDistance(_ curr : CLLocationCoordinate2D,_  dest : CLLocationCoordinate2D )-> String?{
        
        print("\n\n Distance Calulation Started")
        let coordinate₀ = CLLocation(latitude: curr.latitude, longitude: curr.longitude)
        let coordinate₁ = CLLocation(latitude:dest.latitude , longitude: dest.longitude)
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        self.curretDiatance! += distanceInMeters
        
        if let comp = self.distanceCompletion{
            comp()
        }
        print("The distance is here",distanceInMeters)
        return String(format:"%.3f", distanceInMeters) ?? nil
        
    }
    
    
    func openListVC(){
        
        self.openLocationList(locArray: self.userLocationArray as! [CoordinatesValue])
    }
    
    
    func openLocationList(locArray : [CoordinatesValue]){
        
        let vc = PacesTableXIB()
        
        for (index, item) in locArray.enumerated(){
            let coordinate₀ = CLLocation(latitude: self.currentCoordinates.lat, longitude: self.currentCoordinates.lang)
            let coordinate₁ = CLLocation(latitude: item.lat ?? 0.0, longitude: item.long ?? 0.0)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)
            print("The distance is here")
            self.userLocationArray[index]?.distance = distanceInMeters
            
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.array = self.userLocationArray.sorted(by: {($0?.distance ?? 0.0) < ($1?.distance ?? 0.0) }) as! [CoordinatesValue]
        
        
        vc.compLocArray = { (filerArray) in
            self.userLocationArray = filerArray
            
            print("\n\n:: the new count is here",self.getCountOfLocArray())
            if let goComp = self.mapRouteCompletion{
                self.startTime = self.getUnixDate()
                goComp()
            }else{print("Not found any completion")}
            
        }
        
        vc.cancelAction = { [unowned self] in
            self.googleMapView.clear()
            self.userLocationArray.removeAll()
            self.callCurrentLocation()
            
            guard let comp = self.mapCancelCompletion else {
                return
            }
            comp()
            
        }
        
        self.present(vc,animated:  true,completion: nil)
    }
    
    @objc func openGoogleMaps(){
        if let newLat  = self.userLocationArray.first??.lat
            ,let newLang  = self.userLocationArray.first??.long{
            
            print(newLat,newLang)
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(newLat),\(newLang)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
            
        }
        
    }
}


extension MapExtensionVC {
    
    
    func getUserCurrentPlaceName(){
        locationManager.currentLatLong = { (lat, lang) in
            print("\n\nThe current Lat and Lang",lat,lang)
            self.currentCoordinates = (lat: lat!, lang : lang!)
            let position =  CLLocation(latitude: lat!, longitude: lang!)
            self.getCurrentPositionName(coordinates: position) { (placeName, PlaceAddress) in
                self.userPinLocation = placeName ?? ""
            }
            DispatchQueue.main.async {
                self.callGoogleMap(lat: lat!, long: lang!)
                
            }
        }
    }
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    
    func pauseTimer(){
        
        self.locationManager.stopUpdateLocation()
        guard let time = timer?.invalidate() else {
            print("Timer is not nil")
            return}
        
        print("Calling timer")
        time
    }
    
    
    func actionOnEndRoute(){
        self.pauseTimer()
        self.locationManager.stopUpdateLocation()
        if  let serverObj = self.userLocationArray.first{
            //     let temp = tripServerData(date_record: getTodayString(), distance: String(describing: self.curretDiatance!), endpoint: serverObj., fuel: String(describing: fuel!), startpoint: self.startLocation, time: diffFormatString)
        }
        
    }
    
    
    @objc func updateLocation(){
        
        print("\n\n:: Updating location after 15 minuter ::")
        var tempCoordinate = CLLocationCoordinate2D(latitude: self.currentCoordinates.lat, longitude: self.currentCoordinates.lang)
        
        self.locationManager.updateLocation()
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.locationManager.currentLatLong = { (lat, lang) in
                
                self.currentCoordinates = (lat: lat!, lang : lang!)
                let currCor = CLLocationCoordinate2D(latitude: lat!, longitude: lang!)
                //  self.callGoogleMap(lat: lat!, long: lat!)
                
                print("\n\nThe current Lat and Lang",lat,lang)
                guard let destValue = self.userLocationArray.first else{return}
                let dest = CLLocationCoordinate2D(latitude: destValue?.lat ?? 0.0, longitude: destValue?.long ?? 0.0)
                
                DispatchQueue.main.async {
                    self.ismine = true
                    self.drawPolygonForLocation(src: currCor, dst: dest, completion: nil, err: nil)
                    print("\n\n the temp coordinates",tempCoordinate,currCor)
                    print("\n\n The value after updation of distance",self.calculateDistance(tempCoordinate, currCor))
                    print("\n\n The value after updation of remaoin distance",self.calculateRemainDistance(currCor, dest))
                    
                }
            }
        }
    }
    
    
    func setDragOnMap(){
        print("Adding")
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap))
        self.googleMapView.addGestureRecognizer(mapDragRecognizer)
    }
    
    
    func removeDrag(){
        print("Removign")
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap))
        self.googleMapView.removeGestureRecognizer(mapDragRecognizer)
    }
    
    
    @objc func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            print("Map drag began")
        }
        
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
            print("Map drag ended")
        }
        
    }
}


extension MapExtensionVC{
    
    
    func drawPolygonForLocation(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D,completion : (()->())?,err : ((String)->())?){
        
        
        // self.startAnimating()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let locationUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dst.latitude),\(dst.longitude)&sensor=false&mode=driving&key=\(Keys.AppKeys.googleMapKey)"
        
        guard  let url = URL(string:locationUrl) else{ print("Uel is bad") ;return}
        print(locationUrl)
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    
                    guard let errComp = err  else {
                        return
                    }
                    errComp("Not able to create path")
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
                            
                            
                            DispatchQueue.main.async(execute: {
                                self.isTripSrated = true
                                self.googleMapView.clear()
                                //self.setupNavigationBtn(alpha: 1)
                                let path = GMSPath(fromEncodedPath: polyString)
                                self.polyline.map = nil
                                self.polyline = GMSPolyline(path: path)
                                self.polyline.strokeWidth = 8.0
                                if self.ismine == true{
                                      self.polyline.strokeColor = UIColor.red
                                }else{
                                     self.ismine = false
                                    
                                }
                                  self.polyline.strokeColor = UIColor.init(netHex: 0x1565C0)
                              
                                self.polyline.map = self.googleMapView
                                let placeMarker = GMSMarker(position: dst)
                                placeMarker.icon = nil
                                placeMarker.map = self.googleMapView
                                if let mapComp = completion{
                                    mapComp()
                                }else{
                                    print("\n\n Map completion is nil")
                                }
                                
                            })
                        }
                        
                    } catch {
                        
                        print("parsing error")
                    }
                }
            }
        })
        task.resume()
    }
    
    
}


extension MapExtensionVC {
    
    func actionOnReachingToOneEndPoint(){
        self.pauseTimer()
        // self.coveredDiatance = 0.0
        //  self.curretDiatance = 0.0
        
    }
    
    func actionOnCancelButtonPress(){
        self.pauseTimer()
        self.googleMapView.clear()
        self.userLocationArray.removeAll()
        self.getUserCurrentPlaceName()
        
    }
}



extension MapExtensionVC {
    
    func updateDataBase(comp : @escaping (Bool, String?)->()){
        if let obj = self.userLocationArray.first, let serverObj = obj{
            
            self.addDataToServer(serverObj) { (isAdded, message)  in
                if isAdded{
                    print("We have added this data from server")
                    comp(true, message)
                }else{
                    print("Sorry We are unable to add data")
                    comp(false,message)
                }
            }
            
        }else{
            print("Error in finishing data")
            Alert.showLoginAlert(Message: "Sorry for inconvienece", title: "Something went wrong while adding data", window: self)
        }
        
    }
    
    
    fileprivate func addDataToServer(_ addedObject : CoordinatesValue, completion : @escaping (Bool, String?)->()){
        let DBRef = Database.database().reference()
        var tempArray : [[String : Any]] = []
        
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
            let milage = Int(CarManger.shared.singleCarData.Mileage ?? "0")
            let fuel = self.coveredDiatance!/Double(milage!)
            print("The original milage",milage)
            let eTime  =   getUnixDate() - self.startTime!
            print("\n\n The real time is here",self.startTime!,"   ",eTime)
            let totalTime = self.startTime! + eTime
            print("\n\n:->)The end time is here",totalTime)
            
            //
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .abbreviated
            var formatted = formatter.string(from: eTime) ?? ""
            print(formatted)
            //
            
            
            let listObject = tripServerData(date_record: self.startTime!.getDateStringFromUTC(), distance: String(describing: self.coveredDiatance ?? 0.0), endpoint: addedObject.lineString!, fuel: String(describing: fuel ?? 0.0), startpoint: self.userPinLocation, time: formatted.replacingOccurrences(of: "m", with: ""))
            
            
            formatted = formatted.replacingOccurrences(of: "m", with: "")
            
            self.serverObj.append(listObject)
            let values  = ["trip_date:" : self.startTime!.getDateStringFromUTC(),
                           "trip_endpoint:":addedObject.lineString!,
                           "trip_startpoint:":self.userPinLocation,
                           "trip_totaldistance":String(describing : self.coveredDiatance!),
                           "trip_totalfuel" :String(describing: fuel),
                           "trip_totlatime":String(describing: formatted)] as [String : Any]
            
            
            print("\n\nParameter before saving is here")
            print(values)
            print("The time", eTime.getDateStringFromUTC(), addedObject.timeAndDate!.getDateStringFromUTC())
            
            newDB.updateChildValues(values) { (error, refrence) in
                if error != nil{
                    completion(false, "Error in adding values to DB")
                    return
                }
                
                for (index , val) in self.serverObj.enumerated(){
                    tempArray.append(val.valDict())
                }
                
                
                let listKey = newDB.child("list")
                self.currentDBKey = newDB.key ?? ""
                
                listKey.setValue(tempArray)
                
                
                print("The values in the server object")
                self.getDataTripDataFromFirebase(dbID: self.currentDBKey) { (isShown,  message) in
                    if isShown{
                        completion(true, message)
                    }else{
                        completion(false,message)
                    }
                    
                }
                
                
            }
            
        }else{
            
            Alert.showLoginAlert(Message: "Sorry you cannot proceed without car", title: "Please select car first", window: self)
            print("\n\n CarId and UserId at the HOME \n\n\n")
        }
        
    }
}



//                for (index , val) in self.serverObj.enumerated(){
//
//                    self.tempArray.append(val.valDict())
//                }
//
//                print(self.tempArray)
//                let arryVal = newDB.child("list")
//                // let arrayDict : [[:]] = []
//
//
//                let mapVal = self.serverObj.map({_ in NSArray(array: self.serverObj)})
//                print(mapVal)
//                arryVal.setValue(self.tempArray)
//                completion(true)
