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
import AuthenticationServices


class RegisterMenuVC: UIViewController {
    
    @IBOutlet weak var appleSignInView: UIView!
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
        facebookBtnOutlet.setShadowOnView(cornerRadius: self.mobileBtnOutlet.frame.height/2)
        googleBtnOutlet.setShadowOnView(cornerRadius: self.mobileBtnOutlet.frame.height/2)
        mobileBtnOutlet.addTarget(self, action: #selector(openSignInController), for: .touchUpInside)
        
      //  facebookBtnOutlet.setTitle(" facebook", comment: ""), for: .normal)
        
        facebookBtnOutlet.setTitle("\(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.SignUp.rawValue, comment: "")) facebook", for: .normal)
        
          googleBtnOutlet.setTitle("\(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.SignUp.rawValue, comment: "")) Google", for: .normal)
        
          mobileBtnOutlet.setTitle("\(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.SignUp.rawValue, comment: "")) Mobile Number", for: .normal)
        
        // fbLogin.delegate = self
        //  self.facebookBtnOutlet.delegate = self
        if #available(iOS 13.0, *) {
            self.setupSignInButton()
        } else {
            
            // Fallback on earlier versions
        }
        
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



extension RegisterMenuVC{
    
    func setUpFirebase(){
        
          let DBRef = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/")
        
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
            
            if  let imageData  = #imageLiteral(resourceName: "flood").jpegData(compressionQuality: 0.5){
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
                        newDB.updateChildValues(["image_URI" : String(describing: url!),"password" : "1234567", "phone" : "+923347507000" , "name" : "UserDumm","auth_id":userID,"id": userID,"isfborgmail":false ], withCompletionBlock: { (error, dbre) in
                            
                            if err != nil{
                                self.stopAnimating()
                                Alert.showLoginAlert(Message: "", title: err as! String, window: self)
                                print("err",err)
                                return
                            }
                            self.stopAnimating()
                            AuthServices.shared.userObj = "UserDumm" ?? ""
                            AuthServices.shared.userPassword = "12345"
                            AuthServices.shared.userPhoneNumber = "923347507000"
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
        
        
        
        
    }
}

extension RegisterMenuVC : ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    
    
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        print(appleIDCredential.fullName,appleIDCredential.email)
        
        print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.email))")
        print(appleIDCredential)
        let vc = ProfileVC.instantiateViewController()
        vc.vcIdentifier = "Complete Profile"
        vc.isApple = true
        self.setUpFirebase()
      //  self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
    
    private func setupSignInButton() {
        if #available(iOS 13.0, *) {
            let signInButton = ASAuthorizationAppleIDButton()
            signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchDown)
            self.appleSignInView.getRoundedcorner(cornerRadius: self.appleSignInView.roundHeight())
            
            signInButton.translatesAutoresizingMaskIntoConstraints = false
            self.appleSignInView.addSubview(signInButton)
            //signInButton.frame = self.appleSignInView.frame
            
            NSLayoutConstraint.activate([
                signInButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.appleSignInView.centerXAnchor, multiplier: 1),
                signInButton.centerYAnchor.constraint(equalToSystemSpacingBelow: self.appleSignInView.centerYAnchor, multiplier: 1),
                signInButton.heightAnchor.constraint(equalToConstant: 40),
                signInButton.widthAnchor.constraint(equalToConstant:400)
            ])
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    @objc private func signInButtonTapped() {
        if #available(iOS 13.0, *) {
            let authorizationProvider = ASAuthorizationAppleIDProvider()
            let request = authorizationProvider.createRequest()
            request.requestedScopes = [.email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
        
    }
}



