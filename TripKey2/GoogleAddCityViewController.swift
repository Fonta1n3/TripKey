//
//  GoogleAddCityViewController.swift
//  TripKey2
//
//  Created by Peter on 8/29/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class GoogleAddCityViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap, GMSMapViewDelegate {
    
    var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
    var apikey:String = "AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw"
    
    var latitude:String!
    var longitude:String!
    
    var countryDictionaries:[Dictionary<String,String>]!
    var cityDictionaries:[Dictionary<String,String>]!
    var countryDictionary:Dictionary<String,String>!
    var cityDictionary:Dictionary<String,String>!
    var cityName:String!
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    @IBOutlet var mapViewContainer: UIView!
    var activityIndicator:UIActivityIndicatorView!
    var countryName:String!
    var selectedCountry:Dictionary<String,String>!
    
    var userTappedCoordinates:CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var userLongpressedCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
   
    @IBAction func showSearchController(_ sender: AnyObject) {
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func home(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
        
    }
   
    @IBOutlet var addPlacesTitle: UINavigationBar!
    
    
    @IBAction func addCity(_ sender: AnyObject) {
        
        if jsonCityDataSuccesfullyParsed == true {
            
            let alert = UIAlertController(title: "Add more destinations?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
                alert.addAction(UIAlertAction(title: "Add More Cities", style: .default, handler: { (action) in

                }))
            
                alert.addAction(UIAlertAction(title: "Add Another Country", style: .default, handler: { (action) in
                
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCountry") as UIViewController; self.present(viewController, animated: true, completion: nil)
                }))
            
                alert.addAction(UIAlertAction(title: "Add Places to \(cityDictionary["City Name"]!)", style: .default, handler: { (action) in
                
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddPlaces") as UIViewController; self.present(viewController, animated: true, completion: nil)
                }))
            
                alert.addAction(UIAlertAction(title: "Nope all finished", style: .default, handler: { (action) in
                
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                    
                }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "No Place Selected", message: "Please search for and select a valid Place", preferredStyle: UIAlertControllerStyle.alert)
            
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                }))
            
                alert.addAction(UIAlertAction(title: "Add another country", style: .default, handler: { (action) in
                
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCountry") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                }))
            
                alert.addAction(UIAlertAction(title: "Skip adding cities", style: .default, handler: { (action) in
                
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func goToMainMenu(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "mainMenu") as UIViewController; self.present(viewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad from GoogleAddCityViewController")
        
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
        
        if UserDefaults.standard.value(forKey: "countryDictionary") != nil {
            
            countryDictionary = UserDefaults.standard.object(forKey: "countryDictionary") as! Dictionary<String, String>
            
        } else {
    
            countryDictionary = [:]
            
        }
        
        if UserDefaults.standard.value(forKey: "cityDictionary") != nil {
            
            cityDictionary = UserDefaults.standard.object(forKey: "cityDictionary") as! Dictionary<String, String>
            
        } else {
            
            cityDictionary = [:]
            
        }
    
        if UserDefaults.standard.value(forKey: "cityDictionaries") != nil {
            
            cityDictionaries = UserDefaults.standard.object(forKey: "cityDictionaries") as! [Dictionary<String, String>]
            
        } else {
    
        cityDictionaries = [[:]]
            
        }
        
        if UserDefaults.standard.value(forKey: "countryDictionaries") != nil {
            
            countryDictionaries = UserDefaults.standard.object(forKey: "countryDictionaries") as! [Dictionary<String, String>]
            
            //addPlacesTitle.topItem!.title = "Add Cities to \(self.countryDictionaries[]["Country Name"])"

            
        }
        
        if UserDefaults.standard.object(forKey: "selectedCountry") != nil {
            
            selectedCountry = UserDefaults.standard.object(forKey: "selectedCountry") as! Dictionary<String,String>
            
            addPlacesTitle.topItem!.title = ("Add cities to \(selectedCountry["Country Name"]!)")
            
        }
        
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.left:
                
                print("swiped left")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddPlaces") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                
            case UISwipeGestureRecognizerDirection.right:
                
                print("swiped right")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCountry") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.googleMapsView =  GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
        
        mapView(googleMapsView, didTapAt: userTappedCoordinates)

    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String, placeId: String, index: Int) {
        
        DispatchQueue.main.async() { () -> Void in
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.title = self.cityName
            marker.map = self.googleMapsView
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(cityViewPort, withPadding: 5.0))
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                
                if UserDefaults.standard.value(forKey: "cityDictionary") != nil {
                    
                    self.cityDictionary = UserDefaults.standard.object(forKey: "cityDictionary") as! Dictionary<String, String>
                    
                }
                
                let alert = UIAlertController(title: "Add \(self.cityDictionary["City Name"]!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    
                    print("yes")
                    
                    self.cityDictionaries.append(self.cityDictionary)
                    
                    if self.cityDictionaries[0] == [:] {
                        
                        self.cityDictionaries.remove(at: 0)
                        
                    }
                    
                    
                    
                    UserDefaults.standard.set(self.cityDictionary, forKey: "cityDictionary")
                    
                    print("cityDictionary = \(self.cityDictionary)")

                    
                    UserDefaults.standard.set(self.cityDictionaries, forKey: "cityDictionaries")

                    print("cityDictionaries = \(self.cityDictionaries)")

                    
                    //self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
                    
                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddPlaces") as UIViewController; self.present(viewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                    
                    print("no")
                    
                    self.cityDictionary.removeValue(forKey: "City Name")
                    self.cityDictionary.removeValue(forKey: "City ID")
                    self.cityDictionary.removeValue(forKey: "Latitude Center")
                    self.cityDictionary.removeValue(forKey: "Longitude Center")
                    self.cityDictionary.removeValue(forKey: "Viewport NE Latitude")
                    self.cityDictionary.removeValue(forKey: "Viewport NE Longitude")
                    self.cityDictionary.removeValue(forKey: "Viewport SW Latitude")
                    self.cityDictionary.removeValue(forKey: "Viewport SW Longitude")
                    
                    UserDefaults.standard.set(self.cityDictionary, forKey: "cityDictionary")
                    
                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            })
            
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        let filter = GMSAutocompleteFilter()
        
        filter.type = GMSPlacesAutocompleteTypeFilter.geocode
        
        let placesClient = GMSPlacesClient()
        
         placesClient.autocompleteQuery(searchText, bounds: countryBounds, filter: filter) { (results, error:Error?) -> Void in
            
            self.resultsArray.removeAll()
            
            if results == nil {
                
                return
                
            }
            
            for result in results!{
                
                if let result = result as? GMSAutocompletePrediction {
                    
                    self.resultsArray.append(result.attributedFullText.string)
                }
                
            }
            
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        googleMapsView.delegate = self
        print(coordinate.latitude)
        print(coordinate.longitude)
        
        self.latitude = String(coordinate.latitude)
        self.longitude = String(coordinate.longitude)
        getAddressForLatLng(latitude: latitude, longitude: longitude)

    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        googleMapsView.delegate = self
        print(coordinate.latitude)
        print(coordinate.longitude)
    }
    
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
        let url = NSURL(string: "\(baseUrl)latlng=\(latitude),\(longitude)&key=\(apikey)")
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
        if let results = json["results"] as? NSArray {
            
            print("results = \(results)")
            print("results count = \(results.count)")
            
            
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
                    var sublocality_level_2:String!
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
                            
                            country = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("country = \(country)")
                            
                            
                        } else if addressTypeDescriptor == "street_number" {
                            
                            streetNumber = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("streetNumber = \(streetNumber)")
                            
                        } else if addressTypeDescriptor == "neighborhood" {
                            
                            neighborhood = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("neighborhood = \(neighborhood)")
                            
                        } else if addressTypeDescriptor == "locality" {
                            
                            city = ((result as! NSDictionary)["formatted_address"]) as? String
                            
                            print("city = \(city)")
                            
                            self.cityName = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("result = \(result)")
                            print("city = \(self.cityName)")
                            
                            let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            print("lat = \(lat)")
                            
                            let cityLatitudeCenter = lat
                            print("cityLatitudeCenter = \(cityLatitudeCenter)")
                            
                            
                            let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            
                            let cityLongitudeCenter = lon
                            print("cityLongitudeCenter = \(cityLongitudeCenter)")
                            
                            
                            cityCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                            
                            let cityViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            print("cityViewPortNELat = \(cityViewPortNELat)")
                            
                            
                            let cityViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            print("cityViewPortNELon = \(cityViewPortNELon)")
                            
                            
                            let neViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortNELat, longitude: cityViewPortNELon)
                            
                            let cityViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            print("cityViewPortSWLat = \(cityViewPortSWLat)")
                            
                            
                            let cityViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            print("cityViewPortSWLon = \(cityViewPortSWLon)")
                            
                            
                            let swViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortSWLat, longitude: cityViewPortSWLon)
                            
                            cityViewPort = GMSCoordinateBounds(coordinate: neViewPortCityCorner, coordinate: swViewPortCityCorner)
                            
                            let cityID = ((result as? NSDictionary)?["place_id"] as? String)!
                            
                            print("cityID = \(cityID)")
                            
                            self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.cityName!)
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add \(self.cityName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    self.cityDictionary["City Name"] = "\(self.cityName!)"
                                    self.cityDictionary["City ID"] = "\(cityID)"
                                    
                                    self.cityDictionary["Latitude Center"] = "\(cityLatitudeCenter)"
                                    self.cityDictionary["Longitude Center"] = "\(cityLongitudeCenter)"
                                    
                                    self.cityDictionary["Viewport NE Latitude"] = "\(cityViewPortNELat)"
                                    self.cityDictionary["Viewport NE Longitude"] = "\(cityViewPortNELon)"
                                    self.cityDictionary["Viewport SW Latitude"] = "\(cityViewPortSWLat)"
                                    self.cityDictionary["Viewport SW Longitude"] = "\(cityViewPortSWLon)"
                                    
                                    print("cityDictionary = \(self.cityDictionary)")
                                    
                                    self.cityDictionaries.append(self.cityDictionary)
                                    
                                    if self.cityDictionaries[0] == [:] {
                                        
                                        self.cityDictionaries.remove(at: 0)
                                        
                                        
                                    }
                                    
                                    print("cityDictionaries = \(self.cityDictionaries)")
                                    
                                    UserDefaults.standard.set(self.cityDictionary, forKey: "cityDictionary")
                                    
                                    UserDefaults.standard.set(self.cityDictionaries, forKey: "cityDictionaries")
                                    
                                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddPlaces") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                    
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                    
                                    
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }

                            
                        } else if addressTypeDescriptor == "postal_code" {
                            
                            postalCode = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("postalCode = \(postalCode)")
                            
                        } else if addressTypeDescriptor == "route" {
                            
                            route = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("route = \(route)")
                            
                        } else if addressTypeDescriptor == "administrative_area_level_1" {
                            
                            administrative_area_level_1 = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("administrative_area_level_1 = \(administrative_area_level_1)")
                            /*
                            self.cityName = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("result = \(result)")
                            print("city = \(self.cityName)")
                            
                            let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            print("lat = \(lat)")
                            
                            let cityLatitudeCenter = lat
                            print("cityLatitudeCenter = \(cityLatitudeCenter)")
                            
                            
                            let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            
                            let cityLongitudeCenter = lon
                            print("cityLongitudeCenter = \(cityLongitudeCenter)")
                            
                            
                            cityCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                            
                            let cityViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            print("cityViewPortNELat = \(cityViewPortNELat)")
                            
                            
                            let cityViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            print("cityViewPortNELon = \(cityViewPortNELon)")
                            
                            
                            let neViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortNELat, longitude: cityViewPortNELon)
                            
                            let cityViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            print("cityViewPortSWLat = \(cityViewPortSWLat)")
                            
                            
                            let cityViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            print("cityViewPortSWLon = \(cityViewPortSWLon)")
                            
                            
                            let swViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortSWLat, longitude: cityViewPortSWLon)
                            
                            cityViewPort = GMSCoordinateBounds(coordinate: neViewPortCityCorner, coordinate: swViewPortCityCorner)
                            
                            let cityID = ((result as? NSDictionary)?["place_id"] as? String)!
                            
                            print("cityID = \(cityID)")
                            
                            self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.cityName!)
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add \(self.cityName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    self.cityDictionary["City Name"] = "\(self.cityName!)"
                                    self.cityDictionary["City ID"] = "\(cityID)"
                                    
                                    self.cityDictionary["Latitude Center"] = "\(cityLatitudeCenter)"
                                    self.cityDictionary["Longitude Center"] = "\(cityLongitudeCenter)"
                                    
                                    self.cityDictionary["Viewport NE Latitude"] = "\(cityViewPortNELat)"
                                    self.cityDictionary["Viewport NE Longitude"] = "\(cityViewPortNELon)"
                                    self.cityDictionary["Viewport SW Latitude"] = "\(cityViewPortSWLat)"
                                    self.cityDictionary["Viewport SW Longitude"] = "\(cityViewPortSWLon)"
                                    
                                    
                                    let neViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortNELat, longitude: cityViewPortNELon)
                                    let swViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortSWLat, longitude: cityViewPortSWLon)
                                    
                                    cityViewPort = GMSCoordinateBounds(coordinate: neViewPortCityCorner, coordinate: swViewPortCityCorner)
                                    
                                    countryViewPort = cityViewPort
                                    
                                    print("cityDictionary = \(self.cityDictionary)")
                                    
                                    self.cityDictionaries.append(self.cityDictionary)
                                    
                                    if self.cityDictionaries[0] == [:] {
                                        
                                        self.cityDictionaries.remove(at: 0)
                                        
                                        
                                    }
                                    
                                    print("cityDictionaries = \(self.cityDictionaries)")
                                    
                                    UserDefaults.standard.set(self.cityDictionary, forKey: "cityDictionary")
                                    
                                    UserDefaults.standard.set(self.cityDictionaries, forKey: "cityDictionaries")
                                    
                                    //self.googleMapsView.animate(with: GMSCameraUpdate.fit(countryViewPort, withPadding: 5.0))
                                    
                                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCity") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                    
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                    
                                    
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }

                            
                          */
                        } 
                        
                        else if addressTypeDescriptor == "administrative_area_level_2" {
                            
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
                            
                            sublocality_level_2 = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("sublocality_level_2 = \(administrative_area_level_5)")
                            
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
    
    func locateWithLongitudeByTap(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async() { () -> Void in
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.title = self.cityName
            marker.map = self.googleMapsView
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(cityViewPort, withPadding: 5.0))
            
            
            
        }
        
    }

}
