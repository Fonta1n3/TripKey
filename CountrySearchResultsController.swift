//
//  CountrySearchResultsController.swift
//  TripKey2
//
//  Created by Peter on 9/5/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

var countryViewPort:GMSCoordinateBounds!
var countryBounds:GMSCoordinateBounds!
var countryCoordinates:CLLocationCoordinate2D!
var countryName:String!

protocol LocateCountryOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class CountrySearchResultsController: UITableViewController {
    
    var searchResults: [String]!
    var delegate: LocateCountryOnTheMap!
    var countryDictionary:Dictionary<String,String>! = [:]
    var activityIndicator:UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad CountrySearchResultsController")
        
        
        
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
        self.dismiss(animated: true, completion: nil)
        
        let correctedAddress:String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.symbols)
            //print("THis is the corrected address \(correctedAddress)")
        
        if let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=" + (correctedAddress) + "&types=(regions)&key=AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw") {
            
            //print("!!!!!This is the URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonCountriesResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            countryName = ((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["formatted_address"] as? String)!
                            print("countryName = \(countryName)")
                            
                            let lat = ((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            
                            let countryLatitudeCenter = lat
                            
                            let lon = ((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            let countryLongitudeCenter = lon
                            
                            countryCoordinates = CLLocationCoordinate2D(latitude: countryLatitudeCenter, longitude: countryLongitudeCenter)


                            let countryBoundsNELat = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!

                            let countryBoundsNELon = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            
                            let neBoundsCountryCorner = CLLocationCoordinate2D(latitude: countryBoundsNELat, longitude: countryBoundsNELon)

                            let countryBoundsSWLat = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            
                            let countryBoundsSWLon = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            
                            let swBoundsCountryCorner = CLLocationCoordinate2D(latitude: countryBoundsSWLat, longitude: countryBoundsSWLon)
                            
                            countryBounds = GMSCoordinateBounds(coordinate: neBoundsCountryCorner, coordinate: swBoundsCountryCorner)
                            
                            let countryViewPortNELat = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            
                            let countryViewPortNELon = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            
                            let neViewPortCountryCorner = CLLocationCoordinate2D(latitude: countryViewPortNELat, longitude: countryViewPortNELon)
                             
                            let countryViewPortSWLat = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            
                            let countryViewPortSWLon = (((((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            
                            let swViewPortCountryCorner = CLLocationCoordinate2D(latitude: countryViewPortSWLat, longitude: countryViewPortSWLon)
                             
                            countryViewPort = GMSCoordinateBounds(coordinate: neViewPortCountryCorner, coordinate: swViewPortCountryCorner)
 
                            let countryID = ((((jsonCountriesResult)["results"] as? NSArray)?[0] as? NSDictionary)?["place_id"] as? String)!
                            
                            self.countryDictionary["Country Name"] = "\(countryName!)"
                            self.countryDictionary["Country ID"] = "\(countryID)"
                            
                            self.countryDictionary["Latitude Center"] = "\(countryLatitudeCenter)"
                            self.countryDictionary["Longitude Center"] = "\(countryLongitudeCenter)"
                            
                            self.countryDictionary["Bounds NE Latitude"] = "\(countryBoundsNELat)"
                            self.countryDictionary["Bounds NE Longitude"] = "\(countryBoundsNELon)"
                            self.countryDictionary["Bounds SW Latitude"] = "\(countryBoundsSWLat)"
                            self.countryDictionary["Bounds SW Longitude"] = "\(countryBoundsSWLon)"
                            
                            self.countryDictionary["Viewport NE Latitude"] = "\(countryViewPortNELat)"
                            self.countryDictionary["Viewport NE Longitude"] = "\(countryViewPortNELon)"
                            self.countryDictionary["Viewport SW Latitude"] = "\(countryViewPortSWLat)"
                            self.countryDictionary["Viewport SW Longitude"] = "\(countryViewPortSWLon)"
                            
                            print("countryDictionary = \(self.countryDictionary)")
                            
                            UserDefaults.standard.set(self.countryDictionary, forKey: "countryDictionary")
                            
                            self.delegate.locateWithLongitude(lon, andLatitude: lat , andTitle: self.searchResults[indexPath.row])

                            

                        } catch {
                            
                            print("JSon processing failed")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
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




