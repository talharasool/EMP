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
    
    @IBOutlet weak var fuelLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
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
        self.avgLbl.text = String(describing:  self.car?.Mileage ?? "0.0" )
        self.carImgView.getImageFromUrl(imageURL: self.car?.Image_Link ?? "", placeHolder: UIImage())
            
        }
    }
    
    var model : TripData?{
        
        didSet{
            
            self.dateLbl.text = self.model?.trip_date
            self.alpha_destinationLbl.text = self.model?.trip_endpoint
            self.destinationLbl.text = self.model?.trip_startpoint
            let dis = self.model?.trip_totaldistance?.floatValue
            
            if let distance = dis{
                print("The real distance value",distance)
               // self.distanceView.style = .bordered(width: 2, color: UIColor.blue)
                 self.distanceLabel.text = String(describing: distance)
                  self.distanceView.value = CGFloat(distance)
            }
          
            
            if  let time = self.model?.trip_totlatime?.floatValue{
                 print("The real time value",time)
                 self.timeLabel.text = String(describing: time)
                 self.timeView.value = CGFloat(time)
            }
           
            
            if let fuel = self.model?.trip_totalfuel?.floatValue{
                 print("The real fuel value",fuel)
                self.fuelLabel.text = String(describing: fuel)
                self.fuelView.value = CGFloat(fuel)
            }
            
            
           
            
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
    let startPoint : String?
    let lat : Double?
    let long : Double?
    var isSelect : Bool?
    var isCompleted : Bool?
    var distance : Double?
    var timeAndDate : Double?
    
}




func getTodayString() -> String{
    
    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    
    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second
    
    let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE, d MMM yyyy HH:mm:ss Z"
    let availabletoDateTime = dateFormatter.string(from: date)
    return availabletoDateTime
    
}


func getDateFromUNIX(myDate : Date) -> String{
    
    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    
    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second
    
    let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE, d MMM yyyy HH:mm:ss Z"
    dateFormatter.timeZone = .current
    let availabletoDateTime = dateFormatter.string(from: myDate)
    
    return availabletoDateTime
    
}


extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        //  dateFormatter.locale = .current//Locale(identifier: "en_US")
        let dateFormatter = DateFormatter()
       // dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
       // dateFormatter.timeZone = TimeZone.current.secondsFromGMT()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EE, d MMM yyyy HH:mm:ss Z"
        
        return dateFormatter.string(from: date)
    }
}
