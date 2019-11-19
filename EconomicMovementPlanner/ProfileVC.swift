//
//  ProfileVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 31/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import Firebase
import SDWebImage

class ProfileVC: UIViewController {

    @IBOutlet weak var updateProfileAction: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var uploadImageBtnOutlet: UIButton!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userPssword: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
   
    var currentLoginUser : Profile!
    
     let activity = UIActivityIndicatorView()
    
    var socialEmail : String = ""
    var socialImage : String = ""
    var selectedImage : UIImage! = nil
    
    var vcIdentifier : String = ""
    
    var usernametext : String = ""
    var passwordtext : String = ""
    var phonetext : String = ""
    
    var authID : String = ""
    
    var imagePickerController : ImagePickerUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController = ImagePickerUtils(delegate: self, pickerViewController: self)
      
        
        
        if vcIdentifier.isEmpty{
              self.title = "Profile Setting"
              updateProfileAction.addTarget(self, action: #selector(updateUserprofile(sender:)), for: .touchUpInside)
        }else {
            
            
              self.title = "Complete Profile"
            print(self.socialEmail)
         
              updateProfileAction.setTitle("Sign Up", for: .normal)
              updateProfileAction.addTarget(self, action: #selector(actionOnRegister(sender:)), for: .touchUpInside)
            if !(self.socialImage.isEmpty){
             
                if let imageURL = URL(string: self.socialImage){
                   // self.userImageView.sd_setImage(with: imageURL, completed: nil)
                    self.userImageView.sd_setImage(with: imageURL) { (image, err, cache, url) in
                        
                        if err != nil {return}
                          self.selectedImage =  image
                    }
                  
                }else{
                    print("\n\n\n Image url is nil \n\n")
                }
                
            }
          
        }
      
        setUpImageViewTap()
        
        if vcIdentifier.isEmpty{
              setUpMenuButton()
        }else{
            self.navigationController?.navigationItem.hidesBackButton = true
        }
    
     self.navigationController?.setUpBarColor()
    self.navigationController?.setUpTitleColor()
       // navigationController?.navigationItem.title = UIColor.green
        
        self.getProfileData()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.uploadImageBtnOutlet.layer.cornerRadius = 10
        self.updateProfileAction.layer.cornerRadius = self.updateProfileAction.frame.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.vcIdentifier.isEmpty == false{
               self.username.text = self.socialEmail
        }
    }
    
    
    func getProfileData(){
        
        self.userPhoneNumber.text = AuthServices.shared.userPhoneNumber
        self.username.text = AuthServices.shared.userObj
        self.userPssword.text = AuthServices.shared.userPassword
        
        if let imageURL = AuthServices.shared.userImage{
            
            if let imageURL = URL(string: imageURL){
                   self.userImageView.sd_setImage(with: imageURL, completed: nil)
            }else{
                print("\n\n\n Image url is nil \n\n")
            }

        }else{
           print("\n\n\n Image string is nil \n\n")
        }
   
        
        
    
    }

}


extension ProfileVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
}


extension ProfileVC : StoryboardInitializable, ImagePickerUtilsDelegate{
    
    
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


extension ProfileVC {
    
    
}

extension ProfileVC {
    
    
    
    func setUpImageViewTap(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openCameraController))
        userImageView.isUserInteractionEnabled = true;
        //userImageView.addGestureRecognizer(tap)
        uploadImageBtnOutlet.addTarget(self, action: #selector(openCameraController), for: .touchUpInside)
    }
    
    
    @objc func openCameraController(){
        
        let alert = UIAlertController(title: "Please select image", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Please select image from gallery", style: .default, handler: { (action) in
            
            self.imagePickerController.photoFromGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Capture image from camera", style: .default, handler: { (action2) in
            
            self.imagePickerController.photoFromCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true,completion: nil)
        
    }
}




extension ProfileVC {
    
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


extension ProfileVC{
    
    @objc func updateUserprofile(sender : UIButton){
        
        usernametext = username.text!; passwordtext = userPssword.text!;phonetext = userPhoneNumber.text!
        
        if (usernametext.isEmpty || passwordtext.isEmpty || phonetext.isEmpty){
            Alert.showLoginAlert(Message: "", title: "Please fill all the fields", window: self)
        }else{
            if selectedImage == nil {
                Alert.showLoginAlert(Message: "", title: "Please upload the image", window: self)
                
            }else {
                self.startAnimating()
                
                
                if let userID = AuthServices.shared.userValue{
                    
                    
                    let storageRef = Storage.storage().reference().child("myImage").child(userID).child("image.jpg")
                          
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
                                      
                                    let newDB =   DBRef.child("User Details").child(AuthServices.shared.userValue!)
                                      print("The db is \(newDB.key)")
                                      
                                      
                                      newDB.updateChildValues(["image_URl" : String(describing: url!),"password" : self.passwordtext, "phone" :  self.phonetext , "name" : self.usernametext ], withCompletionBlock: { (error, dbre) in
                                          
                                          if err != nil{
                                              self.stopAnimating()
                                              Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                                              print("err",err)
                                              return
                                          }
                                          
                                          AuthServices.shared.userObj = self.username.text ?? ""
                                          AuthServices.shared.userPassword = self.userPssword.text ?? ""
                                          AuthServices.shared.userPhoneNumber = self.userPhoneNumber.text ?? ""
                                          AuthServices.shared.userImage = String(describing: url!)
                                          
                                          self.stopAnimating()
                                          
                                          Alert.showLoginAlert(Message: "", title: "User Updated Sucessfully", window: self)
                                          print(dbre.childByAutoId())
                                          
                                      })
                                      
                                      // newDB.updateChildValues(["Car_Id" : new])
                                      
                                  })
                              }
                          }else{
                              self.stopAnimating()
                              print("Storage")
                          }
                    
                }else{
                    
                    self.stopAnimating()
                    
                    print("\n\n User ID is herle ")
                }
      
                
                
                
                
