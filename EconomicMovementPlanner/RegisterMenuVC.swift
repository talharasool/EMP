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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    
}

extension RegisterMenuVC{
    
    @objc func openSignInController(){
        performSegue(withIdentifier: Keys.SegueName().registerSegue, sender: nil)
    }
}



extension RegisterMenuVC : GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
