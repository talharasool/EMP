//
//  ImageExt.swift
//  Epicdemo
//
//  Created by talha on 29/07/2019.
//  Copyright © 2019 GetSetGo. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage


extension UIImageView{
    
    func getImageFromUrl(imageURL : String , placeHolder : UIImage){
        
        
        self.sd_setImage(with: URL(string: imageURL)!) { (downloadedImage, err, type, url) in
            
            
            if err != nil{ return}
            
            if let download = downloadedImage{
                
                print("\n\n")
                print("The type of caching is here :: > ", type.rawValue)
                print("\n\n")
                
                if type == .none
                {
                    self.alpha = 0
                    UIView.transition(with: self, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        self.image = download
                        self.alpha = 1
                        
                    }, completion: nil)
                }
            
            }else{
                self.image = placeHolder
            }
       
        }
        
    }
}
