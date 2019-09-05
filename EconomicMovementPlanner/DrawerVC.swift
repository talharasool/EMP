//
//  DrawerVC.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 29/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import KYDrawerController
import FirebaseAuth
import FirebaseDatabase
import DropDown

class DrawerVC: UIViewController {
    
    typealias secondResponse = [String : [String : Any]]
    typealias firstResponse = [String : secondResponse]
    var carArray : [CarModel] = []
    
    @IBOutlet weak var dropDownBtnOutlet: UIButton!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private let dropDown = DropDown()
    
    var userData : User?
    @IBOutlet weak var optionTV: UITableView!{
        didSet{
            
            self.optionTV.delegate = self
            self.optionTV.dataSource = self
        }
    }
    
    
    var menuItems = [DrawerItems(name: "Home", image: nil),DrawerItems(name: "My Cars", image: nil),DrawerItems(name: "My Trips", image: nil),DrawerItems(name: "Add Cars", image: nil),DrawerItems(name: "Setting", image: nil),
                     DrawerItems(name: "Logout", image: nil)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did Load is calling from drawer vc")
       
        print(AppDelegate.allUser.name)
        self.navigationController?.isNavigationBarHidden = true
        let userVal = UserDefaults.standard.value(forKey: AppIdentifiers.Defaults().loginObject) as? User ?? User(data: [:])
        
     
       
        self.optionTV.tableFooterView = UIView(frame: .zero)
        
        dropDown.anchorView = self.dropDownBtnOutlet
    
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View will appear is calling in drawer vc")
        
        
        if (AuthServices.shared.loginVal){
            
            self.getCarsFromServer()
            print(AuthServices.shared.userObj)
            self.dropDownBtnOutlet.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
            
            self.usernameLabel.text = AuthServices.shared.userObj
            if let imageURL = URL(string: AuthServices.shared.userImage){
                self.userImageView.sd_setImage(with: imageURL, completed: nil)
            }
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                
                
                if let carImageURL = URL(string: self.carArray[index].Image_Link){
                    self.carImageView.sd_setImage(with: carImageURL, completed: nil)
                }
                self.dropDown.hide()
                
            }
            
            
        }
        
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.carImageView.layer.cornerRadius = self.carImageView.frame.width/2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}


extension DrawerVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Keys.Xibs().MenuXib, for: indexPath) as? MenuCell{
            
            cell.menuLabel.text = menuItems[indexPath.row].name
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  55
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            setDrawerController(controller: HomeVC.instantiateViewController())
        case 1:
            setDrawerController(controller: CarListVC.instantiateViewController())
        case 2:
            setDrawerController(controller: CarListVC.instantiateViewController())
        case 3:
            setDrawerController(controller: CarMenuVC.instantiateViewController())
        case 4:
            setDrawerController(controller: ProfileVC.instantiateViewController())
        case 5:
            print("Logout Calling")
        //setDrawerController(controller: ProfileVC.instantiateViewController())
        default:
            break
        }
    }
    
    func setDrawerController(controller : UIViewController){
        
        let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
        let vc = controller
        let nav = UINavigationController.init(rootViewController: vc)
        drawer.mainViewController = nav
        drawer.setDrawerState(.closed, animated: true)
        
    }
}




//    let drawer : KYDrawerController  = self.navigationController?.parent as! KYDrawerController
//    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: sbName().AboutVC) as! AboutVC
//    let nav = UINavigationController.init(rootViewController: vc)
//    drawer.mainViewController = nav
//    drawer.setDrawerState(.closed, animated: true)

struct  DrawerItems {
    
    let name : String?
    let image : UIImage?
}


extension DrawerVC : StoryboardInitializable{
    
}

extension DrawerVC{
    
    
    @objc func showDropDown(){
    
        dropDown.show()
    }
    
    func getCarsFromServer(){
        
        FIRService.shared.getDataFromDataBase("Car Details") { (response) in
           
            // print(response)
            
            if let data  = response as? firstResponse{
                print("Values are")
                print(data.count)
                
                for newValues in data{
                    print(newValues.key)
                    
                    print(AuthServices.shared.userValue)
                    if (newValues.key ==  AuthServices.shared.userValue){
                        
                        for new in newValues.value{
                            print("Actual value")
                            print(new.value)
                            let temp = CarModel(data: new.value)
                            print("tempobjdect", temp.Name)
                            
                            let filter = self.carArray.filter({$0.Car_Id == temp.Car_Id})
                            
                            if filter.count > 0{
                                
                            }
                            self.carArray.append(temp)
                            
                          
                            
                        }
                        
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    for data in self.carArray{
                        
                        self.dropDown.dataSource.append(data.Name)
                    }
                }
            
            }
            
            
    
            print("The count of cars are \(self.carArray.count)")
        }
        
    }
    
}
