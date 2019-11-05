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
    @IBOutlet weak var distanceView: CircularProgressView!
    @IBOutlet weak var timeView: CircularProgressView!
    @IBOutlet weak var fuelView: CircularProgressView!
    @IBOutlet weak var fuelLbl: UILabel!
    

    var model : tripList?{
        
        didSet{
            
           
            self.alpha_destinationLbl.text = self.model?.endpoint ?? ""
            self.destinationLbl.text = self.model?.startpoint ?? ""
            
            //let dis = self.model?.trip_totaldistance?.floatValue
            //self.distanceView.value = CGFloat(dis!)
            
            // let time = self.model?.trip_totlatime?.floatValue
            //  self.timeView.value = CGFloat(time!)
            
            //let fuel = self.model?.trip_totalfuel?.floatValue
            // self.distanceView.value = CGFloat(fuel!)
        
            if let distance = Int(self.model!.distance!){
                self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(distance/100) )
            }
            
            if let time = Int(self.model!.time!){
                self.timeView.progressAnimation(duration: 0.1, toValue: CGFloat(time/100) )
            }
            if let fuel = Int(self.model!.fuel!){
               // self.distanceView.progressAnimation(duration: 0.1, toValue: CGFloat(fuel/100) )
                self.fuelView.progressAnimation(duration: 0.1, toValue: 10 )
            }
           
            if let distanceval = self.model!.distance{
                self.distanceLbl.text = distanceval
                       }
            if let fuelVal = self.model!.distance{
            self.fuelLbl.text = fuelVal
                   }
            if let timeVal = self.model!.distance{
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


