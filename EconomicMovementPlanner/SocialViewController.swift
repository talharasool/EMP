//
//  SocialViewController.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 15/06/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController

class SocialViewController: UIViewController {

    @IBOutlet weak var signInbtnOutlet: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var socialTitleLabel: UILabel!
    
    var username : String = ""
    var password : String = ""
    var myTitle : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.signInbtnOutlet.addTarget(self, action: #selector(performSignIn(sender:)), for: .touchUpInside)
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
extension SocialViewController : StoryboardInitializable{}
