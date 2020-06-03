//
//  ChangePasswordVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 05/11/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var passTextField: UITextField!{
        didSet{self.passTextField.delegate = self}
    }
    
    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var resetPassword: UIButton!
    
    var currentUser : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        changePasswordLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.change_password.rawValue, comment: "")
        
        headLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.enter_a_secure_password_txt.rawValue, comment: "")
    
        resetPassword.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.reset_password.rawValue, comment: ""), for: .normal)
        
        passTextField.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Password.rawValue, comment: "")


        if let user = self.currentUser{
            print(user.name,user.phone,user.id,user.auth_id)
        }
        
         self.resetPassword.addTarget(self, action: #selector(resetAction(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
       
        
    }
    
    
    func updatePassword(_ param :  String){
        
        if let user = self.currentUser{
            
            let val =  Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child("User Details").child(user.id)
            
            val.updateChildValues(["password" : param])
            
            let alert = UIAlertController(title: "Password Update Successfully", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (alert) in
                
                self.navigationController?.popToRootViewController(animated: true)
            }))
        
            self.present(alert,animated: true)
            
        }
        
        

        
        
        
    }
    
    @objc func resetAction(_ sender : UIButton){
        
        if let password = passTextField.text{
            self.updatePassword(password)
        }
    }
}


extension ChangePasswordVC : UITextFieldDelegate{}
extension ChangePasswordVC : StoryboardInitializable {}


