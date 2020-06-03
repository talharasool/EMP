//
//  CarUpdateViewController.swift
//  EconomicMovementPlanner
//
//  Created by talha on 08/11/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//



import UIKit
import KYDrawerController
import FirebaseDatabase
import FirebaseStorage
import GoogleMobileAds

class CarUpdateViewController: UIViewController {
    
    @IBOutlet weak var updateProfileAction: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var uploadImageBtnOutlet: UIButton!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userPssword: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    
    @IBOutlet weak var addcaroutlet: UILabel!
    let activity = UIActivityIndicatorView()
    
    var selectedImage : UIImage! = nil
    
    var vcIdentifier : String = ""
    
    var usernametext : String = ""
    var passwordtext : String = ""
    var phonetext : String = ""
    
    
    var currentCar : CarModel?
    
    var imagePickerController : ImagePickerUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController = ImagePickerUtils(delegate: self, pickerViewController: self)
        updateProfileAction.addTarget(self, action: #selector(updateUserprofile(sender:)), for: .touchUpInside)
        self.addBanner()
        self.title = "Update Car"
        self.updateProfileAction.setTitle("Update", for: .normal)
        
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        
        self.view.setBackground(imageName: "background")
        setUpImageViewTap()
        setUpMenuButton()
        
        if let car = self.currentCar{
            
            self.username.text = car.Name
            self.userPhoneNumber.text = car.Model
            self.userPssword.text = String(describing: car.Mileage)
            if let imageURL = URL(string: car.Image_Link!){
                self.userImageView.sd_setImage(with: imageURL, completed: nil)
                self.selectedImage = self.userImageView.image!
            }else{
                print("\n\n\n Image url is nil \n\n")
            }
        }
        
        self.updateProfileAction.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.AddCar.rawValue, comment: ""), for: .normal)
             
             self.username.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Make.rawValue, comment: "")
             self.userPssword.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Mileage.rawValue, comment: "")
             self.userPhoneNumber.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Model.rawValue, comment: "")
             
             self.addcaroutlet.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.AddCar.rawValue, comment: "")
             
             self.uploadImageBtnOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.UploadImage.rawValue, comment: ""), for: .normal)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.uploadImageBtnOutlet.layer.cornerRadius = 10
        self.updateProfileAction.layer.cornerRadius = self.updateProfileAction.frame.height/2
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension CarUpdateViewController {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
    
}

extension CarUpdateViewController : StoryboardInitializable, ImagePickerUtilsDelegate{
    
    
    func didFinishPickingImage(selectedImage: UIImage) {
        
        print("The selected image is here", selectedImage)
        
        self.selectedImage  = selectedImage
        self.userImageView.image = selectedImage
        
    }
    
    func didTapOnCancel() {
        
    }
    
    func cameraNotAvailable() {
        "Print Sorry Camera not avialable"
    }
}


extension CarUpdateViewController {
    
    @objc func updateUserprofile(sender : UIButton){
   
        usernametext = username.text!; passwordtext = userPssword.text!;phonetext = userPhoneNumber.text!
        
        if (usernametext.isEmpty || passwordtext.isEmpty || phonetext.isEmpty){
            Alert.showLoginAlert(Message: "", title: "Please fill all the fields", window: self)
        }else{
            if selectedImage == nil {
                Alert.showLoginAlert(Message: "", title: "Please upload the image", window: self)
                
            }else {
                     self.startAnimating()
                let storageRef = Storage.storage().reference().child("myImage").child(AuthServices.shared.userValue!).child("image.jpg")
                
                if  let imageData  = selectedImage.jpegData(compressionQuality: 0.5){
                    print("Good walls")
                    storageRef.putData(imageData, metadata: nil) { (metaData, err) in
                        if err != nil{
                            self.stopAnimating()
                             Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                            print("error is here")
                            return
                        }
                      
                        
                       print(metaData)
                        
                        
                        guard let newImage = metaData else {return}
                        
                        storageRef.downloadURL(completion: { (url, err) in
                            print(url)
                            
                            
                            let DBRef = Database.database().reference()
                            
                            if let userId = AuthServices.shared.userValue, let car = self.currentCar{
                                
                                let newDB =   DBRef.child("Car Details").child(userId).child(car.Car_Id)
                                print("The db is \(newDB.key)")
                                
                               
                                
                                newDB.updateChildValues(["Image_Link" : String(describing: url!),"Mileage" : self.passwordtext, "Model" :  self.phonetext , "Name" :    self.usernametext ], withCompletionBlock: { (error, dbre) in
                                    
                                    if err != nil{
                                        self.stopAnimating()
                                        Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                                        print("err",err)
                                        return
                                    }
                                    
                                    self.stopAnimating()
                                    
                        
                                    
                                    let alert = UIAlertController(title: "Car Updated", message: "", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {(alert) in
                                        
                                        self.dismiss(animated: true, completion: nil)
                                    }))
                                    self.present(alert,animated: true)
                                    
                                  //  print(dbre.childByAutoId())
                                })
                                
                            }else{
                                
                                print("\n\n Unable to get update profile \n")
                            }
                            
                            
                            
                            // newDB.updateChildValues(["Car_Id" : new])
                            
                        })
                    }
                }else{
                    
                    print("Storage")
                }
                
             
                
                
               // Alert.showLoginAlert(Message: "", title: "Car added successfully", window: self)
                
            }
            
        }
        
        
        
    }
    
}

extension CarUpdateViewController {
    
    
    
    func setUpImageViewTap(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openCameraController))
        userImageView.isUserInteractionEnabled = true;
        //userImageView.addGestureRecognizer(tap)
        uploadImageBtnOutlet.addTarget(self, action: #selector(openCameraController(sender:)), for: .touchUpInside)
    }
    
    
    @objc func openCameraController(sender : UIButton){
        
        let alert = UIAlertController(title: "Please select image", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: " Select image from gallery", style: .default, handler: { (action) in
            
            self.imagePickerController.photoFromGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Capture image from camera", style: .default, handler: { (action2) in
            
            self.imagePickerController.photoFromCamera()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.isPad{
            
            alert.popoverPresentationController?.sourceRect = sender.frame
            alert.popoverPresentationController?.sourceView = self.view
        }
        self.present(alert,animated: true,completion: nil)
        
    }
}




extension CarUpdateViewController {
    
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
        self.view.addSubview(activity)
        
    }
    
    func stopAnimating(){
        
        UIApplication.shared.endIgnoringInteractionEvents()
        activity.stopAnimating()
    }
}




extension CarUpdateViewController : GADBannerViewDelegate{
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: 300, height: 50))

        var bannerView: GADBannerView! = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
        
        //bannerView.adUnitID = "ca-app-pub-5725707446720007/1443645625"
         bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
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



extension CarUpdateViewController{
    
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
