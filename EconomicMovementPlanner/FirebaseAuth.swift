//
//  FirebaseAuth.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 13/06/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import Foundation
import FirebaseAuth


class FirAuth{
    
    public static var authHandler = FirAuth()
    
    private init(){
        print("Fir Authentication")
    }
    deinit {
        print("The auth class de initialize")
    }
    

    func phoneAuthService(_ phoneNumber : String , completion : @escaping (Any)->()){
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (result, error) in
            
            guard error == nil else{
                print("\n\nError in geeting code from firebase \(error?.localizedDescription)\n\n")
                completion(error?.localizedDescription)
                return}
            
            print("\n\n The result after phone authentication..\(String(describing: result)) \n\n")
            
        }
    }

}
