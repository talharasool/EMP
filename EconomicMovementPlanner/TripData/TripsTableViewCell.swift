//
//  TripsTableViewCell.swift
//  EconomicMovementPlanner
//
//  Created by talha on 15/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SDWebImage

class TripsTableViewCell: UITableViewCell {
    
    
    static let reuseIdentifier = "TripsTableViewCell"
    
    @IBOutlet weak var alpha_destinationLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
    @IBOutlet weak var avgLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var distanceView: UICircularProgressRing!
    @IBOutlet weak var timeView: UICircularProgressRing!
    @IBOutlet weak var fuelView: UICircularProgressRing!
    
    
    var car : CarModel?{
        
        didSet{
            
        print(self.car?.Image_Link)
        self.nameLbl.text = self.car?.Name ?? ""
        self.avgLbl.text = self.car?.Mileag ?? ""
        self.carImgView.getImageFromUrl(imageURL: self.car?.Image_Link ?? "", placeHolder: UIImage())
            
        }
    }
    
    var model : TripData?{
        
        didSet{
            
            self.dateLbl.text = self.model?.trip_date
            self.alpha_destinationLbl.text = self.model?.trip_endpoint
            self.destinationLbl.text = self.model?.trip_startpoint
            let dis = self.model?.trip_totaldistance?.floatValue
            self.distanceView.value = CGFloat(dis!)
            
            let time = self.model?.trip_totlatime?.floatValue
            self.timeView.value = CGFloat(time!)
            
            let fuel = self.model?.trip_totalfuel?.floatValue
            self.distanceView.value = CGFloat(fuel!)
            
            print(self.distanceView.value)
            
            
            
        }
    }
    
    
    @IBOutlet weak var carImgView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
   
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        self.carImgView.layer.cornerRadius =  self.carImgView.frame.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

struct CoordinatesValue{
    
    let lineString : String?
    let title : String?
    let lat : Double?
    let long : Double?
    var isSelect : Bool?
    var isCompleted : Bool?
    
}

