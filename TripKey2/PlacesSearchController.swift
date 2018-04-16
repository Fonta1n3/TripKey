//
//  PlacesSearchController.swift
//  TripKey2
//
//  Created by Peter on 9/7/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

var placeViewPort:GMSCoordinateBounds!
var placeCoordinates:CLLocationCoordinate2D!
var placeName:String!
var placeLatitudeCenter:Double!
var placeLongitudeCenter:Double!

var jsonPlaceDataSuccesfullyParsed = Bool()

protocol LocatePlaceOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class PlacesSearchController: UITableViewController {

    var placeDictionaries:[Dictionary<String,String>]!
    var activityIndicator:UIActivityIndicatorView!
    var placeDictionary:Dictionary<String,String> = [:]
    var searchResults: [String]!
    var delegate: LocatePlaceOnTheMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad from SearchResultsController (City)")
        
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        /*
        if UserDefaults.standard.value(forKey: "placeDictionary") != nil {
            
            placeDictionary = UserDefaults.standard.object(forKey: "placeDictionary") as! Dictionary<String, String>
        }
        
        if UserDefaults.standard.value(forKey: "placeDictionaries") != nil {
            
            placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String, String>]
            
        } else {
            
            placeDictionaries = [[:]]
            
        }
        */
       
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
        
        self.dismiss(animated: true, completion: nil)
        let correctedAddress:String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.symbols)
        //print("THis is the corrected address \(correctedAddress)")
        let locationBias:String! = "\(cityLatitudeCenter),\(cityLongitudeCenter)"
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
                            //print("This is your dic \(jsonCitiesResult)")
                            
                            placeName = ((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["formatted_address"] as? String)!
                            //print("This is your country name \(cityName)")
                            
                            let lat = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            //print("This is latitude\(lat)")
                            let placeLatitudeCenter = lat
                            
                            let lon = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            //print("This is longitude\(lon)")
                            let placeLongitudeCenter = lon
                            
                            placeCoordinates = CLLocationCoordinate2D(latitude: placeLatitudeCenter, longitude: placeLongitudeCenter)
                            
                            
                            
                            
                            /*
                             let cityBoundsNELat = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double
                             print("This is cityBoundsNELat\(cityBoundsNELat)")
                             
                             let cityBoundsNELon = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double
                             print("This is cityBoundsNELon\(cityBoundsNELon)")
                             
                             let neBoundsCityCorner = CLLocationCoordinate2D(latitude: cityBoundsNELat!, longitude: cityBoundsNELon!)
                             
                             let cityBoundsSWLat = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double
                             print("This is cityBoundsSWLat\(cityBoundsSWLat)")
                             
                             let cityBoundsSWLon = ((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double
                             print("This is cityBoundsSWLon\(cityBoundsSWLon)")
                             
                             let swBoundsCityCorner = CLLocationCoordinate2D(latitude: cityBoundsSWLat!, longitude: cityBoundsSWLon!)
                             
                             cityBounds = GMSCoordinateBounds(coordinate: neBoundsCityCorner, coordinate: swBoundsCityCorner)
                             
                             
                             
                             print("this is your cityBounds\(cityBounds)")
                             */
                            
                            
                            let placeViewPortNELat = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            //print("This is cityViewPortNELat\(cityViewPortNELat)")
                            
                            let placeViewPortNELon = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            //print("This is cityViewPortNELon\(cityViewPortNELon)")
                            
                            let neViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortNELat, longitude: placeViewPortNELon)
                            
                            let placeViewPortSWLat = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            //print("This is cityViewPortSWLat\(cityViewPortSWLat)")
                            
                            let placeViewPortSWLon = (((((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            //print("This is cityViewPortSWLon\(cityViewPortSWLon)")
                            
                            let swViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortSWLat, longitude: placeViewPortSWLon)
                            
                            placeViewPort = GMSCoordinateBounds(coordinate: neViewPortPlaceCorner, coordinate: swViewPortPlaceCorner)
                            
                            //print("this is your cityViewPort\(cityViewPort)")
                            
                            
                            let placeID = ((((jsonCitiesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["place_id"] as? String)!
                            //print("This is your city ID \(cityID)")
                            
                            self.placeDictionary["Place Name"] = "\(placeName!)"
                            self.placeDictionary["Place ID"] = "\(placeID)"
                            
                            self.placeDictionary["Latitude Center"] = "\(placeLatitudeCenter)"
                            self.placeDictionary["Longitude Center"] = "\(placeLongitudeCenter)"
                            
                            self.placeDictionary["Viewport NE Latitude"] = "\(placeViewPortNELat)"
                            self.placeDictionary["Viewport NE Longitude"] = "\(placeViewPortNELon)"
                            self.placeDictionary["Viewport SW Latitude"] = "\(placeViewPortSWLat)"
                            self.placeDictionary["Viewport SW Longitude"] = "\(placeViewPortSWLon)"
                            
                            UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")

                            jsonCityDataSuccesfullyParsed = true
                            
                            self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row])
                            
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
    
    /*
    func pauseApp() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    func restoreApp() {
        
        activityIndicator.stopAnimating()
        
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
 */
    
}
