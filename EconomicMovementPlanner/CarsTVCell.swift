//
//  CarsTVCell.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 31/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class CarsTVCell: UITableViewCell {

    var carObject : CarModel?{
        didSet{
            
            self.averageLabel.text = "Average :" + carObject!.Mileag + "KM" ?? "Average : 0.0 "
             self.carNameLabel.text = carObject?.Name ?? "No Name"
           // print("The image link :   ", carObject?.Image_Link)
             self.carImageView.getImageFromUrl(imageURL: carObject?.Image_Link ?? "" , placeHolder: UIImage())
        }
    }
    
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImage(Url : String){
        carImageView.getImageFromUrl(imageURL: Url, placeHolder: UIImage())
    }
    
}
