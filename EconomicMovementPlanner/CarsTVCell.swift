//
//  CarsTVCell.swift
//  EconomicMovementPlanner
//
//  Created by Talha on 31/05/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class CarsTVCell: UITableViewCell {
    
    
    
    @IBOutlet weak var deleteBtnOutlet: UIButton!
     @IBOutlet weak var editBtnOutlet: UIButton!
     @IBOutlet weak var cancelBtnOutlet: UIButton!
    
    
    var deleteCompletion : (()->())?
    var editCompletion : (()->())?
    
    
    @IBOutlet weak var editActionView: UIView!
    var carObject : CarModel?{
        didSet{
            
            self.averageLabel.text = "Average :" + String(describing: carObject!.Mileage!) + " KM" ?? "Average : 0.0 "
             self.carNameLabel.text = carObject?.Name ?? "No Name"
           // print("The image link :   ", carObject?.Image_Link)
             self.carImageView.getImageFromUrl(imageURL: carObject?.Image_Link ?? "" , placeHolder: UIImage())
        }
    }
    
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBOutlet weak var starImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.cancelBtnOutlet.addTarget(self, action: #selector(showView(_:)), for: .touchUpInside)
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap(_:))))
        
        self.deleteBtnOutlet.addTarget(self, action: #selector(handleDelete(_:)), for: .touchUpInside)
        
        self.editBtnOutlet.addTarget(self, action: #selector(handleEdit(_:)), for: .touchUpInside)
        hideView(0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImage(Url : String){
        carImageView.getImageFromUrl(imageURL: Url, placeHolder: UIImage())
    }
    
    
    @objc func showView(_ sender : UIButton){
        
        self.hideView(0)
        
    }
    
    @objc func handleLongTap(_ sender : UILongPressGestureRecognizer){
        
        if (sender.state == UIGestureRecognizer.State.began){
         
            self.backgroundColor = UIColor.lightGray
            
            hideView(1)
        }
    }
    
    
    @objc func handleEdit(_ sender : UIButton){
          
          guard let comp = editCompletion else {
                  return
          }
          
          comp()
      }
    
    @objc func handleDelete(_ sender : UIButton){
        
        guard let comp = deleteCompletion else {
                return
        }
        
        comp()
    }
    
}

extension CarsTVCell{
    
    
    func hideView(_ opq : CGFloat){
        
        UIView.transition(with: self.editActionView, duration: 0.2, options: [.transitionCrossDissolve,.curveEaseIn], animations: {
            self.editActionView.alpha = opq
            
            if opq == 1{
                self.backgroundColor = UIColor.lightGray
            }else{
                self.backgroundColor = UIColor.white
            }
        }, completion: nil)
        
    }
    
}
