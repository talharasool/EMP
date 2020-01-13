

import UIKit
import KYDrawerController
import FirebaseDatabase
import FirebaseStorage
import GoogleMobileAds

class CarMenuVC: UIViewController {
    
    @IBOutlet weak var updateProfileAction: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var uploadImageBtnOutlet: UIButton!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userPssword: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    
     let activity = UIActivityIndicatorView()
    
    var selectedImage : UIImage! = nil
    
    var vcIdentifier : String = ""
    
    var usernametext : String = ""
    var passwordtext : String = ""
    var phonetext : String = ""
    
    var imagePickerController : ImagePickerUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController = ImagePickerUtils(delegate: self, pickerViewController: self)
        updateProfileAction.addTarget(self, action: #selector(updateUserprofile(sender:)), for: .touchUpInside)
        
        self.title = "Add Car"
        self.addBanner()
        
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        
        self.view.setBackground(imageName: "background")
        setUpImageViewTap()
        setUpMenuButton()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.uploadImageBtnOutlet.layer.cornerRadius = 10
        self.updateProfileAction.layer.cornerRadius = self.updateProfileAction.frame.height/2
    }
    
}


extension CarMenuVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
    
}

extension CarMenuVC : StoryboardInitializable, ImagePickerUtilsDelegate{
    
    
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


extension CarMenuVC {
    
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
                            
                            if let userId = AuthServices.shared.userValue{
                                
                                let newDB =   DBRef.child("Car Details").child(userId).childByAutoId()
                                print("The db is \(newDB.key)")
                                
                                
                                newDB.updateChildValues(["Car_Id" : newDB.key!, "Image_Link" : String(describing: url!),"Mileage" : self.passwordtext, "Model" :  self.phonetext , "Name" :    self.usernametext ], withCompletionBlock: { (error, dbre) in
                                    
                                    if err != nil{
                                        self.stopAnimating()
                                        Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                                        print("err",err)
                                        return
                                    }
                                    
                                    self.stopAnimating()
                                    
                                    Alert.showLoginAlert(Message: "", title: "Car Added", window: self)
                                    
                                    print(dbre.childByAutoId())
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

extension CarMenuVC {
    
    
    
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
        if UIDevice.isPad{
            
            alert.popoverPresentationController?.sourceRect = sender.frame
            alert.popoverPresentationController?.sourceView = self.view
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true,completion: nil)
        
    }
}




extension CarMenuVC {
    
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



extension CarMenuVC : GADBannerViewDelegate{
    
    func addBanner(){
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width - 20, height: 50))

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



extension CarMenuVC{
    
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
