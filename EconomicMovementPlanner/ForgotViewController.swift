

import UIKit
import MRCountryPicker
import KYDrawerController
import Firebase
import FirebaseCore
import FirebaseDatabase

class ForgotViewController: UIViewController {
    
    deinit
    { print("\n\n--> The Login Deinit <--\n\n") }
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    
    
    let activity = UIActivityIndicatorView()
    var usersArray : [User] = []
    var selectedUser : User?
    
    //  let refDb = Database.database().reference()
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var signUpAction: UIButton!
    
    let countriesPikerView = MRCountryPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentView.setBackground(imageName: "background")
  //      signUpAction.addTarget(self, action: #selector(openRegister), for: .touchUpInside)
        
        
        //        let value  = refDb.child("User Details").observe(DataEventType.value) { (snapshot) in
        //            print(snapshot)
        //        }
        
        navigationController?.removeNavigationBarColor()
        
        countryCodeField.inputView = countriesPikerView
        setCountryPickerDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    
    
    @IBAction func signInAction(_ sender: Any) {
        
        self.view.endEditing(true)
        if let phoneNumber  = phoneTextField.text?.replacingOccurrences(of: " ", with: ""){
            
            var phone = "\(countryCodeField.text!)\(phoneNumber)"
            print("The Phone Is ", phone)
            if (phone.isEmpty){
                
                let alert = UIAlertController(title: "Please enter valid phone number", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(alert,animated: true)
                
            }else {
                self.startAnimating()
                self.usersArray.removeAll()
                
                let dbValues  = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child("User Details").observe(.value
                    , with: { (snapshot) in
                        self.stopAnimating()
                        print(snapshot.value)
                        print("The count is here")
                        print(snapshot.childrenCount)
                        //                        print("The value are\n")
                        //                        let snapValue = snapshot.children
                        //                        print(snapshot.childrenCount)
                        
                        if let data  =  snapshot.value as? [String :[String : Any]]{
                            print(data)
                            
                            for values in data{
                                print()
                                let temp = User(data: values.value)
                                self.usersArray.append(temp)
                            }
                        }
                        
                        let filter = self.usersArray.filter({$0.phone == phone})
                        print("The filter values are")
                        print(filter.first?.phone)
                        print(filter.count)
                        if (filter.count > 0){
                            
                            self.selectedUser = filter.first
                           
                            let vc = ChangePasswordVC.instantiateViewController()
                            vc.currentUser = self.selectedUser
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            
                            let phone = self.phoneTextField.text?.replacingOccurrences(of: " ", with: "")
                            let alert = UIAlertController(title: "Error", message:"This \(self.countryCodeField.text!)\(phone!) number is not resgistered", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                            self.present(alert,animated: true)
                        }
                        
                        print("The count is here : \(self.usersArray.count)")
                        
                }) { (error) in
                    print("The error is here \(error)")
                    let alert = UIAlertController(title: "Error", message:error as! String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    self.present(alert,animated: true)
                    print("err")
                }
            
            }
            
        }else {
            
            let alert = UIAlertController(title: "Please fill all the fields", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert,animated: true)
            
        }
        
    }
    
    @IBAction func facebookActionBtn(_ sender: Any) {
        
        let vc = SocialViewController.instantiateViewController()
        vc.myTitle = "Facebook Login"
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func googleActionBtn(_ sender: Any) {
        
        let vc = SocialViewController.instantiateViewController()
        vc.myTitle = "Google Login"
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setCountryPickerDelegate(){
        
        countriesPikerView.countryPickerDelegate = self
        countriesPikerView.showPhoneNumbers = true
        countriesPikerView.setCountry("PK")
        countriesPikerView.setCountryByName("Pakistan")
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
}

extension ForgotViewController :MRCountryPickerDelegate, UITextFieldDelegate {
    
    func getDataFromServer(completionHandler: @escaping (User)->()){
        
        let dbValues  = Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child("User Details").observe(.childAdded
            , with: { (snapshot) in
                
                print("The value are\n")
                let snapValue = snapshot.children
                print(snapshot.childrenCount)
                
                
                
                
        }) { (error) in
            print("The error is here \(error)")
        }
        
    }
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        countryCodeField.text = phoneCode
        //countryCodeField.text = name
    }
}


extension ForgotViewController{
    
    @objc func openRegister(){
        
    
        performSegue(withIdentifier: Keys.SegueName().registerMenuSegue, sender: nil)
    }
}



extension ForgotViewController {
    
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


extension ForgotViewController : StoryboardInitializable{}
