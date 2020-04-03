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
            
            
            if let distance = Int(self.model!.distance!){
                print("The distance in model is here",distance)
                //  self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(distance/100) )
                self.distanceView.value = CGFloat(distance)
              //  self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(distance) )
            }
            
            if let time = Int(self.model!.time ?? "0"){
                
                print("\n\nThe model time is here :: ", time)
                //  self.timeView.progressAnimation(duration: 0.1, toValue: CGFloat(time/100) )
                //self.timeView.progressAnimation(duration: 0.1, toValue: CGFloat(time/100) )
                 self.timeView.value = CGFloat(time)
            }
            if let fuel = Int(self.model!.fuel!){
                // self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(fuel/100) )
                print("\n\nThe fuel is here :: ", fuel)
                //   self.fuelView.progressAnimation(duration: 0.1, toValue: 10 )
                 self.fuelView.value = CGFloat(fuel)
             //   self.fuelView.progressAnimation(duration: 0.1, toValue: CGFloat(fuel) )
            }
            
            if let distanceval = self.model!.distance{
                print("\n\nThe distancevalue is here :: ", distanceval)
                self.distanceLbl.text = distanceval
            }
            if let fuelVal = self.model!.fuel{
                print("\n\nThe fuel is here :: ", fuelVal)
                self.fuelLbl.text = fuelVal
            }
            if let timeVal = self.model!.time{
                print("\n\nThe timeVAL is here :: ", timeVal)
                self.timeLbl.text = timeVal
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


