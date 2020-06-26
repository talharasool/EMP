//
//  Helper.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 19/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import Foundation
import UIKit



extension UIView{
    
    func setBackground(imageName : String ){
        
        let backgroundImage = UIImage(named: imageName)
        var imageView : UIImageView!
        imageView = UIImageView(frame: self.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = backgroundImage
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        
    }
}


enum Keys{
    
    struct AppKeys {
        static let googleMapKey = "AIzaSyAaJOYHFdAm-IRBnLtIrmHG38C3jN99-dU"
        
    }
    
    struct SegueName {
        let registerMenuSegue = "registerMenuSegue"
        let registerSegue = "registerSegue"
        let socialSegue = "socialSegue"
        let finalRegisterSegue = "finalRegisterSegue"
    }
    
    struct Xibs {
        let MenuXib = "MenuXib"
    }
    
    struct CellIds {
        let carCell = "carCell"
        let tripCell = "TripsTableViewCell"
    }
}


extension UIView{
    
     func setShadowOnView(cornerRadius : CGFloat){
        
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowRadius = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.3
        
    }
    
}



extension UINavigationController{
    
    func removeNavigationBarColor(){
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
}




public class Alert{
    
    public static func showLoginAlert(Message : String, title : String , window : UIViewController){
        
        let alert = UIAlertController(title: title, message: Message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        window.present(alert,animated: true)
        
    }
}



extension UINavigationController{
    
    func setUpTitleColor(){
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationBar.titleTextAttributes = textAttributes
        
    }
    //4F8F00
    func setUpBarColor(){
    self.navigationBar.barTintColor = UIColor.init(rgb: 0x4F8F00)
    }
    
    func setUpNavigationColor(color : UIColor){
      self.navigationBar.barTintColor = color
    }
}


extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}





extension UIViewController {
    public func add(asChildViewController viewController: UIViewController,to parentView:UIView) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        parentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    public func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}


