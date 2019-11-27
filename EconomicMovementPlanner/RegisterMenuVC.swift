//
//  RegisterMenuVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 22/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import Firebase
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FirebaseAuth

class RegisterMenuVC: UIViewController {

    @IBOutlet weak var facebookBtnOutlet: UIButton!
    @IBOutlet weak var googleBtnOutlet: UIButton!
    @IBOutlet weak var mobileBtnOutlet: UIButton!
        let activity = UIActivityIndicatorView()
    

    var usersArray : [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        mobileBtnOutlet.setShadowOnView(cornerRadius: self.mobileBtnOutlet.frame.height/2)
        mobileBtnOutlet.addTarget(self, action: #selector(openSignInController), for: .touchUpInside)
        
        // fbLogin.delegate = self
        //  self.facebookBtnOutlet.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func gSignInAction(_ sender: Any) {
         GIDSignIn.sharedInstance()?.signIn()
    }
    @IBAction func fbAction(_ sender: Any) {
        
        let loginManager = LoginManager()
        self.startAnimating()
        loginManager.logIn(permissions: [.email,.publicProfile], viewController: self) { (result) in
            print(result)
            print(result)
            
            
            switch result{
                
            case .cancelled:
                print("\n\n User cancelled data")
                self.stopAnimating()
            case .failed(let err):
                print(err)
                self.stopAnimating()
                Alert.showLoginAlert(Message: "Error login facebook", title: "", window: self)
         
            case .success(let granted, let declined, let token):
                
                print(granted,token)
                
                let graphReq = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"]).start {  (connection, result, error) in
                    
                    
                    if(error == nil) {
                        print("result \(result)")
                        
                        let field = result! as? [String:Any]
                        
                        var imageString = ""
                        let email = field!["email"] as? String ?? ""
                        if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                            print(imageURL)
                            imageString = imageURL
                            let url = URL(string: imageURL)
                            let data = NSData(contentsOf: url!)
                            let image = UIImage(data: data! as Data)
                            
                        }
                        print(AccessToken.current!.tokenString)
                        print(token.tokenString)
                        print(token.appID)
                        let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                        self.stopAnimating()
//                        let vc = ProfileVC.instantiateViewController()
//                        vc.vcIdentifier = "Complete Profile"
//                        vc.authID = ""
//                        vc.socialEmail = email
//                        vc.socialImage = imageString
//                        
//                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        self.startAnimating()
                        self.checkUserExsistance(email) { (val) in
                            self.stopAnimating()
                            if val{
                                let vc = ProfileVC.instantiateViewController()
                                vc.vcIdentifier = "Complete Profile"
                                vc.authID = ""
                                vc.socialEmail = email
                                vc.socialImage = imageString
                                vc.isGmailOrFB = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                Alert.showLoginAlert(Message: "User already in the database", title: "", window: self)
                            }
                        }
                        
                        
//                        Auth.auth().signIn(with: credential) { (authResult, error) in
//                            if let error = error {
//                                // ...
//
//                                print("fb error",error)
//                                self.stopAnimating()
//                                return
//                            }
//                            // User is signed in
//                            // ...
//                            self.stopAnimating()
//
//                        }
//
                    } else {
                        self.stopAnimating()
                        print("error \(error)")
                    }
                }
                
//                let req =    GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: token.appID, version: nil, httpMethod: .get)
//
//                req.start { (connection, result, error) in
//
//                    if(error == nil) {
//                        print("result \(result)")
//                    } else {
//                        print("error \(error)")
//                    }
//                }
            }
        }
  
    }
    
//    loginManager.logIn(permissions: ["email","public_profile"], from: self) { (result, error) in
//
//          print(error,result)
//
//          if error != nil {
//
//              return
//          }
//          guard let token = AccessToken.current else {
//              print("Failed to get access token")
//
//              return
//          }
//
//          print("\n The token is here",token.appID)
//
//
//      }
}

extension RegisterMenuVC{
    
    @objc func openSignInController(){
        performSegue(withIdentifier: Keys.SegueName().registerSegue, sender: nil)
    }
}



extension RegisterMenuVC : GIDSignInDelegate{
    
    
    func checkUserExsistance(_ email : String, completion : ((Bool)->())?){
        
        let DBRef = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/")
        // +923004534531
        let newDB =   DBRef.child("User Details").queryOrdered(byChild: "name").queryEqual(toValue: email)
        newDB.observe(.value, with: { (snapPhot) in
            print(snapPhot.value,snapPhot.childrenCount)
            
            if snapPhot.childrenCount == 0{
                completion!(true)
            }else{
                completion!(false)
            }
            
        }) { (erooor) in
            print(erooor)
            completion!(false)
        }
    
 
        
      
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        print("User details")
        print(user.profile.name)
        print(user.profile.familyName)
        print(user.profile.imageURL(withDimension: 200))
        
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        self.startAnimating()
        self.checkUserExsistance(email!) { (val) in
        self.stopAnimating()
            if val{
                let vc = ProfileVC.instantiateViewController()
                       vc.vcIdentifier = "Complete Profile"
                       vc.authID = user.authentication.idToken
                       vc.socialEmail = email!
                       vc.isGmailOrFB = true
                       if let img =  user.profile.imageURL(withDimension: 200){
                            print("The image is", img)
                            vc.socialImage = String(describing: img)
                       }
                      
                       
                       self.navigationController?.pushViewController(vc, animated: true)
            }else{
                Alert.showLoginAlert(Message: "User already in the database", title: "", window: self)
            }
        }
        
        print(email)
       
        
    }
}

extension RegisterMenuVC : LoginButtonDelegate{
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        print(result)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout tap")
    }
    
  
    
    
    
}

extension RegisterMenuVC {
    
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

