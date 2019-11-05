//
//  ForgotVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 05/11/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import MRCountryPicker
import Firebase
import FirebaseCore
import FirebaseDatabase


class ForgotVC: UIViewController {

    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    
    
    @IBOutlet weak var resetAction: UIButton!
    
    let activity = UIActivityIndicatorView()
       var usersArray : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
