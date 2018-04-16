//
//  SearchResultsController.swift
//  TripKey2
//
//  Created by Peter on 8/29/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


var cityCoordinates = CLLocationCoordinate2D()
var cityViewPort = GMSCoordinateBounds()
var cityLatitudeCenter = CLLocationDegrees()
var cityLongitudeCenter = CLLocationDegrees()
var cityName:String!

var jsonCityDataSuccesfullyParsed = Bool()


protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String, placeId: String, index: Int)
}

class SearchResultsController: UITableViewController {
    
    var placeDictionary:Dictionary<String,String>!
    var placeDictionaries = [Dictionary<String,String>]()
    var cityDictionary:Dictionary<String,String> = [:]
    var activityIndicator:UIActivityIndicatorView!
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    var countryDictionary:Dictionary<String,String>!
    var countryName:String!
    var countryLatitudeCenter:String!
    var countryLongitudeCenter:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad from SearchResultsController (City)")
        
        self.searchResults = Array()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
       /*
        
       if UserDefaults.standard.value(forKey: "countryDictionary") != nil {
            
            countryDictionary = UserDefaults.standard.object(forKey: "countryDictionary") as! Dictionary<String, String>
        }
        
        if UserDefaults.standard.value(forKey: "cityDictionary") != nil {
            
            cityDictionary = UserDefaults.standard.object(forKey: "cityDictionary") as! Dictionary<String, String>
            
            cityName = cityDictionary["City Name"]!
        }
        */
        
        
        //addPlacesTitle.title = "Add Places to \(cityName!)"
        
        //countryName = countryDictionary["Country Name"]
        //countryLatitudeCenter = countryDictionary["\(self.countryName) Latitude Center"]
        //countryLongitudeCenter = countryDictionary["\(self.countryName) Longitude Center"]

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.placeDictionaries.removeAll()
        
        var countryVar = ""
        var cityVar = ""
        
        
        self.dismiss(animated: true, completion: nil)
        let correctedAddress:String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.symbols)
        //print("THis is the corrected address \(correctedAddress)")
        let locationBias:String! = "\(countryLatitudeCenter),\(countryLongitudeCenter)"
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=" + (correctedAddress) + "&location=" + (locationBias) + "&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw")
        //print("!!!!!This is the URL: \(url)")
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            do {
                if error != nil {
                    print(error as Any)
                } else {
                    if let urlContent = data {
                        do {
                            
                            let jsonCitiesResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            print("This is your dic \(jsonCitiesResult)")
                            
                            if let countryCheck = ((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["address_components"] as? NSArray) {
                                
                                for country in countryCheck {
                                    
                                    if let types = ((country as? NSDictionary)?["types"]) as? NSArray {
                                    print("types = \(String(describing: types))")
                                    
                                    for type in types {
                                        
                                        let type = type as? String
                                        
                                        if type == "country" {
                                            
                                            if let countryName = (country as? NSDictionary)?["long_name"] as? String {
                                                
                                              print("country = \(countryName)")
                                                countryVar = countryName
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        if type == "locality" {
                                            
                                            if let cityName = (country as? NSDictionary)?["long_name"] as? String {
                                                
                                                print("city = \(cityName)")
                                                cityVar = cityName
                                                
                                            }
                                            
                                        }
                                    }
                                        
                                    }
                                }
                                
                                print("countryCheck = \(countryCheck)")
                            }
                            
                            cityName = ((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["formatted_address"] as? String)!
                             print("This is your country name \(cityName)")
                             
                             let lat = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                             //print("This is latitude\(lat)")
                            let cityLatitudeCenter = lat
                            
                            UserDefaults.standard.set(lat, forKey: "selectedPlaceLatitude")
                             
                             let lon = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                             //print("This is longitude\(lon)")
                             let cityLongitudeCenter = lon
                            
                            UserDefaults.standard.set(lat, forKey: "selectedPlaceLongitude")
                            
                             cityCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                             
                            let cityViewPortNELat = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                             //print("This is cityViewPortNELat\(cityViewPortNELat)")
                             
                             let cityViewPortNELon = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                             //print("This is cityViewPortNELon\(cityViewPortNELon)")
                             
                             let neViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortNELat, longitude: cityViewPortNELon)
                             
                             let cityViewPortSWLat = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                             //print("This is cityViewPortSWLat\(cityViewPortSWLat)")
                             
                             let cityViewPortSWLon = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                             //print("This is cityViewPortSWLon\(cityViewPortSWLon)")
                             
                             let swViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortSWLat, longitude: cityViewPortSWLon)
                             
                             cityViewPort = GMSCoordinateBounds(coordinate: neViewPortCityCorner, coordinate: swViewPortCityCorner)
                             
                             //print("this is your cityViewPort\(cityViewPort)")
                             
                             
                             let cityID = ((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["place_id"] as? String)!
                             print("This is your city ID \(cityID)")
                            UserDefaults.standard.set(cityID, forKey: "placeId")
                            /*
                            self.cityDictionary["City Name"] = "\(cityName!)"
                            self.cityDictionary["City ID"] = "\(cityID)"
                            
                            self.cityDictionary["Latitude Center"] = "\(cityLatitudeCenter)"
                            self.cityDictionary["Longitude Center"] = "\(cityLongitudeCenter)"
                            
                            self.cityDictionary["Viewport NE Latitude"] = "\(cityViewPortNELat)"
                            self.cityDictionary["Viewport NE Longitude"] = "\(cityViewPortNELon)"
                            self.cityDictionary["Viewport SW Latitude"] = "\(cityViewPortSWLat)"
                            self.cityDictionary["Viewport SW Longitude"] = "\(cityViewPortSWLon)"
                            */
                            //UserDefaults.standard.set(self.cityDictionary, forKey: "cityDictionary")
 
                            
                            self.placeDictionary = [
                                
                                "Place Latitude":"\(lat)",
                                "Place Longitude":"\(lon)",
                                "Place ID":"\(cityID)",
                                "Distance":"",
                                "Index":"\(0)",
                                "Place Type":"N/A",
                                "Place Country":"\(countryVar)",
                                "Place City":"\(cityVar)"
                                
                            ]
                            
                            self.placeDictionaries.append(self.placeDictionary)
                            
                            UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                            
                             jsonCityDataSuccesfullyParsed = true
                            
                            self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row], placeId: cityID, index: 0)
                            
                        } catch {
                            print("JSon processing failed")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    
}
