//
//  RoutesTableViewCell.swift
//  EconomicMovementPlanner
//
//  Created by talha on 21/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SDWebImage

class RoutesTableViewCell: UITableViewCell {
    
    
    static let reuseIdentifier = "RoutesTableViewCell"
    
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var alpha_destinationLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
 
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var distanceView: UICircularProgressRing!
    @IBOutlet weak var timeView: UICircularProgressRing!
    @IBOutlet weak var fuelView: UICircularProgressRing!
    @IBOutlet weak var fuelLbl: UILabel!
    

    var model : tripList?{
        
        didSet{
            
            
            self.alpha_destinationLbl.text = self.model?.endpoint ?? ""
            self.destinationLbl.text = self.model?.startpoint ?? ""
            
            
            if let distance = self.model!.distance{
                print("The distance in model is here",distance)
                //  self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(distance/100) )
             //   self.distanceView.value = CGFloat(distance)
                
                if let n = NumberFormatter().number(from: distance) {
                    print("The fffff")
                    self.distanceView.value = CGFloat(n)
                }
                              
              //  self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(distance) )
            }else{print("Dis is nil")}
            
            if let time = self.model!.time {
                
                print("\n\nThe model time is here :: ", time)
                //  self.timeView.progressAnimation(duration: 0.1, toValue: CGFloat(time/100) )
                //self.timeView.progressAnimation(duration: 0.1, toValue: CGFloat(time/100) )
              //   self.timeView.value = CGFloat(time)
                
                if let n = NumberFormatter().number(from: time) {
                    print("The fffff")
                    self.timeView.value = CGFloat(n)
                }
            }else{print("Time is nil")}
            print("FF",self.model?.fuel ?? "0")
            if let fuel = self.model!.fuel{
                // self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(fuel/100) )
                print("\n\nThe fuel model is here :: ", fuel)
                //   self.fuelView.progressAnimation(duration: 0.1, toValue: 10 )
                let f  = Double(fuel)
                
                if let n = NumberFormatter().number(from: fuel) {
                    print("The fffff")
                    self.fuelView.value = CGFloat(n)
                }
                
                
             //   self.fuelView.progressAnimation(duration: 0.1, toValue: CGFloat(fuel) )
            }else{print("Fuel is nil")}
            
            if let distanceval = self.model!.distance{
                
                print("\n\nThe distancevalue is here :: ", distanceval)
                self.distanceLbl.text = distanceval//   String(format:"%.2f", distanceval)
            }
            if let fuelVal = self.model!.fuel{
                print("\n\nThe fuel is here :: ", fuelVal)
                self.fuelLbl.text =   fuelVal//String(format:"%.2f", fuelVal)
            }
            if let timeVal = self.model!.time{
                print("\n\nThe timeVAL is here :: ", timeVal)
                self.timeLbl.text = timeVal//String(format:"%.2f", timeVal)
            }
            
        }
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
//        self.carImgView.layer.cornerRadius =  self.carImgView.frame.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


