//
//  DatabaseService.swift
//  EconomicMovementPlanner
//
//  Created by talha on 04/08/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase

class FIRService{
    
    static var shared = FIRService()
    
    
    func getDataFromDataBaseWithEventCurrentUser(_ clusterName : String, completion:@escaping (Any)->()){
        
        if let id  = AuthServices.shared.userValue{
            
            let val =  Database.database().reference().child(clusterName).child(id).observe(DataEventType.value, with: { (snapshot) in
                print("The snapShots are here", snapshot)
                completion(snapshot.value)
                
            }) { (error) in
                print(error)
                completion(error)
            }
        }
        
    }
    
    
    func getDataFromDataBaseWithEvent(_ clusterName : String, completion:@escaping (Any)->()){
        
        let val =  Database.database().reference().child(clusterName).observe(DataEventType.childChanged, with: { (snapshot) in
            print("The snapShots are here", snapshot)
            completion(snapshot.value)
            
        }) { (error) in
            print(error)
            completion(error)
        }
    }
    
    func getDataFromDataBase(_ clusterName : String, completion:@escaping (Any)->()){
        
        if let userID = AuthServices.shared.userValue{
            print("The current user id is here",userID)
            let val =  Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child(clusterName).child(userID).queryOrderedByKey().observe(DataEventType.value, with: { (snapshot) in
                print("The snapShots are here", snapshot.value,snapshot.childrenCount)
                
                var carArray : [CarModel] = []
                print(snapshot.children.allObjects)
                if let snap = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    print(snap)
                    
                    for (index,val) in snap.enumerated(){
                        print("values")
                        print(val)
                        print(val.value)
                        
                        do {
                            let model = try FirebaseDecoder().decode(CarModel.self, from: val.value)
                            carArray.append(model)
                            
                            
                        } catch let error {
                            print(error)
                            completion(error)
                        }
                        
                        
                    }
                    
                    completion(carArray)
                }else{
                    completion("Unable to fetch data")
                }
                
                
                
            }) { (error) in
                print(error)
                completion(error)
            }
            
            
        }else{
            print("\n\n UserID Is nil in service \n\n")
        }
        
    }
    
    
    func getCarDetailsDataFromDataBase(_ clusterName : String, completion:@escaping (Any)->()){
        
        if let userID = AuthServices.shared.userValue{
            print("The current user id is here",userID)
            let val =  Database.database().reference(fromURL: "https://tactile-timer-238411.firebaseio.com/").child(clusterName).child(userID).observe(DataEventType.value, with: { (snapshot) in
                print("The snapShots are here", snapshot)
                //    completion(snapshot.chi)
                
            }) { (error) in
                print(error)
                completion(error)
            }
            
            
        }else{
            print("\n\n UserID Is nil in service \n\n")
        }
        
    }
    
    
    func  getUserDataFromDB(_ clusterName : String, completion:@escaping (Profile, Int)->()){
        
        Database.database().reference().child(clusterName).observe(.value) { (snapshot) in
            
            guard let value = snapshot.value else { return }
            do {
                let person = try FirebaseDecoder().decode(Profile.self, from: value)
                
            } catch let error {
                print(error)
            }
        }
    }
}
