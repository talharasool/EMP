//
//  RegisterVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 29/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import MRCountryPicker

class RegisterVC: UIViewController {

    @IBOutlet weak var signInBtnOutlet: UIButton!
    @IBOutlet weak var varificationBtnOutlet: UIButton!
  
    let countriesPikerView = MRCountryPicker()
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var verificationCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mobileBtnOutlet.layer.cornerRadius = self.mobileBtnOutlet.frame.height/2
        self.navigationController?.isNavigationBarHidden = false
        self.signInBtnOutlet.addTarget(self, action: #selector(phoneAuthAction(sender:)), for: .touchUpInside)
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
    
    
    @objc func phoneVerifyAction(sender : UIButton){
        
        let phone = phoneField.text!
        
        if (!(phone.isEmpty)){
            
            
            
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
    
    
}
