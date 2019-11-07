//
//  ChangePasswordVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 05/11/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var passTextField: UITextField!{
        didSet{self.passTextField.delegate = self}
    }
    
    @IBOutlet weak var resetPassword: UIButton!
    
    var currentUser : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = self.currentUser{
            print(user.name,user.phone,user.id,user.auth_id)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
}


extension ChangePasswordVC : UITextFieldDelegate{}
extension ChangePasswordVC : StoryboardInitializable {}
