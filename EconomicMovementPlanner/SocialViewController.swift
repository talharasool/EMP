//
//  SocialViewController.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 15/06/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import MRCountryPicker
import KYDrawerController
import Firebase
import FirebaseCore
import FirebaseDatabase



class SocialViewController: UIViewController {
    
    @IBOutlet weak var signInbtnOutlet: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var socialTitleLabel: UILabel!
    
    var username : String = ""
    var password : String = ""
    var myTitle : String = ""
    
    let activity = UIActivityIndicatorView()
    var usersArray : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInbtnOutlet.addTarget(self, action: #selector(signInSocial(sender:)), for: .touchUpInside)
        socialTitleLabel.text = self.myTitle
      
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.signInbtnOutlet.layer.cornerRadius = self.signInbtnOutlet.frame.height/2
    }
    
}

extension SocialViewController {
    
    @objc func performSignIn(sender : UIButton){
        
        password = passwordField.text!
        username = usernameField.text!
        
        if (password.isEmpty || username.isEmpty){
            Alert.showLoginAlert(Message: "", title: "Please fill all the fields", window: self)
        }else {
            let MainSb = KYDrawerController.instantiateViewController()
            self.present(MainSb,animated: true)
        }
    }
}
//Segue Definition
extension SocialViewController : StoryboardInitializable{
    
    @objc func signInSocial(sender : UIButton){
        self.view.endEditing(true)
        if let phoneNumber  = usernameField.text?.replacingOccurrences(of: " ", with: ""),  let password = passwordField.text?.replacingOccurrences(of: " ", with: "") {
            
       
   
            if (phoneNumber.isEmpty || password.isEmpty){
                
                let alert = UIAlertController(title: "Please fill all the fields", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert,animated: true)
                
            }else {
                self.startAnimating()
                self.usersArray.removeAll()
                
                let dbValues  = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child("User Details").observe(.value
                    , with: { (snapshot) in
                        self.stopAnimating()
                        print(snapshot.value)
                        print("The count is here")
                        print(snapshot.childrenCount)
                        //                        print("The value are\n")
                        //                        let snapValue = snapshot.children
                        //                        print(snapshot.childrenCount)
                        
                        if let data  =  snapshot.value as? [String :[String : Any]]{
                            print(data)
                            
                            for values in data{
                                print()
                                let temp = User(data: values.value)
                                self.usersArray.append(temp)
                            }
                        }
                        
                        let filter = self.usersArray.filter({$0.name == phoneNumber && $0.password == password})
                        print("The filter values are")
                        print(filter.first?.phone)
                        print(filter.count)
                        if (filter.count > 0){
                            
                            AuthServices.shared.loginVal = true
                            
                            AuthServices.shared.userValue = filter.first!.id
                            AuthServices.shared.userImage = filter.first!.image_URI
                            AuthServices.shared.userObj = filter.first!.name
                            AuthServices.shared.userPassword = filter.first!.password
                            AuthServices.shared.userPhoneNumber = filter.first!.phone
                            
                            let drawerVC = DrawerVC.instantiateViewController() as? DrawerVC
                            drawerVC!.userData = filter.first!
                            
                            let MainSB = KYDrawerController.instantiateViewController()
                            
                            //     AppDelegate.allUser = filter.first!
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = MainSB
                            
                        }else{
                            
                            let alert = UIAlertController(title: "Error", message:"User Not Found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                            self.present(alert,animated: true)
                        }
                        
                        print("The count is here : \(self.usersArray.count)")
                        
                }) { (error) in
                    print("The error is here \(error)")
                    let alert = UIAlertController(title: "Error", message:error as! String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    self.present(alert,animated: true)
                    print("err")
                }
                
            }
            
        }else {
            
            let alert = UIAlertController(title: "Please fill all the fields", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert,animated: true)
            
        }
    }
}


extension SocialViewController {
    
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
