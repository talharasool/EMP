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
    
    func getDataFromDataBase(_ clusterName : String, completion:@escaping (Any)->()){
        
        let val =  Database.database().reference().child(clusterName).observe(DataEventType.value, with: { (snapshot) in
            print("The snapShots are here", snapshot)
            completion(snapshot.value)
            
        }) { (error) in
            print(error)
            completion(error)
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
