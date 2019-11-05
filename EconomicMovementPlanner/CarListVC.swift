//
//  CarListVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 31/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import Firebase
import CodableFirebase

class CarListVC: UIViewController {
    
    @IBOutlet weak var addCarAction: UIButton!
    typealias secondResponse = [String : [String : Any]]
    typealias firstResponse = [String : secondResponse]
    
    var carArray : [CarModel] = []
    let activity = UIActivityIndicatorView()

    @IBOutlet weak var carTV: UITableView! {
        
        didSet{
            carTV.delegate = self
            carTV.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Cars"
        let nib = UINib(nibName: "CarsTVCell", bundle: nil)
        carTV.register(nib, forCellReuseIdentifier: Keys.CellIds().carCell)
        carTV.tableFooterView = UIView(frame: .zero)
        
        
        self.addCarAction.addTarget(self, action: #selector(openCarAddVC(sender:)), for: .touchUpInside)
        
        self.navigationController?.setUpBarColor()
       self.navigationController?.setUpTitleColor()
        setUpMenuButton()
        self.startAnimating()
        

        FIRService.shared.getDataFromDataBase("Car Details") { (response) in
            self.stopAnimating()
           print(response)
            
            
            
            do {
                let model = try FirebaseDecoder().decode([CarModel].self, from: response)
                
                print(model)
               
                
            } catch let error {
                print(error)
            }
        
            
            
            if let newData  = response  as? [[String : Any]]{
                
                print(newData.count)
                
                for val in newData{
                    
                    print(val)
                }
            }
            if let data  = response as? firstResponse{
                print("Values are")
                print(data.count)
                
                print(data)
                
               
               
//                for newValues in data{
//                    print(newValues.key)
//
//                    print(AuthServices.shared.userValue)
//                    if (newValues.key ==  AuthServices.shared.userValue){
//
//                        print("\n\n\n")
//                        print("The Current Array Vals are here", newValues.key,AuthServices.shared.userValue)
//                        print(newValues.key)
//                        print(newValues.value)
//                        print("\n\n\n")
//                        for new in newValues.value{
//
//                            print("Actual value")
//                            print(new.value)
//                            let temp = CarModel(data: new.value)
//                            print("tempobjdect", temp.Name)
//
////                            let filter = self.carArray.filter({$0.Car_Id == temp.Car_Id})
////
////                            if filter.count > 0{
////
////                            }
//                            self.carArray.append(temp)
//
//                        }
//                    }
//                }
            }
            
            
            
            DispatchQueue.main.async {
                self.carTV.reloadData()
            }
            print("The count of cars are \(self.carArray.count)")
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.addCarAction.layer.cornerRadius = self.addCarAction.frame.width/2
    }

    @objc func openCarAddVC(sender : UIButton){
        
        let vc = CarMenuVC.instantiateViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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

extension CarListVC {
    
    internal func setUpMenuButton(){
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-button (1)"), style: .plain, target: self, action: #selector(setUpBarButton))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func setUpBarButton(){
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(KYDrawerController.DrawerState.opened, animated: true)
    }
}



extension CarListVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.carArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIds().carCell, for: indexPath) as? CarsTVCell{
            
            print(carArray[indexPath.item].Mileag)
              print(carArray[indexPath.item].Image_Link)
            cell.carObject = carArray[indexPath.item]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 146
    }
}


extension CarListVC :StoryboardInitializable {}


extension CarListVC {
    
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
