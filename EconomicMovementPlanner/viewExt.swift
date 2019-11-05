
//
//  ViewExt.swift
//  Boxeyi
//
//  Created by talha on 29/08/2019.
//  Copyright © 2019 Boxeyi. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    
    func getRoundedcorner(cornerRadius : CGFloat){
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        self.clipsToBounds = true
        
    }
    
    func roundWidth() -> CGFloat{
        return self.frame.width/2
    }
    
    func roundHeight() -> CGFloat {
        return self.frame.height/2
    }
    
    
    func  setShadowWithCornerRadius(_ corner : CGFloat, _ shadowRadius : CGFloat, _ shadowOpacity : CGFloat, _ shadowColor : UIColor,_ shadowX : CGFloat, _ ShadowY : CGFloat){
        
        self.layer.cornerRadius = corner
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        self.layer.shadowRadius = shadowRadius ////Here yout control blur
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: shadowX, height: ShadowY) //Here you control x and y
        self.layer.shadowOpacity = Float(shadowOpacity)
    }
    
    
    func giveShadow(cornerRadius : CGFloat){
        let shadow = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 3)
        let shadowBlurRadius: CGFloat = 2
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        
        self.layer.shadowColor = shadow.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowBlurRadius
        
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
    }
    
    
    
}
