//
//  NewListTVCell.swift
//  EconomicMovementPlanner
//
//  Created by talha on 22/08/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class NewListTVCell: UITableViewCell {

    @IBOutlet weak var headerLbl: UILabel!
   
    @IBOutlet weak var switchOutlet: UISwitch!
    
    @IBOutlet weak var directionLbl: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.image = #imageLiteral(resourceName: "maps-and-flags").withRenderingMode(.alwaysTemplate)
        self.imageView?.tintColor = UIColor.green
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
