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


class HomeVC: UIViewController {
    
    @IBOutlet weak var gMapView: UIView!
    @IBOutlet weak var cancelTripBtnOutlet: UIButton!
    @IBOutlet weak var googleAdBanner: GADBannerView!
    @IBOutlet weak var okBtnOutlet: UIButton!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    @IBOutlet weak var endRouteBtnOutlet: UIButton!
    @IBOutlet weak var dropPointOutlet: UIButton!
    @IBOutlet weak var rideSelectOutlet: UIButton!
    @IBOutlet weak var currentLocOutlet: UIButton!
    @IBOutlet weak var searchBtnOutlet: UIButton!
    @IBOutlet weak var googleMapOutlet: UIButton!

    
    private lazy var mapVC: MapExtensionVC = {
        var viewController = MapExtensionVC.instantiateViewController()
        self.add(asChildViewController: viewController, to: gMapView)
        return viewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRoundness()
        self.setUpAddBanner()
        self.initalHideButtons()
        self.setActionOnPlacePicker()
        self.setCurrentLocationAction()
        
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
        
    }
    
}


extension HomeVC : StoryboardInitializable{
    
    public static var storyboardName: UIStoryboard.Storyboard{
        return .main
    }
}



extension HomeVC{
    
    func setRoundness(){
        
        cancelTripBtnOutlet.getRoundedcorner(cornerRadius: self.cancelBtnOutlet.roundHeight())
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addBanner()
        }
    }
    
    func addBanner(){
        
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width - 20, height: 30))
        googleAdBanner.adUnitID = "ca-app-pub-5725707446720007/1443645625"
        googleAdBanner.rootViewController = self
        googleAdBanner.delegate = self
        googleAdBanner.load(GADRequest())
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


extension HomeVC : GMSAutocompleteViewControllerDelegate{
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
         viewController.dismiss(animated: true, completion: nil)
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
        present(autocompleteController, animated: true, completion: nil)
        
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
