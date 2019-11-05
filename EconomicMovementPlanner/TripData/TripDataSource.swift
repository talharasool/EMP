//
//  TripDataSource.swift
//  EconomicMovementPlanner
//
//  Created by talha on 15/09/2019.
//  Copyright © 2019 EconomicMovementPlanner. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class TripDataSource:  NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    let array : [String] = ["Talha", "ALi", "Ahmed"]
    
    var listData : [TripData] = []
    var curretCar : CarModel!
    fileprivate var cellName  : UITableViewCell!
    
    override init() {
        super.init()
        
        print("Data Source Is Calling")
        //getDataFromFirebase()
        
    }
    
    
    func getDataFromFirebase(tableView : UITableView){
        
        
        //        var listData : [TripData] = []
        //           var curretCar : CarModel!
        print(AuthServices.shared.userValue, AuthServices.shared.carId)
        
        if let userID =   AuthServices.shared.userValue ,let  carID =  AuthServices.shared.carId{
            let dbRef =   Database.database().reference().child("Routes").child( userID)
            let dbRefForCar =   Database.database().reference().child("Car Details").child( userID)
            let carvalue = dbRefForCar.child(carID).observe(.value) { (snap) in
                
                print(snap.value)
                
                if let data = snap.value as? [String : Any]{
                    
                    let temp = CarModel(data: data)
                    
                    print(temp.Car_Id)
                    
                    self.curretCar = temp
                    
                    let values = dbRef.child( carID).observe(.value) { (snap) in
                        
                        print(snap.value)
                        
                        
                        if let newData = snap.value{
                            
                            if let parser = newData as? [String : Any]{
                                print(parser.count)
                                
                                for data in parser{
                                    
                                    do {
                                        let model = try FirebaseDecoder().decode(TripData.self, from: data.value)
                                        
                                        print(model.trip_date)
                                        self.listData.append(model)
                                        
                                    } catch let error {
                                        print(error)
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    print("\nThe new count is\n")
                                    print(self.listData.first?.list.count)
                                    print("\n")
                                    tableView.reloadData()
                                }
                                
                            }else{
                                print("Parser is not working")
                            }
                        }
                    }
                }
            }
        }else{
            print("\n\n Error in getting data ")
        }
    }
    
    
    func registerCells(with tableView: UITableView) {
        let nib = UINib(nibName: "TripsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TripsTableViewCell.reuseIdentifier)
        
        self.getDataFromFirebase(tableView: tableView)
        
    }
    
    
}


extension TripDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TripsTableViewCell.reuseIdentifier, for: indexPath) as? TripsTableViewCell{
            cell.car = self.curretCar
            cell.model = self.listData[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
}


class TripValues : Codable {
    
    var  value : String?
    var  trip  : [TripData]?
    
    
    enum CodingKeys : String, CodingKey {
        
        case value
        case trip
    }
    
    
    
    required init(from decoder: Decoder) throws {
        
        let container  =  try? decoder.container(keyedBy: CodingKeys.self)
        value = try? container?.decode(String.self, forKey: .value) ?? "NO Value"
        trip = try? container?.decode([TripData].self, forKey: .trip)
        
    }
}


class tripList : Codable{
    
    var  date_record:String?
    var   distance:String?
    var   endpoint:String?
    var   fuel:String?
    var   startpoint:String?
    var   time: String?
    
    enum CodingKeys : String, CodingKey {
        
        case date_record
        case distance
        case endpoint
        case fuel
        case startpoint
        case time
    }
    
    required init(from decoder: Decoder) throws {
        
        let container  =  try? decoder.container(keyedBy: CodingKeys.self)
        date_record = try? container?.decode(String.self, forKey: .date_record) ?? "NO Value"
        distance = try? container?.decode(String.self, forKey: .distance) ?? "NO Value"
        endpoint = try? container?.decode(String.self, forKey: .endpoint) ?? "NO Value"
        fuel = try? container?.decode(String.self, forKey: .fuel) ?? "NO Value"
        startpoint = try? container?.decode(String.self, forKey: .startpoint) ?? "NO Value"
        time = try? container?.decode(String.self, forKey: .time) ?? "NO Value"
    }
    
}

class TripData : Codable {
    
    var  trip_date : String?
    var  trip_endpoint : String?
    var  trip_startpoint : String?
    var  trip_totaldistance : String?
    var  trip_totalfuel : String?
    var  trip_totlatime : String?
    var list : [tripList?]
    
    enum CodingKeys : String, CodingKey {
        
        case trip_date
        case trip_endpoint
        case trip_startpoint
        case trip_totaldistance
        case trip_totalfuel
        case trip_totlatime
        case list
    }
    
    
    
    required init(from decoder: Decoder) throws {
        
        let container  =  try? decoder.container(keyedBy: CodingKeys.self)
        trip_date = try? container?.decode(String.self, forKey: .trip_date) ?? "NO Value"
        trip_endpoint = try? container?.decode(String.self, forKey: .trip_endpoint) ?? "NO Value"
        trip_startpoint = try? container?.decode(String.self, forKey: .trip_startpoint) ?? "NO Value"
        trip_totaldistance = try? container?.decode(String.self, forKey: .trip_totaldistance) ?? "NO Value"
        trip_totalfuel = try? container?.decode(String.self, forKey: .trip_totalfuel) ?? "NO Value"
        trip_totlatime = try? container?.decode(String.self, forKey: .trip_totlatime) ?? "NO Value"
        list = try! container?.decodeIfPresent([tripList].self, forKey: .list) ?? []
    }
}



//        let newQuery = dbRef.queryOrderedByKey().queryEqual(toValue: AuthServices.shared.carId).observe(.value) { (snapShot) in
//
//            print("The SnapShot For TripVC new")
//        //print(snapShot.value)
//            print("\n\n")
//
//
//
//            if let data = snapShot.value as? NSDictionary {
//
//                print(data.allValues)
//
//                for val in data.allValues{
//
//                }
//
//            }else{
//                print("Unable to prse data")
//
//            }
//        }
//

//        let result = dbRef.observe(.childAdded) { (snapShot) in
//
//            print("The SnapShot For TripVC")
//            print(snapShot.value)
//            print("\n\n")
//
//
//            if let arr = snapShot.value as? NSArray{
//                print(arr)
//            }
//
//            if let data = snapShot.value as? NSDictionary {
//
//                do {
//                    let model = try FirebaseDecoder().decode([TripData].self, from: data.allValues)
//                     print(model.count)
//                } catch let error {
//                    print(error)
//                }
//
//            }else{
//                print("Unable to prse data")
//
//            }
//
//        }


//let quer2 = dbRef.qu
//        let query = dbRef.queryEqual(toValue: AuthServices.shared.userValue).observe(.value, with: { (snapShot) in
//
//
//        }) { (error) in
//             print("Err In reloading Data", error)
//        }

//        Database.database().reference().child("Routes").observe(.value, with: { (snapShot) in
//            print("The SnapShot For TripVC")
//            print(snapShot)
//            print("\n\n")
//
//        }) { (error) in
//
//
//        }


struct  tripServerData : Codable {
    
    var  date_record:String
    var  distance:String
    var  endpoint:String
    var  fuel:String
    var  startpoint:String
    var  time: String
    
    
    func valDict()->[String : Any]{
        
        return ["date_record" : date_record,"distance": distance,"endpoint" : endpoint,"fuel" : fuel,"startpoint":startpoint,"time":time]
    }
}
