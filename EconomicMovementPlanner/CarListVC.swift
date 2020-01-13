//
//  CarListVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 31/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import Firebase
import CodableFirebase
import GoogleMobileAds

class CarListVC: UIViewController {
    
    @IBOutlet weak var addCarAction: UIButton!
    typealias secondResponse = [String : [String : Any]]
    typealias firstResponse = [String : secondResponse]
    
    var carArray : [CarModel] = []
    let activity = UIActivityIndicatorView()

    @IBOutlet weak var carTV: UITableView! {
        
        didSet{
            carTV.delegate = self
            carTV.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Cars"
        let nib = UINib(nibName: "CarsTVCell", bundle: nil)
        carTV.register(nib, forCellReuseIdentifier: Keys.CellIds().carCell)
        carTV.tableFooterView = UIView(frame: .zero)
        
        self.addBanner()
        self.addCarAction.addTarget(self, action: #selector(openCarAddVC(sender:)), for: .touchUpInside)
        
        self.navigationController?.setUpBarColor()
       self.navigationController?.setUpTitleColor()
        setUpMenuButton()
        self.startAnimating()
        

        FIRService.shared.getDataFromDataBase("Car Details") { (response) in
            self.stopAnimating()
           print(response)
            
            
            if let data =  response as? [CarModel]{
                
                self.carArray = data
            }else{
                
                
            }

            
            
            DispatchQueue.main.async {
                self.carTV.reloadData()
            }
            print("The count of cars are \(self.carArray.count)")
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.addCarAction.layer.cornerRadius = self.addCarAction.frame.width/2
    }

    @objc func openCarAddVC(sender : UIButton){
        
        let vc = CarMenuVC.instantiateViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CarListVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
}



extension CarListVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.carArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIds().carCell, for: indexPath) as? CarsTVCell{
            
            print(carArray[indexPath.item].Mileage)
              print(carArray[indexPath.item].Image_Link)
            cell.carObject = carArray[indexPath.item]
            
            if let carId =  AuthServices.shared.carId{
                
                if carId == carArray[indexPath.item].Car_Id{
                    cell.starImageView.image = #imageLiteral(resourceName: "groupColor")
                    
                }else{
                      cell.starImageView.image = #imageLiteral(resourceName: "group")
                }
            }
            
            
            cell.editCompletion = { [weak self]  in
                
                let vc = CarUpdateViewController.instantiateViewController()
                vc.currentCar = self?.carArray[indexPath.row]
                vc.modalPresentationStyle = .overFullScreen
                self!.present(vc,animated: true)
            }
            
            
            cell.deleteCompletion = { [weak self] in
                
                let alert = UIAlertController(title: "Are you sure you want to delete car", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                    
                    if let id  = AuthServices.shared.userValue{
                        
                        if let carID = self?.carArray[indexPath.row].Car_Id{
                               let val =  Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child("Car Details").child(id).child(carID)
                            
                            val.removeValue { (err, ref) in
                                
                                if err !=  nil{
                                    return
                                }
                                
                                  NotificationCenter.default.post(name: car_Notify_Key, object: nil)
                                
                               // self?.carArray.remove(at: indexPath.row)
                                
                                self?.carTV.reloadData()
                                
                                cell.hideView(0)
                            }
                        }
                     
                        
                    }
                   
                    
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert) in
                    
                }))
                
                self!.present(alert,animated: true,completion: nil)
                
            }
            
        
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 146
    }
}


extension CarListVC :StoryboardInitializable {}


extension CarListVC {
    
    // let activity = UIActivityIndicatorView()
    func startAnimating(){
        
        //   UIApplication.shared.beginIgnoringInteractionEvents()
        let width  = self.view.frame.width/2
        let height = self.view.frame.height/2
        activity.style = .whiteLarge
        activity.color = UIColor.black
        activity.backgroundColor = UIColor.clear
        activity.frame = CGRect(x: width , y: height, width: 80, height: 70)
        let label  = UILabel()
        activity.layer.cornerRadius = 4
        activity.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        label.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 80, height: 20)
        // label.text =  "Please Wait"
        activity.addSubview(label)
        activity.startAnimating()
        self.navigationController!.view.addSubview(activity)
        
    }
    
    func stopAnimating(){
        
        UIApplication.shared.endIgnoringInteractionEvents()
        activity.stopAnimating()
    }
}





extension CarListVC : GADBannerViewDelegate{
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: 300, height: 50))

        var bannerView: GADBannerView! = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-5725707446720007/1443645625"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())

          
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



extension CarListVC{
    
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
