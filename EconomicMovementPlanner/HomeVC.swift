//
//  HomeVC.swift
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
import GoogleMobileAds



struct TaylorFan {
    fileprivate var name: String
}


class HomeVC: UIViewController {
    
    @IBOutlet weak var dataMainLabel: UILabel!
    @IBOutlet weak var gMapView: UIView!
    @IBOutlet weak var googleAdBanner: GADBannerView!
    
    @IBOutlet weak var okBtnOutlet: UIButton!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var endRouteBtnOutlet: UIButton!
    @IBOutlet weak var dropPointOutlet: UIButton!
    @IBOutlet weak var rideSelectOutlet: UIButton!
    @IBOutlet weak var currentLocOutlet: UIButton!
    @IBOutlet weak var searchBtnOutlet: UIButton!
    @IBOutlet weak var googleMapOutlet: UIButton!
    @IBOutlet weak var cancelTripBtnOutlet: UIButton!
    
    let label  = UILabel()
    
    var activityText = "Please wait making route for you"
    private lazy var mapVC: MapExtensionVC = {
        var viewController = MapExtensionVC.instantiateViewController()
        self.add(asChildViewController: viewController, to: gMapView)
        return viewController }()
    
    private lazy var activity = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
   self.okBtnOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.OK.rawValue, comment: ""), for: .normal)
        self.cancelBtnOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Cancel.rawValue, comment: ""), for: .normal)
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Home.rawValue, comment: "")
        self.endRouteBtnOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.EndRoute.rawValue, comment: ""), for: .normal)
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        
        self.cancelTripBtnOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.CANCELTRIP.rawValue, comment: ""), for: .normal)
        
        self.setRoundness()
        self.setUpAddBanner()
        self.initalHideButtons()
        self.setActionOnPlacePicker()
        self.setCurrentLocationAction()
        self.setActionOndropPointOutlet()
        self.setActionOnCancelButton()
        self.setActionOkOutlet()
        self.setActionOnListButton()
        self.setEndRouteAction()
        self.setActionOnCancelTripButton()
        self.setGoogleRouteAction()
        self.setCompletionOfDistanceReaching()
        print("The car id",AuthServices.shared.carId)
        
        if let id = AuthServices.shared.carId{
            
            if id.isEmpty{
               // self.showTemporaryAlert("Oops", "There id ni car for the trip please add the car")
              Alert.showLoginAlert(Message:  "There id no car for the trip please add the car", title: "Oops", window: self)
            }
        }else{
               Alert.showLoginAlert(Message:  "There id no car for the trip please add the car", title: "Oops", window: self)
            // self.showTemporaryAlert("Oops", "There id ni car for the trip please add the car")
        }
        
        var fan = TaylorFan(name: "Kailee")
        fan.name = "Simon"
        print(fan.name)
        self.showDistance()
        
        self.mapVC.resetOutletCompletion = {[unowned self] (isSingle) in
            
            if isSingle{
                
                self.endRouteBtnOutlet.isHidden =  true
                self.dropPointOutlet.isHidden = false
                self.cancelBtnOutlet.isHidden = true
                self.searchBtnOutlet.isHidden = false
                self.googleMapOutlet.isHidden = true
                self.cancelTripBtnOutlet.isHidden = true
                self.cancelBtnOutlet.backgroundColor = UIColor.gray
                
            }else{
                
                self.endRouteBtnOutlet.isHidden = true
                self.cancelTripBtnOutlet.isHidden = false
                self.cancelBtnOutlet.isHidden = false
                
                if self.mapVC.getCountOfLocArray() == 0{
                    self.mapVC.googleMapView.clear()
                }
            }
            
            
        }
        
        self.mapVC.mapCancelCompletion = {
            [unowned self] in
            self.rideSelectOutlet.isHidden = true
        }
        
        self.setUpActionForUserLocationTracking()
        
        
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        
        if LocalizationSystem.sharedInstance.getLanguage() == "en"{
            drawer.drawerDirection = .left
        }else{
            drawer.drawerDirection = .right
        }
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
    
}

