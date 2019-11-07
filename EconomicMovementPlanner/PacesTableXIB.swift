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
    
    var placeName : [String] = []
    var array : [CoordinatesValue] = []
    var filterArray : [CoordinatesValue] = []
    
    @IBOutlet weak var listTV : UITableView!{
        didSet{
            self.listTV.delegate = self
            self.listTV.dataSource = self
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listTV.tableFooterView = UIView(frame: .zero)
        
        self.goOutletAction.addTarget(self, action: #selector(goAction(sender:)), for: .touchUpInside)
        
        
        let nib = UINib(nibName: "NewListTVCell", bundle: nil)
        self.listTV.register(nib, forCellReuseIdentifier: id)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.listTV.reloadData()
    }
    
    @IBAction func cancelRideAction(_ sender: Any) {
        
        delegate?.cancelRouter()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PacesTableXIB : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
     
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? NewListTVCell{
            
            cell.switchOutlet.tag = indexPath.row
            cell.switchOutlet.addTarget(self, action: #selector(tapOnSwitch(_:)), for: .valueChanged)
            cell.directionLbl.text = self.array[indexPath.row].lineString
            
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
        
        if sender.isOn{
            
          self.array[sender.tag].isSelect = true
        }else{
            //  self.filterArray.removeAll(where: {$0})
           self.array[sender.tag].isSelect = false
        }
        
    }
    
    
    @objc func actionOnSwitch(sender : UISwitch){
        
        print(sender.tag)
        if sender.isOn{
            
        }
    }
    
    @objc func goAction(sender : UIButton){
        
        
        let filer = self.array.filter({$0.isSelect == true})
        if filer.count > 0{
            self.dismiss(animated: true) {
                self.delegate?.getData(arr: self.array.filter(({$0.isSelect! == true})))
            }
            
        }
       
//        if self.array.filter(({$0.isSelect == false})).count == 0{
//
//            Alert.showLoginAlert(Message: "Please select any Location", title: "", window: self)
//        }else{
//
//
//        }
        
    }
}
