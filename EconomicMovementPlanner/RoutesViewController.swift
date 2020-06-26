//
//  RoutesViewController.swift
//  EconomicMovementPlanner
//
//  Created by talha on 21/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit

class RoutesViewController: UIViewController {
    
    @IBOutlet weak var fuelLbl: UILabel!
    @IBOutlet weak var timeinminlbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var routeDetails: UILabel!
    @IBOutlet weak var backOutlet: UIButton!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
         customCompletion!()
    }
    
    deinit {
    }
    //LISTING DATA
    var listData : [TripData] = []
    var curretCar : CarModel!
    
    let identifier = RoutesTableViewCell.reuseIdentifier
    
    //OUTLETS
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var disLbl: UILabel!
    @IBOutlet weak var fulLbl: UILabel!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var avgLbl: UILabel!
    
    //IMG VIEW
    @IBOutlet weak var selectedImgView: UIImageView!
    @IBOutlet weak var carImgView: UIImageView!
    var newCount  = 0
    var customCompletion : (()->())?
    //View
    @IBOutlet weak var fuelView: CircularProgressView!
    @IBOutlet weak var timeView: CircularProgressView!
    @IBOutlet weak var distanceView: CircularProgressView!
    
    var deletePlanetIndexPath: NSIndexPath? = nil
    
    //Table View
    @IBOutlet weak var detailTV: UITableView!{
        didSet{
            self.detailTV.delegate = self
            self.detailTV.dataSource = self
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.listData.count)
        self.setDataOnLabels()
        print(listData.count)
        
        self.routeDetails.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.Route.rawValue, comment: "")
        self.backOutlet.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.back.rawValue, comment: ""), for: .normal)
        
//        fulLbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.fuel.rawValue, comment: "")
//        timeinminlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.tmn.rawValue, comment: "")
//        disLbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: LocalStrings.dkm.rawValue, comment: "")
//        
        print("The list of new data is here\n\n",self.listData.count)
       
        self.detailTV.tableFooterView = UIView(frame: .zero)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.detailTV.register(nib, forCellReuseIdentifier: identifier)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.distanceView.getRoundedcorner(cornerRadius: self.distanceView.roundWidth())
//        self.timeView.getRoundedcorner(cornerRadius: self.timeView.roundWidth())
//        self.fuelView.getRoundedcorner(cornerRadius: self.fuelView.roundWidth())
//
//        self.distanceView.layer.borderColor = UIColor.green.cgColor
//        self.timeView.layer.borderColor = UIColor.green.cgColor
//        self.fuelView.layer.borderColor = UIColor.green.cgColor
//
//        self.fuelView.layer.borderWidth = 2
//        self.fuelView.layer.borderColor = UIColor.green.cgColor
//        self.fuelView.layer.borderColor = UIColor.green.cgColor
        if let data = self.listData.first{
            
            print("\n\nTrip Data is here",data.trip_totaldistance,data.trip_totalfuel,data.trip_totlatime)
            
            if let distance = data.trip_totaldistance?.floatValue{
                disLbl.text = String(describing: distance)
                print("\n\n The distance value is after calculation :", distance)
                distanceView.progressAnimation(duration: 1, toValue:CGFloat(distance/1000))
            }else{print("Err in cal distance")}
            
            
            if let fuel = data.trip_totalfuel?.floatValue{
                
                fuelLbl.text = String(describing: fuel)
                print("\n\n The fuel value is after calculation :", fuel)
                fuelView.progressAnimation(duration: 1, toValue:CGFloat(fuel/100))
            }else{print("Err in fuel distance")}
            
            
            
            if let time = data.trip_totlatime?.floatValue{
                
                timeLbl.text = String(describing: time)
                print("\n\n The time value is after calculation :", time)
                timeView.progressAnimation(duration: 1, toValue:CGFloat(time/100))
            }else{print("Err in fuel distance")}
            
            // fuelView.progressAnimation(duration: 5, toValue: 0.2)
            //  timeView.progressAnimation(duration: 5, toValue: 0.3)
        }
        
        
    }
    
    @IBAction func dissmissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RoutesViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = listData.first?.list.count{
           // print("\n\nThe list count is here",count)
            return count
        }
        return  0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell  = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RoutesTableViewCell{
            
            //   cell.model?.list
            
            cell.model = self.listData[0].list[indexPath.row]
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 242
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            deletePlanetIndexPath = indexPath
//            let planetToDelete = planets[indexPath.row]
//            confirmDelete(planetToDelete)
//        }
//    }
    
    
    
    
    
    
}


extension RoutesViewController{
    
    func setDataOnLabels(){
        
        if let url = URL(string: self.curretCar.Image_Link!){
            self.carImgView.sd_setImage(with: url, completed: nil)
        }
        
        //Setting Car Information On label
        self.carNameLbl.text = self.curretCar.Name
        self.avgLbl.text = "Average of Car \(self.curretCar.Mileage)"
        
    }
}



class CircularProgressView: UIView {
    // First create two layer properties
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: frame.width/2.0, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 5.0
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circleLayer)
        layer.addSublayer(progressLayer)
    }
    func progressAnimation(duration: TimeInterval,toValue: CGFloat) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = toValue
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}