                // Alert.showLoginAlert(Message: "", title: "Car added successfully", window: self)
                
            }
            
        }
        
        
        
    }
    
    
}

extension ProfileVC{
    @objc func addUserprofile(){
        let DBRef = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/")
        usernametext = username.text!; passwordtext = userPssword.text!;phonetext = userPhoneNumber.text!
        
        if (usernametext.isEmpty || passwordtext.isEmpty || phonetext.isEmpty){
            Alert.showLoginAlert(Message: "", title: "Please fill all the fields", window: self)
        }else{
            if selectedImage == nil {
                Alert.showLoginAlert(Message: "", title: "Please upload the image", window: self)
                
            }else {
                
//                auth_id:
//                "QsKxf06l8dYR1GI7zlaJ7mEJncE2"
//                id:
//                "-LkkRrH3Qbl5Mi8Fprzy"
//                image_URI:
//                "https://firebasestorage.googleapis.com/v0/b/tac..."
//                isfborgmail:
//                true
//                name:
//                "Abidur.c@gmail.com"
//                password:
//                "choudhury1"
//                phone:
//                "+447764962892"

                self.startAnimating()
               
                let dbAction = DBRef.child("User Details").childByAutoId()
                
           
                let param = ["auth_id" : "","id" : dbAction.key!]
                //print(dbAction.key)
             //   dbAction.updateChildValues(<#T##values: [AnyHashable : Any]##[AnyHashable : Any]#>, withCompletionBlock: <#T##(Error?, DatabaseReference) -> Void#>)
                
                
                
                if let userID =  dbAction.key{

                    print("The current user ID IS HERE :: \(userID)")
                    let storageRef = Storage.storage().reference().child("myImage").child(userID).child("image.jpg")

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

                                    let newDB =   DBRef.child("User Details").child(userID)
                                      print("The db is \(newDB.key)")

                                    print("The new image url is here", url)
                                    newDB.updateChildValues(["image_URI" : String(describing: url!),"password" : self.passwordtext, "phone" :  self.phonetext , "name" : self.usernametext,"auth_id":self.authID,"id": userID,"isfborgmail":false ], withCompletionBlock: { (error, dbre) in

                                          if err != nil{
                                              self.stopAnimating()
                                              Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                                              print("err",err)
                                              return
                                          }
  self.stopAnimating()
                                        AuthServices.shared.userObj = self.username.text ?? ""
                                        AuthServices.shared.userPassword = self.userPssword.text ?? ""
                                        AuthServices.shared.userPhoneNumber = self.userPhoneNumber.text ?? ""
                                        AuthServices.shared.userImage = String(describing: url!)
                                        
                                        AuthServices.shared.loginVal = true
                                        
                                        AuthServices.shared.userValue = userID
                                        
                                      
                                       
                                       
                                        
                                        let drawerVC = DrawerVC.instantiateViewController() as? DrawerVC
                                      //  drawerVC!.userData = filter.first!
                                        
                                        let MainSB = KYDrawerController.instantiateViewController()
                                        
                                        //     AppDelegate.allUser = filter.first!
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.window?.rootViewController = MainSB

                                        

                                       //   Alert.showLoginAlert(Message: "", title: "User Updated Sucessfully", window: self)
                                          print(dbre.childByAutoId())

                                      })

                                      // newDB.updateChildValues(["Car_Id" : new])

                                  })
                              }
                          }else{
                              self.stopAnimating()
                              print("Storage")
                          }

                }else{

                    self.stopAnimating()

                    print("\n\n User ID is herle ")
                }

                
                
                
                
                // Alert.showLoginAlert(Message: "", title: "Car added successfully", window: self)
                
            }
            
        }
        
    }
    
    
    func checkUserExsistance(completion : ((Bool)->())?){
        
         let DBRef = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/")
       // +923004534531
        let newDB =   DBRef.child("User Details").queryOrdered(byChild: "phone").queryEqual(toValue: userPhoneNumber.text!)
        newDB.observe(.value, with: { (snapPhot) in
            print(snapPhot.value,snapPhot.childrenCount)
            
            if snapPhot.childrenCount == 0{
                completion!(true)
            }else{
                completion!(false)
            }
            
//            if let data  = snapPhot.value{
//                print("good")
//
//
//
//            }else{
//                completion!(false)
//                print("bad")
//            }
        }) { (erooor) in
            print(erooor)
            completion!(false)
        }
    }
    
    
    @objc func actionOnRegister(sender : UIButton){
     
         self.addUserprofile()
    }
    
    
    

}



struct PlaceData {
    
    var placeName : String?
    var placeAddress : String?
    var TimeFormat : String?
    
}