extension HomeVC : StoryboardInitializable{
    public static var storyboardName: UIStoryboard.Storyboard{ return .main }
}

extension HomeVC{
    
    func setRoundness(){
        cancelTripBtnOutlet.getRoundedcorner(cornerRadius: self.cancelTripBtnOutlet.roundHeight())
        cancelBtnOutlet.getRoundedcorner(cornerRadius: self.cancelBtnOutlet.roundHeight())
        endRouteBtnOutlet.getRoundedcorner(cornerRadius: self.endRouteBtnOutlet.roundHeight())
        okBtnOutlet.getRoundedcorner(cornerRadius: self.okBtnOutlet.roundHeight())
        dropPointOutlet.getRoundedcorner(cornerRadius: self.dropPointOutlet.roundHeight())
        rideSelectOutlet.getRoundedcorner(cornerRadius: self.rideSelectOutlet.roundHeight())
        currentLocOutlet.getRoundedcorner(cornerRadius: self.currentLocOutlet.roundHeight())
        searchBtnOutlet.getRoundedcorner(cornerRadius: self.searchBtnOutlet.roundHeight())
        googleMapOutlet.getRoundedcorner(cornerRadius: self.googleMapOutlet.roundHeight())
    }
}


extension HomeVC {
    
    func setUpActionForUserLocationTracking(){
        
        self.mapVC.mapRouteCompletion = {[unowned self] in
            self.activityText = ""
            self.activityText = "Please wait making route for you"
            self.startAnimating()
            let source  = CLLocationCoordinate2D(latitude: self.mapVC.currentCoordinates.lat, longitude:  self.mapVC.currentCoordinates.lang)
            
            guard  let dest = self.mapVC.userLocationArray.first else {
                self.stopAnimating()
                return
            }
            
            let destCoordinates = CLLocationCoordinate2D(latitude: dest?.lat ?? 0.0, longitude: dest?.long ?? 0.0)
            print("The dest is here",dest?.lat , dest?.long,destCoordinates,source)
            self.mapVC.drawPolygonForLocation(src: source, dst: destCoordinates, completion: {
                self.stopAnimating()
                self.mapVC.startTimer()
                self.cancelBtnOutlet.backgroundColor = UIColor.red
                self.cancelBtnOutlet.isHidden = false
                self.searchBtnOutlet.isHidden = false
                self.dropPointOutlet.isHidden = false
                self.rideSelectOutlet.isHidden = true
                self.googleMapOutlet.isHidden = false
                
                if self.mapVC.getCountOfLocArray() == 1{
                    self.cancelTripBtnOutlet.isHidden = false
                }else{
                     self.cancelTripBtnOutlet.isHidden = false
                }
            }) { (err) in
                self.stopAnimating()
                Alert.showLoginAlert(Message: "Sorry Unable to find out your route", title: "Route error", window: self)
            }
        }
    }
}

extension HomeVC {
    
    
    private  func initalHideButtons(){
        self.cancelTripBtnOutlet.isHidden = true
        self.googleMapOutlet.isHidden = true
        self.rideSelectOutlet.isHidden = true
        self.cancelBtnOutlet.isHidden = true
        self.endRouteBtnOutlet.isHidden = true
        self.okBtnOutlet.isHidden = true
        
    }
}

extension HomeVC : GADBannerViewDelegate{
    
    func setUpAddBanner(){
        self.addBanner()
    }
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width - 20, height: 30))
       googleAdBanner.adUnitID = "ca-app-pub-5725707446720007/1443645625"
       // googleAdBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        googleAdBanner.rootViewController = self
        googleAdBanner.delegate = self
        let rq = GADRequest()
        googleAdBanner.load(rq)
    }
}


extension HomeVC{
    
