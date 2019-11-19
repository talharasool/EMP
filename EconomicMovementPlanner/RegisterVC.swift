//
//  RegisterVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 29/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import MRCountryPicker
import GoogleSignIn
import FirebaseAuth
import Firebase

class RegisterVC: UIViewController {

    let btn  = GIDSignInButton()
    @IBOutlet weak var signInBtnOutlet: GIDSignInButton!
    @IBOutlet weak var varificationBtnOutlet: UIButton!
    
    let activity = UIActivityIndicatorView()
  
    let countriesPikerView = MRCountryPicker()
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var verificationCodeField: UITextField!
    
    var credID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mobileBtnOutlet.layer.cornerRadius = self.mobileBtnOutlet.frame.height/2
        self.navigationController?.isNavigationBarHidden = false
        self.signInBtnOutlet.addTarget(self, action: #selector(numberVerifyAction(_:)), for: .touchUpInside)
        self.varificationBtnOutlet.addTarget(self, action: #selector(phoneVerifyAction(sender:)), for: .touchUpInside)
        
        countryCodeField.inputView = countriesPikerView
        setCountryPickerDelegate()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.varificationBtnOutlet.layer.cornerRadius = self.varificationBtnOutlet.frame.height/2
        self.signInBtnOutlet.layer.cornerRadius = self.signInBtnOutlet.frame.height/2
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     //   self.navigationController?.isNavigationBarHidden = true
    }
    
    func setCountryPickerDelegate(){
        
        countriesPikerView.countryPickerDelegate = self
        countriesPikerView.showPhoneNumbers = true
        countriesPikerView.setCountry("PK")
        countriesPikerView.setCountryByName("Pakistan")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Keys.SegueName().finalRegisterSegue{
            
            let dest = segue.destination as? ProfileVC
            
            dest?.vcIdentifier = "Register"
        }
    }

}

extension RegisterVC :MRCountryPickerDelegate, UITextFieldDelegate {
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        countryCodeField.text = phoneCode
        //countryCodeField.text = name
    }
}

extension RegisterVC {
    
    
    
    func checkUserExsistance(phone : String ,completion : ((Bool)->())?){
        
        let DBRef = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/")
        // +923004534531
          let newDB =   DBRef.child("User Details").queryOrdered(byChild: "phone").queryEqual(toValue: phone)
      //  let newDB =   DBRef.child("User Details").queryOrdered(byChild: "").
        newDB.observe(.value, with: { (snapPhot) in
            print(snapPhot.value,snapPhot.childrenCount)
            
            if snapPhot.childrenCount > 0{
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
    
    
    
    @objc func numberVerifyAction(_ sender : UIButton){
        self.view.endEditing(true)
        let code = verificationCodeField.text ?? ""
      
        self.startAnimating()
        if (!(code.isEmpty)){
          
            print("Code :: \(code)")
            self.verifyNumber(code: code)
        
        }else {
            self.stopAnimating()
            Alert.showLoginAlert(Message: "", title: "Please enter the verification code ", window: self)
        }
    }
    
    
    @objc func phoneVerifyAction(sender : UIButton){
         self.view.endEditing(true)
         let phone = phoneField.text ?? ""
         let ext = self.countryCodeField.text ?? ""
         self.startAnimating()
         if (!(phone.isEmpty)){
             let number = ext + phone
             print("Phone Number :: \(phone)")
             
             self.checkUserExsistance(phone: number) { (isExsit) in
                 self.stopAnimating()
                 if isExsit{
                     print("Exsit")
                     Alert.showLoginAlert(Message: "User already exist \(number)", title: "", window: self)
                 }else{
                     print("Not Exsist")
                     PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (val, err) in
                         print(val,err)
                         self.stopAnimating()
                         if err != nil {
                             print("error")
                             print("Unable to send verification code")
                             Alert.showLoginAlert(Message: "Unable to send verification code", title: "", window: self)
                             return
                         }
                           self.credID = val!
                          Alert.showLoginAlert(Message: "OTP has send to your number", title: "", window: self)
                     }
                 }
             }
         
         }else {
             Alert.showLoginAlert(Message: "", title: "Please enter the phone number", window: self)
         }
     }
    
    
    @objc func phoneAuthAction(sender : UIButton){
        
        let verify = verificationCodeField.text!
        
        if (!(verify.isEmpty)){
            
            performSegue(withIdentifier: Keys.SegueName().finalRegisterSegue, sender: nil)
            
        }else {
            Alert.showLoginAlert(Message: "", title: "Please enter the verificcation code", window: self)
        }
    }
    
//   03117007950
    func verifyNumber(code : String){
    self.startAnimating()
     let credentials =    PhoneAuthProvider.provider().credential(withVerificationID: self.credID, verificationCode: code)
        Auth.auth().signIn(with: credentials) { (result, error) in
            self.stopAnimating()
            if error != nil{
                Alert.showLoginAlert(Message: "Unable to verify OTP", title: "", window: self)
                return
            }
            print(result?.user.providerID)
            print(result?.user.uid)
            let vc =  ProfileVC.instantiateViewController()
            vc.vcIdentifier = "Complete Profile"
            vc.authID = (result?.user.uid)!
            self.navigationController?.pushViewController(vc, animated: true)
            
          
        }
        
    }
    
    
}



extension RegisterVC {
    
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
