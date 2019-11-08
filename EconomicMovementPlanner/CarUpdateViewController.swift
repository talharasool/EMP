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


class CarUpdateViewController: UIViewController {
    
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
    
    
    var currentCar : CarModel?
    
    var imagePickerController : ImagePickerUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController = ImagePickerUtils(delegate: self, pickerViewController: self)
        updateProfileAction.addTarget(self, action: #selector(updateUserprofile(sender:)), for: .touchUpInside)
        
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
        uploadImageBtnOutlet.addTarget(self, action: #selector(openCameraController), for: .touchUpInside)
    }
    
    
    @objc func openCameraController(){
        
        let alert = UIAlertController(title: "Please select image", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: " Select image from gallery", style: .default, handler: { (action) in
            
            self.imagePickerController.photoFromGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Capture image from camera", style: .default, handler: { (action2) in
            
            self.imagePickerController.photoFromCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