    func setCompletionOfDistanceReaching(){
        
        self.mapVC.distanceRemainCompletion = { [unowned self] in
            self.endRouteBtnOutlet.isHidden = false
            self.cancelBtnOutlet.isHidden = true
            self.mapVC.actionOnReachingToOneEndPoint()
            self.showTemporaryAlert()
        }
    }
    
    
    func showTemporaryAlert(_ title : String = "Destination Arrived" , _ msg : String = "You have reached at your destination."){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        self.present(alert,animated: true,completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
        
    }
    func setEndRouteAction(){
        self.endRouteBtnOutlet.addTarget(self, action: #selector(actionOnEndRoute(_:)), for: .touchUpInside)
    }
    
    func setGoogleRouteAction(){
        self.googleMapOutlet.addTarget(self, action: #selector(actionOnGoogleRoute(_:)), for: .touchUpInside)
    }
    
    @objc func actionOnGoogleRoute(_ sender : UIButton){
        
        self.mapVC.openGoogleMaps()
    }
    
    @objc func actionOnEndRoute(_ sender : UIButton){
        print("End route")
        self.activityText = ""
        self.activityText = "Please Wait\n updating trip data."
        self.startAnimating()
        
        self.mapVC.updateDataBase { (isAdded, msg) in
            self.stopAnimating()
            if isAdded{
                if self.mapVC.getCountOfLocArray() == 1{
                    self.googleMapOutlet.isHidden = true
                }
                print("\n\n Every thing added succesfully")
                // self.showTemporaryAlert()
            }else{
                self.showTemporaryAlert("Something went wrong", msg ?? "")
            }
        }
    }
}

extension HomeVC {
    
    
    func setCurrentLocationAction(){
        
        self.currentLocOutlet.addTarget(self, action: #selector(currentLocationAction(sender:)), for: .touchUpInside)
        
    }
    
    @objc func currentLocationAction(sender : UIButton){
        
        self.mapVC.callCurrentLocation()
    }
    
}

//Hide And show Button
extension HomeVC{
    
    func hideandShowButtonsSelectingLocation(){
        self.dropPointOutlet.isHidden = true
        self.rideSelectOutlet.isHidden = true
        self.okBtnOutlet.isHidden = false
        self.cancelBtnOutlet.isHidden = false
    }
}

//Set action On buttons
extension HomeVC {
    
    func setActionOnCancelButton(){
        self.cancelBtnOutlet.addTarget(self, action: #selector(actionOnCancelButton(sender:)), for: .touchUpInside)
    }
    
    func setActionOndropPointOutlet(){
        self.dropPointOutlet.addTarget(self, action: #selector(actionOndropPointOutlet(sender:)), for: .touchUpInside)
    }
    
    func setActionOkOutlet(){
        self.okBtnOutlet.addTarget(self, action: #selector(actionOnOkButton(sender:)), for: .touchUpInside)
    }
    
    func setActionOnListButton(){
        self.rideSelectOutlet.addTarget(self, action: #selector(openRiderSelectionVC(sender:)), for: .touchUpInside)
    }

    func setActionOnCancelTripButton(){
        self.cancelTripBtnOutlet.addTarget(self, action: #selector(actionOnCancelTrip(sender:)), for: .touchUpInside)
    }

    @objc func actionOndropPointOutlet(sender : UIButton){
        
        self.cancelBtnOutlet.isHidden = false
        self.okBtnOutlet.isHidden = false
        self.mapVC.isPinDropEnable = true
        
        self.mapVC.setMarkerOnCoordinates()
    }
    
    @objc func actionOnCancelTrip(sender : UIButton){
        
        self.startAnimating()
        self.mapVC.updateDataBase { (isAdded, msg) in
            self.stopAnimating()
            if isAdded{
                print("\n\n Every thing added succesfully")
                // self.showTemporaryAlert()
            }else{
                self.showTemporaryAlert("Something went wrong\n \( msg ?? "")")
            }
        }
        
    }
    
    @objc func actionOnCancelButton(sender : UIButton){
        
        if cancelBtnOutlet.backgroundColor == UIColor.red{
            
            self.dropPointOutlet.isHidden = false
            self.searchBtnOutlet.isHidden = false
            self.rideSelectOutlet.isHidden = true
            self.cancelBtnOutlet.isHidden = true
            self.googleMapOutlet.isHidden = true
            self.cancelTripBtnOutlet.isHidden = true
            self.mapVC.getUserCurrentPlaceName()
            self.mapVC.actionOnCancelButtonPress()
            self.mapVC.polyline.map = nil
            self.cancelBtnOutlet.backgroundColor = UIColor.gray
            
        }else{
            
            self.cancelBtnOutlet.isHidden = true
            self.okBtnOutlet.isHidden = true
            self.dropPointOutlet.isHidden = false
            self.mapVC.isPinDropEnable = false
            self.mapVC.getUserCurrentPlaceName()
            if self.mapVC.getCountOfLocArray() == 0{}
            self.mapVC.googleMapView.clear()
            self.mapVC.actionOnCancelButtonPress()
            
            
        }
        
    }
    
    @objc func actionOnOkButton(sender : UIButton){
        
        self.cancelBtnOutlet.isHidden = true
        self.dropPointOutlet.isHidden = false
        self.rideSelectOutlet.isHidden = false
        self.okBtnOutlet.isHidden = true
        self.mapVC.isPinDropEnable = false
        
        if self.mapVC.draggingCoordinate !=  nil{
            self.mapVC.placeTempMarkerAtCoordinate(geoCoordinates: self.mapVC.draggingCoordinate)
            
        }else{print("Dragging coordinates are nil here")

        }
        
        if self.mapVC.searchCoordinate != nil{
            self.mapVC.placeTempMarkerAtCoordinate(geoCoordinates: self.mapVC.searchCoordinate)
        }
        
        if (self.mapVC.draggingCoordinate == nil && self.mapVC.searchCoordinate ==  nil && self.mapVC.getCountOfLocArray() == 0){
            self.rideSelectOutlet.isHidden = true
            self.mapVC.googleMapView.clear()
        }else  if (self.mapVC.draggingCoordinate == nil && self.mapVC.searchCoordinate ==  nil && (self.mapVC.getCountOfLocArray()! > 0)){
            self.mapVC.dragMarker.map = nil
        }
        
        self.mapVC.resetPointers()
        
        
    }
    
    @objc func openRiderSelectionVC(sender : UIButton){
        self.mapVC.openListVC()
    }
    
}

//PlacePicker action and delegate
extension HomeVC : GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        viewController.dismiss(animated: true, completion: {
            self.hideandShowButtonsSelectingLocation()
            
            print("\n Ye to kisi place pe nhi likha",place.name,place.coordinate)
            let address  = place.addressComponents?.first?.name ?? ""
            print("\n Ye to kisi place pe nhi likha",place.name,place.coordinate,address)
            self.mapVC.placeName = place.name ?? ""
            self.mapVC.searchCoordinate = place.coordinate
            
            self.mapVC.setMarkerFromSearchLocation(locCoordinate: place.coordinate)
            
        })
        
        print("\nPlace Coordinatee:\(place.coordinate.latitude),\(place.coordinate.longitude)")
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("\n\n\(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("\n\nCancelled")
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func setActionOnPlacePicker(){
        self.searchBtnOutlet.addTarget(self, action: #selector(openPlacePicker(_:)), for: .touchUpInside)
    }
    
    @objc func openPlacePicker(_ sender : UIButton){
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.modalPresentationStyle = .popover
        self.present(autocompleteController, animated: true, completion: {self.mapVC.callCurrentLocation()})
        
    }
    
    
    func showDistance(){
        self.mapVC.dummyCompletion = { [unowned self](val) in
            self.dataMainLabel.text = "Hence covered distance is here \(val)"
        }
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



extension HomeVC {
    
    func startAnimating(){
        
        //   UIApplication.shared.beginIgnoringInteractionEvents()
        let width  = self.view.frame.width/2
        let height = self.view.frame.height/2
        activity.style = .whiteLarge
        activity.color = UIColor.black
        activity.backgroundColor = UIColor.white
        activity.frame = CGRect(x: width , y: height, width: 100, height: 100)
        
        activity.layer.cornerRadius = 4
        activity.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        label.center = CGPoint(x:activity.frame.width/2, y: activity.frame.height/2 + 30)
        
        
        label.text =  self.activityText
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

