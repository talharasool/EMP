//
//  TripVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 15/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import GoogleMobileAds

class TripVC: UIViewController {
    
    @IBOutlet weak var gadView: GADBannerView!
    
    @IBOutlet weak var tripTV: UITableView!{
        didSet{self.tripTV.dataSource = dataSource}
    }
    
    private let dataSource = TripDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        print("Trip VC CALLING\n\n")
        
        self.title = "My Trips"
        dataSource.registerCells(with: tripTV)
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        setUpMenuButton()
        
        addBanner()
    }
    
}



extension TripVC  : StoryboardInitializable {}



extension TripVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc fileprivate func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
}



extension TripVC : GADBannerViewDelegate{
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width - 20, height: 30))

      //  var bannerView: GADBannerView! = GADBannerView(adSize: adSize)
        //addBannerViewToView(bannerView)
        
        gadView.adUnitID = "ca-app-pub-5725707446720007/1443645625"
        gadView.rootViewController = self
        gadView.delegate = self
    
        gadView.load(GADRequest())

          
    }
    
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
