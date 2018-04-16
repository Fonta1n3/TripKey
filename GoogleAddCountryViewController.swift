//
//  GoogleAddCountryViewController.swift
//  TripKey2
//
//  Created by Peter on 9/5/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class GoogleAddCountryViewController: UIViewController, UISearchBarDelegate, LocateCountryOnTheMap, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
    var apikey:String = "AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw"

    var latitude:String!
    var longitude:String!
    
    var userTappedCoordinates:CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var userLongpressedCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var countryDictionaries:[Dictionary<String,String>]!
    var countryDictionary:Dictionary<String,String>! = [:]
    var activityIndicator:UIActivityIndicatorView!
    var countryName:String!

    var searchResultController:CountrySearchResultsController!
    var resultsArray = [String]()
    var googleMapsView: GMSMapView!
    var manager: CLLocationManager!
    var userLocation = CLLocationCoordinate2D()
    
    var selectedCountry:Dictionary<String,String>!
    
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet var addCountryLabel: UIBarButtonItem!
    @IBOutlet var addCountryTitle: UINavigationBar!
    
    @IBAction func goHome(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
        
    }
    
    @IBAction func showSearchController(_ sender: AnyObject) {
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }

    @IBAction func goToMainMenu(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "mainMenu") as UIViewController; self.present(viewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad from GoogleAddCountryViewController")
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gesture:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        if UserDefaults.standard.object(forKey: "countryDictionaries") != nil {
            
            countryDictionaries = UserDefaults.standard.object(forKey: "countryDictionaries") as! [Dictionary<String,String>]
            
        } else {
            
            countryDictionaries = [[:]]
            
        }
        
        
        
        print("countryDictionaries = \(countryDictionaries)")
        
        manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        getUserLocation()
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            let searchController = UISearchController(searchResultsController: self.searchResultController)
            searchController.searchBar.delegate = self
            self.present(searchController, animated: true, completion: nil)
            
        })
        */
        
        
        
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.left:
                
                print("swiped left")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCity") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                
            case UISwipeGestureRecognizerDirection.right:
                
                print("swiped right")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.down:
                
                print("swiped down")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
            case UISwipeGestureRecognizerDirection.up:
                
                print("swiped up")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "mainMenu") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
            default:
                break
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocations : CLLocation = locations[0]
        let latitude = userLocations.coordinate.latitude
        let longitude = userLocations.coordinate.longitude
        //print(locations)
        self.userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //goToUserLocation()
    }

    func getUserLocation () {
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func goToUserLocation () {
        
            self.googleMapsView.isMyLocationEnabled = true
            self.googleMapsView.delegate = self
            //print("This is the Users Location\(userLocation)")
            self.googleMapsView.animate(toLocation: userLocation)
            manager.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.googleMapsView =  GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultController = CountrySearchResultsController()
        searchResultController.delegate = self
        
        mapView(googleMapsView, didTapAt: userTappedCoordinates)
        //mapView(googleMapsView, didLongPressAt: userLongpressedCoordinates)
        
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async() { () -> Void in
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.title = self.countryName
            marker.map = self.googleMapsView
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                
                if UserDefaults.standard.value(forKey: "countryDictionary") != nil {
                    
                    self.countryDictionary = UserDefaults.standard.object(forKey: "countryDictionary") as! Dictionary<String, String>
                    
                    }
                
                let alert = UIAlertController(title: "Add \(self.countryDictionary["Country Name"]!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    
                    self.countryDictionaries.append(self.countryDictionary)
                    
                    if self.countryDictionaries[0] == [:] {
                        
                        self.countryDictionaries.remove(at: 0)

                        
                    }
                    
                    
                    UserDefaults.standard.set(self.countryDictionary, forKey: "countryDictionary")
                    
                    print("tripDictionary = \(self.countryDictionary)")
                    
                    UserDefaults.standard.set(self.countryDictionaries, forKey: "countryDictionaries")
                    
                    print("countryDictionaries = \(self.countryDictionaries)")
                    
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCity") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                    
                    self.countryDictionary.removeValue(forKey: "Country Name")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) ID")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Latitude Center")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Longitude Center")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Bounds NE Latitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Bounds NE Longitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Bounds SW Latitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Bounds SW Longitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Viewport NE Latitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Viewport NE Longitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Viewport SW Latitude")
                    self.countryDictionary.removeValue(forKey: "\(self.countryName) Viewport SW Longitude")
                    
                    UserDefaults.standard.set(self.countryDictionary, forKey: "countryDictionary")
                    
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCountry") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            })
        
        }
            
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.region
        let placesClient = GMSPlacesClient()
        
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (results, error:Error?) -> Void in
            
            self.resultsArray.removeAll()
            
            if results == nil {
                
                return
                
            }
            
            for result in results!{
                
                if let result = result as? GMSAutocompletePrediction{
                    
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        googleMapsView.delegate = self
        print(coordinate.latitude)
        print(coordinate.longitude)
        
        self.latitude = String(coordinate.latitude)
        self.longitude = String(coordinate.longitude)

        
        
        //let position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        //let marker = GMSMarker(position: position)
        //marker.title = "Hello World"
        //marker.map = mapView
        
        getAddressForLatLng(latitude: latitude, longitude: longitude)
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        googleMapsView.delegate = self
        print(coordinate.latitude)
        print(coordinate.longitude)
    }
    
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        
        if let url = NSURL(string: "\(baseUrl)latlng=\(latitude),\(longitude)&key=\(apikey)") {
            
            
            let data = NSData(contentsOf: url as URL)
            let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            if let results = json["results"] as? NSArray {
                
                if results.count > 1 {
                    
                    for result in results {
                        
                        var country:String!
                        var route:String!
                        var streetNumber:String!
                        var neighborhood:String!
                        var city:String!
                        var postalCode:String!
                        var intersection:String!
                        var street_address:String!
                        var natural_feature:String!
                        var airport:String!
                        var park:String!
                        
                        var administrative_area_level_1:String!
                        //indicates a first-order civil entity below the country level. Within the United States, these administrative levels are states. Not all nations exhibit these administrative levels. In most cases, administrative_area_level_1 short names will closely match ISO 3166-2 subdivisions and other widely circulated lists; however this is not guaranteed as our geocoding results are based on a variety of signals and location data.
                        
                        var administrative_area_level_2:String!
                        //indicates a second-order civil entity below the country level. Within the United States, these administrative levels are counties. Not all nations exhibit these administrative levels.
                        
                        var administrative_area_level_3:String!
                        //indicates a third-order civil entity below the country level. This type indicates a minor civil division. Not all nations exhibit these administrative levels.
                        
                        var administrative_area_level_4:String!
                        //indicates a fourth-order civil entity below the country level. This type indicates a minor civil division. Not all nations exhibit these administrative levels.
                        
                        var administrative_area_level_5:String!
                        //indicates a fifth-order civil entity below the country level. This type indicates a minor civil division. Not all nations exhibit these administrative levels.
                        
                        var sublocality:String!
                        var sublocality_level_1:String!
                        var sublocality_level_3:String!
                        var sublocality_level_4:String!
                        var sublocality_level_5:String!
                        // indicates a first-order civil entity below a locality. For some locations may receive one of the additional types: sublocality_level_1 to sublocality_level_5. Each sublocality level is a civil entity. Larger numbers indicate a smaller geographic area.
                        
                        var postal_town:String!
                        //indicates a grouping of geographic areas, such as locality and sublocality, used for mailing addresses in some countries.
                        
                        var locality:String!
                        //indicates an incorporated city or town political entity
                        
                        var colloquial_area:String!
                        //indicates a commonly-used alternative name for the entity.
                        
                        var ward:String!
                        //indicates a specific type of Japanese locality, to facilitate distinction between multiple locality components within a Japanese address.
                        
                        var premise:String!
                        //indicates a named location, usually a building or collection of buildings with a common name
                        
                        var subpremise:String!
                        //indicates a first-order entity below a named location, usually a singular building within a collection of buildings with a common name
                        
                        var point_of_interest:String!
                        //indicates a named point of interest. Typically, these "POI"s are prominent local entities that don't easily fit in another category, such as "Empire State Building" or "Statue of Liberty."
                        
                        var political:String!
                        //indicates a political entity. Usually, this type indicates a polygon of some civil administration.
                        
                        var floor:String!
                        //indicates the floor of a building address.
                        
                        var establishment:String!
                        //typically indicates a place that has not yet been categorized.
                        
                        var parking:String!
                        //indicates a parking lot or parking structure.
                        
                        var post_box:String!
                        //indicates a specific postal box.
                        
                        var room:String!
                        //indicates the room of a building address.
                        
                        if let addressTypeDescriptor = (((((result as! NSDictionary)["address_components"]) as? NSArray)?[0] as? NSDictionary)?["types"] as? NSArray)?[0] as? String {
                            
                            if addressTypeDescriptor == "country" {
                                
                                self.countryName = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("result = \(result)")
                                print("country = \(country)")
                                
                                let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                                print("lat = \(lat)")
                                
                                let countryLatitudeCenter = lat
                                print("countryLatitudeCenter = \(countryLatitudeCenter)")
                                
                                
                                let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                                
                                
                                let countryLongitudeCenter = lon
                                print("countryLongitudeCenter = \(countryLongitudeCenter)")
                                
                                
                                countryCoordinates = CLLocationCoordinate2D(latitude: countryLatitudeCenter, longitude: countryLongitudeCenter)
                                
                                
                                let countryBoundsNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                                print("countryBoundsNELat = \(countryBoundsNELat)")
                                
                                
                                print("countryBoundsNELat = \(countryBoundsNELat)")
                                
                                
                                let countryBoundsNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                                print("countryBoundsNELon = \(countryBoundsNELon)")
                                
                                
                                let neBoundsCountryCorner = CLLocationCoordinate2D(latitude: countryBoundsNELat, longitude: countryBoundsNELon)
                                
                                let countryBoundsSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                                print("countryBoundsSWLat = \(countryBoundsSWLat)")
                                
                                
                                let countryBoundsSWLon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["bounds"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                                print("countryBoundsSWLon = \(countryBoundsSWLon)")
                                
                                
                                let swBoundsCountryCorner = CLLocationCoordinate2D(latitude: countryBoundsSWLat, longitude: countryBoundsSWLon)
                                
                                countryBounds = GMSCoordinateBounds(coordinate: neBoundsCountryCorner, coordinate: swBoundsCountryCorner)
                                
                                let countryViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                                print("countryViewPortNELat = \(countryViewPortNELat)")
                                
                                
                                let countryViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                                print("countryViewPortNELon = \(countryViewPortNELon)")
                                
                                
                                let neViewPortCountryCorner = CLLocationCoordinate2D(latitude: countryViewPortNELat, longitude: countryViewPortNELon)
                                
                                let countryViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                                print("countryViewPortSWLat = \(countryViewPortSWLat)")
                                
                                
                                let countryViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                                print("countryViewPortSWLon = \(countryViewPortSWLon)")
                                
                                
                                let swViewPortCountryCorner = CLLocationCoordinate2D(latitude: countryViewPortSWLat, longitude: countryViewPortSWLon)
                                
                                countryViewPort = GMSCoordinateBounds(coordinate: neViewPortCountryCorner, coordinate: swViewPortCountryCorner)
                                
                                let countryID = ((result as? NSDictionary)?["place_id"] as? String)!
                                
                                print("countryID = \(countryID)")
                                
                                self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.countryName!)
                                
                                DispatchQueue.main.async {
                                    
                                    let alert = UIAlertController(title: "Add \(self.countryName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                        
                                        self.countryDictionary["Country Name"] = "\(self.countryName!)"
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
                                        
                                        self.countryDictionaries.append(self.countryDictionary)
                                        
                                        if self.countryDictionaries[0] == [:] {
                                            
                                            self.countryDictionaries.remove(at: 0)
                                            
                                            
                                        }
                                        
                                        print("countryDictionaries = \(self.countryDictionaries)")
                                        
                                        UserDefaults.standard.set(self.countryDictionary, forKey: "countryDictionary")
                                        
                                        UserDefaults.standard.set(self.countryDictionaries, forKey: "countryDictionaries")
                                        
                                        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCity") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                        
                                    }))
                                    
                                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                                
                            } else if addressTypeDescriptor == "street_number" {
                                
                                streetNumber = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("streetNumber = \(streetNumber)")
                                
                            } else if addressTypeDescriptor == "neighborhood" {
                                
                                neighborhood = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("neighborhood = \(neighborhood)")
                                
                            } else if addressTypeDescriptor == "locality" {
                                
                                city = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("city = \(city)")
                                
                            } else if addressTypeDescriptor == "postal_code" {
                                
                                postalCode = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("postalCode = \(postalCode)")
                                
                            } else if addressTypeDescriptor == "route" {
                                
                                route = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("route = \(route)")
                                
                            } else if addressTypeDescriptor == "administrative_area_level_1" {
                                
                                administrative_area_level_1 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("administrative_area_level_1 = \(administrative_area_level_1)")
                                
                                
                            } else if addressTypeDescriptor == "administrative_area_level_2" {
                                
                                administrative_area_level_2 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("administrative_area_level_2 = \(administrative_area_level_2)")
                                
                            } else if addressTypeDescriptor == "administrative_area_level_3" {
                                
                                administrative_area_level_3 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("administrative_area_level_3 = \(administrative_area_level_3)")
                                
                            } else if addressTypeDescriptor == "administrative_area_level_4" {
                                
                                administrative_area_level_4 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("administrative_area_level_4 = \(administrative_area_level_4)")
                                
                            } else if addressTypeDescriptor == "administrative_area_level_5" {
                                
                                administrative_area_level_5 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("administrative_area_level_5 = \(administrative_area_level_5)")
                                
                            } else if addressTypeDescriptor == "political" {
                                
                                political = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("political = \(political)")
                                
                            } else if addressTypeDescriptor == "postal_town" {
                                
                                postal_town = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("postal_town = \(postal_town)")
                                
                            } else if addressTypeDescriptor == "locality" {
                                
                                locality = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("locality = \(locality)")
                                
                            } else if addressTypeDescriptor == "sublocality" {
                                
                                sublocality = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("sublocality = \(sublocality)")
                                
                            } else if addressTypeDescriptor == "sublocality_level_1" {
                                
                                sublocality_level_1 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("sublocality_level_1 = \(sublocality_level_1)")
                                
                            } else if addressTypeDescriptor == "sublocality_level_2" {
                                
                                //sublocality_level_2 = ((result as! NSDictionary)["formatted_address"]) as? String
                                //print("sublocality_level_2 = \(administrative_area_level_5)")
                                
                            } else if addressTypeDescriptor == "sublocality_level_3" {
                                
                                sublocality_level_3 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("sublocality_level_3 = \(sublocality_level_3)")
                                
                            } else if addressTypeDescriptor == "sublocality_level_4" {
                                
                                sublocality_level_4 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("sublocality_level_4 = \(sublocality_level_4)")
                                
                            } else if addressTypeDescriptor == "sublocality_level_5" {
                                
                                sublocality_level_5 = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("sublocality_level_5 = \(sublocality_level_5)")
                                
                            } else if addressTypeDescriptor == "colloquial_area" {
                                
                                colloquial_area = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("colloquial_area = \(colloquial_area)")
                                
                            } else if addressTypeDescriptor == "premise" {
                                
                                premise = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("premise = \(premise)")
                                
                            } else if addressTypeDescriptor == "subpremise" {
                                
                                subpremise = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("subpremise = \(subpremise)")
                                
                            } else if addressTypeDescriptor == "natural_feature" {
                                
                                natural_feature = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("natural_feature = \(natural_feature)")
                                
                            } else if addressTypeDescriptor == "airport" {
                                
                                airport = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("airport = \(airport)")
                                
                            } else if addressTypeDescriptor == "park" {
                                
                                park = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("park = \(park)")
                                
                            } else if addressTypeDescriptor == "point_of_interest" {
                                
                                point_of_interest = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("point_of_interest = \(point_of_interest)")
                                
                            } else if addressTypeDescriptor == "intersection" {
                                
                                intersection = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("intersection = \(intersection)")
                                
                            } else if addressTypeDescriptor == "street_address" {
                                
                                street_address = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("street_address = \(street_address)")
                                
                            } else if addressTypeDescriptor == "ward" {
                                
                                ward = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("ward = \(ward)")
                                
                            } else if addressTypeDescriptor == "ward" {
                                
                                ward = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("ward = \(ward)")
                                
                            } else if addressTypeDescriptor == "floor" {
                                
                                floor = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("floor = \(floor)")
                                
                            } else if addressTypeDescriptor == "establishment" {
                                
                                establishment = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("establishment = \(establishment)")
                                
                            } else if addressTypeDescriptor == "parking" {
                                
                                parking = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("parking = \(parking)")
                                
                            } else if addressTypeDescriptor == "post_box" {
                                
                                post_box = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("post_box = \(post_box)")
                                
                            } else if addressTypeDescriptor == "room" {
                                
                                room = ((result as! NSDictionary)["formatted_address"]) as? String
                                print("room = \(room)")
                                
                            } else {
                                
                                print("addressType = \(addressTypeDescriptor)")
                                
                            }
                            
                        } else {
                            
                            print("Unable to parse addressTypeDescriptor")
                            
                        }
                        
                    }
                    
                }
            }

        }
    }
    
    func locateWithLongitudeByTap(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async() { () -> Void in
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.title = self.countryName
            marker.map = self.googleMapsView
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
            
            
            
        }
        
    }

}


