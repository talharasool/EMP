//
//  Models.swift
//  EconomicMovementPlanner
//
//  Created by talha on 04/08/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import Foundation


class User   {
    
    var  auth_id : String
    var  id : String
    var  image_URI : String
    var  isfborgmail : String
    var  name : String
    var  password : String
    var  phone : String
    
    init(data : [String : Any]) {
        
        auth_id =  data["auth_id"] as? String ?? ""
        id =  data["id"] as? String ?? " "
        image_URI =  data["image_URI"] as? String ?? ""
        isfborgmail =  data["isfborgmail"] as? String ?? ""
        name =  data["name"] as? String ?? ""
        password =  data["password"] as? String ??  ""
        phone =  data["phone"] as? String ??  ""
    }
}

class CarModel  : Codable  {
    
    var Car_Id : String
    var Image_Link : String?
    var Mileag : Double?
    var Model : String
    var Name : String
    
    
    init(data : [String : Any]) {
        
        Car_Id =  data["Car_Id"] as? String ?? ""
        Image_Link =  data["Image_Link"] as? String ?? "No Image "
      //  Mileag =  data["Mileage"] as? String ?? ""
        Model =  data["Model"] as? String ?? "No model"
        Name =  data["Name"] as? String ?? "No name"
       
    }
}


class CarDataModel  : Codable  {
    
    var Car_Id : String
    var Image_Link : String?
    var Mileag : String
    var Model : String
    var Name : String
    
    
    init(data : [String : Any]) {
        
        Car_Id =  data["Car_Id"] as? String ?? ""
        Image_Link =  data["Image_Link"] as? String ?? "No Image "
        Mileag =  data["Mileage"] as? String ?? ""
        Model =  data["Model"] as? String ?? "No model"
        Name =  data["Name"] as? String ?? "No name"
       
    }
}



class  AuthServices {
    
    static  let shared = AuthServices()
    
    let def = UserDefaults.standard
    
    var loginVal : Bool?{
        
        get{return def.value(forKey: AppIdentifiers.Defaults().login) as? Bool ?? false}
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().login)}
    }
    
    
    var userValue : String?{
        get{return def.value(forKey: AppIdentifiers.Defaults().loginObject) as? String ?? "" }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().loginObject)}
    }
    
    
    var carId : String? {
        get{return def.value(forKey: AppIdentifiers.Defaults().carIDKey) as? String ?? "" }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().carIDKey)}
    }
    
    
    var userObj : String? {
        
        get{return def.value(forKey: AppIdentifiers.Defaults().userObj) as? String ?? ""  }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().userObj)}
    }
    
    
    
    var userPassword : String? {
        
        get{return def.value(forKey: AppIdentifiers.Defaults().passKey) as? String ?? ""  }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().passKey)}
    }
    
    var userPhoneNumber : String?{
        
        get{return def.value(forKey: AppIdentifiers.Defaults().phoneKey) as? String ?? ""  }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().phoneKey)}
    }
    
    
    var username : String? {
        get{return def.value(forKey: AppIdentifiers.Defaults().userName) as? String ?? "" }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().userName)}
        
    }
    
    var userImage : String? {
        get{return def.value(forKey: AppIdentifiers.Defaults().userImage) as? String ?? "" }
        set{def.set(newValue, forKey: AppIdentifiers.Defaults().userImage)}
        
    }
    
    init() {
        
    }
    
    
    static func resetDef(){
      
        AuthServices.shared.carId = nil
        AuthServices.shared.loginVal = nil
        AuthServices.shared.userValue = nil
        AuthServices.shared.userImage = nil
        AuthServices.shared.userObj = nil
        AuthServices.shared.userPassword = nil
        AuthServices.shared.userPhoneNumber = nil
        
    }
    
    
}



enum AppIdentifiers{
    
    struct Defaults {
        let login = "Login"
        let loginObject = "userid"
        let userName = "userName"
        let userImage   = "userImage"
        let userObj = "userObj"
        let passKey = "passKey"
        let phoneKey = "phoneKey"
        let carIDKey = "carIDKey"
    }
}


class AllUsers : Codable{
    
    var array : [Profile]
}

class Profile : Codable   {
    
    var  auth_id : String?
    var  id : String?
    var  image_URl : String?
    var  isfborgmail : String?
    var  name : String?
    var  password : String?
    var  phone : String?
    
//    enum  Codingkeys : String , CodingKey {
//        case auth_id,id,image_URl,isfborgmail,name,password,phone
//    }
//    
//    required init(from decoder: Decoder) throws {
//        
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        auth_id = try container.decode(String.self, forKey: .auth_id)
//        image_URl = try container.decode(String.self, forKey: .image_URl)
//        isfborgmail = try container.decode(String.self, forKey: .isfborgmail)
//        name = try container.decode(String.self, forKey: .name)
//        password = try container.decode(String.self, forKey: .password)
//        phone = try container.decode(String.self, forKey: .phone)
//    }
}




