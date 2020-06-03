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


let car_Notify_Key = Notification.Name("CarUpdateKey")


class DrawerVC: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var carnameLbl: UILabel!
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
    
    
    
    func createObserver(){
        print("Observer is Listing")
        NotificationCenter.default.addObserver(self, selector: #selector(self.getCarsFromServer), name: car_Notify_Key, object: nil)
        
        
        DispatchQueue.main.async {
            
            //Perform any thing on UI
            
        }
        
        
        
        
    }
    
    var menuItems = [DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Home.rawValue, comment: ""), image: #imageLiteral(resourceName: "home")),DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.mycars.rawValue, comment: ""), image: #imageLiteral(resourceName: "basecar")),DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.mytrips.rawValue, comment: ""), image: #imageLiteral(resourceName: "trip")),DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.AddCar.rawValue, comment: ""), image: #imageLiteral(resourceName: "ic_add")),DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.settings.rawValue, comment: ""), image: #imageLiteral(resourceName: "settings-cog")),
                     DrawerItems(name: LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.settings.rawValue, comment: ""), image: #imageLiteral(resourceName: "logout"))]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did Load is calling from drawer vc")
        self.createObserver()
        self.backView.setBackground(imageName: "background")
        print(AppDelegate.allUser.name)
        self.navigationController?.isNavigationBarHidden = true
        let userVal = UserDefaults.standard.value(forKey: AppIdentifiers.Defaults().loginObject) as? User ?? User(data: [:])
        
        self.optionTV.tableFooterView = UIView(frame: .zero)
        self.getCarsFromServer()
        dropDown.anchorView = self.dropDownBtnOutlet
        
        self.dropDownBtnOutlet.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            
            
            if let carImageURL = URL(string: self.carArray[index].Image_Link!){
                self.carImageView.sd_setImage(with: carImageURL, completed: nil)
                self.carnameLbl.text = self.carArray[index].Name
                 AuthServices.shared.carId = self.carArray[index].Car_Id
              //   CarManger.shared.singleCarData = self.carArray[index]
            }
            self.dropDown.hide()
            
        }
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View will appear is calling in drawer vc")
    
        
        if (AuthServices.shared.loginVal ?? false){
            
            
            print(AuthServices.shared.userObj)
          
            
            self.usernameLabel.text = AuthServices.shared.userObj
            if let imageURL = URL(string: AuthServices.shared.userImage ?? ""){
                self.userImageView.sd_setImage(with: imageURL, completed: nil)
            }
            

            
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        print("Deinit is calling")
        NotificationCenter.default.removeObserver(self)
        
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.carImageView.layer.borderColor = UIColor.white.cgColor
        self.carImageView.layer.borderWidth = 0.8
        self.carImageView.layer.cornerRadius = self.carImageView.frame.width/2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    fileprivate func dismissControllers(){
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            
            let vc = ViewController.instantiateViewController()
            let nav = UINavigationController(rootViewController: vc)
            AuthServices.resetDef()
            delegate.window?.rootViewController = nav
            delegate.window?.makeKeyAndVisible()
        }
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
            cell.menuImage.image = menuItems[indexPath.row].image
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
            setDrawerController(controller: TripVC.instantiateViewController())
        case 3:
            setDrawerController(controller: CarMenuVC.instantiateViewController())
        case 4:
            setDrawerController(controller: ProfileVC.instantiateViewController())
        case 5:
            print("Logout Calling")
            self.dismissControllers()
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
    
    @objc func getCarsFromServer(){
        self.carArray.removeAll()
        self.dropDown.dataSource.removeAll()
        FIRService.shared.getDataFromDataBase("Car Details") { (response) in
            print(AuthServices.shared.userValue)
            // print(response)
            self.carArray.removeAll()
             self.dropDown.dataSource.removeAll()
            self.carnameLbl.text = ""
            self.carImageView.image = nil
            if let data =  response as? [CarModel]{
                
                self.carArray = data
                
                for arr in self.carArray{
                    
                    self.dropDown.dataSource.append(arr.Name)
                    
                }
          
                
                DispatchQueue.main.async {
                    
               
                    if let carID = AuthServices.shared.carId{
                        
                          let filter = self.carArray.filter({$0.Car_Id == carID})
                        
                        
                        if filter.count > 0{
                            
                            if let carImageURL = URL(string: filter[0].Image_Link!){
                                self.carImageView.sd_setImage(with: carImageURL, completed: nil)
                                self.carnameLbl.text = filter[0].Name
                                AuthServices.shared.carId = filter[0].Car_Id
                                CarManger.shared.singleCarData = filter[0]
                            }
                        }else{

                            if self.carArray.count == 0{
                                
                                AuthServices.shared.carId = nil
                                
                            }else{
                                
                                if let imageString = self.carArray[0].Image_Link {
                                    
                                    if let carImageURL = URL(string: imageString){
                                        self.carImageView.sd_setImage(with: carImageURL, completed: nil)
                                        self.carnameLbl.text = self.carArray[0].Name
                                        AuthServices.shared.carId = self.carArray[0].Car_Id
                                        CarManger.shared.singleCarData = self.carArray[0]
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    }else{
                        
                        
                        
                        if let carImageURL = URL(string: self.carArray[0].Image_Link!){
                            self.carImageView.sd_setImage(with: carImageURL, completed: nil)
                            self.carnameLbl.text = self.carArray[0].Name
                            AuthServices.shared.carId = self.carArray[0].Car_Id
                            CarManger.shared.singleCarData = self.carArray[0]
                        }
                        
                        
                    }
                
                }
            }else{
                
                Alert.showLoginAlert(Message: "Unable to fetch data", title: "", window: self)
                
            }
            
            
            
//            if let data  = response as? firstResponse{
//                print("Values are")
//                print(data.count)
//
//                for newValues in data{
//                    print(newValues.key)
//
//                    print(AuthServices.shared.userValue)
//                    if (newValues.key ==  AuthServices.shared.userValue){
//
//
//                        for new in newValues.value{
//                            print("Actual value")
//                            print(new.value)
//                            let temp = CarModel(data: new.value)
//                            print("tempobjdect", temp.Name)
//
//                        //    let filter = self.carArray.filter({$0.Car_Id == temp.Car_Id})
//
//
//                            if let carID = AuthServices.shared.carId{
//
//                                let filter = self.carArray.filter({$0.Car_Id == carID})
//                                if filter.count > 0{
//                                    print("Get car in filer")
//                                }else{
//
//                                    if temp.Image_Link != nil{
//                                        self.carArray.append(temp)
//                                    }
//                                }
//                            }else{
//
//                                if temp.Image_Link != nil{
//                                    self.carArray.append(temp)
//                                }
//
//                            }
//
//
//
//                        }
//
//                    }
//
//                }
//
//                DispatchQueue.main.async {
//
//                    for data in self.carArray{
//
//                        self.dropDown.dataSource.append(data.Name)
//
//                    }
//
//
//                    if let carImageURL = URL(string: self.carArray[0].Image_Link!){
//                        self.carImageView.sd_setImage(with: carImageURL, completed: nil)
//                        self.carnameLbl.text = self.carArray[0].Name
//                        AuthServices.shared.carId = self.carArray[0].Car_Id
//                      //  CarManger.shared.singleCarData = self.carArray[0]
//                    }
//
//
//
//
//                }
//
//            }
//
            
    
            print("The count of cars are \(self.carArray.count)")
        }
        
    }
    
}


class CarManger{
    
    static var shared = CarManger()
    
    var carData : [CarModel] = []
    var singleCarData : CarModel!
    
}
