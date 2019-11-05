//
//  TripVC.swift
//  EconomicMovementPlanner
//
//  Created by talha on 15/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController

class TripVC: UIViewController {
    
    
    @IBOutlet weak var tripTV: UITableView!{
        didSet{self.tripTV.dataSource = dataSource}
    }
    
    private let dataSource = TripDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        print("Trip VC CALLING\n\n")
        
        self.title = "My Trips"
        dataSource.registerCells(with: tripTV)
        self.navigationController?.setUpBarColor()
        self.navigationController?.setUpTitleColor()
        setUpMenuButton()
        
    }
    
}



extension TripVC  : StoryboardInitializable {}



extension TripVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc fileprivate func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
}
