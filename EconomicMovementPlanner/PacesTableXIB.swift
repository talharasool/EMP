//
//  PacesTableXIB.swift
//  EconomicMovementPlanner
//
//  Created by talha on 22/08/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class PacesTableXIB: UIViewController {

    @IBOutlet weak var goOutletAction: UIButton!
    
    let id  = "listCell"
    
    
    weak var delegate : PaceCellDelegate?
    
    var array : [CoordinatesValue] = []
    
    @IBOutlet weak var listTV : UITableView!{
        didSet{
            self.listTV.delegate = self
            self.listTV.dataSource = self
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.goOutletAction.addTarget(self, action: #selector(goAction(sender:)), for: .touchUpInside)
        
        let nib = UINib(nibName: "NewListTVCell", bundle: nil)
        self.listTV.register(nib, forCellReuseIdentifier: id)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.listTV.reloadData()
    }
    
    @IBAction func cancelRideAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PacesTableXIB : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? NewListTVCell{
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    
    @objc func  tapOnSwitch(_ sender : UISwitch){
    
        print(sender.tag)
        
       var  switchCell =  self.listTV.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! NewListTVCell
        
     

    
    }
    
    @objc func goAction(sender : UIButton){
       delegate?.getData(arr: self.array)
        
        self.dismiss(animated: true, completion: nil)
    }
}
