//
//  GoogleAddPlacesViewController.swift
//  TripKey2
//
//  Created by Peter on 9/7/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

//var cityName:String!
//var countryName:String!

class GoogleAddPlacesViewController: UIViewController, UISearchBarDelegate, LocatePlaceOnTheMap, GMSMapViewDelegate {
    
    var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
    var apikey:String = "AIzaSyCL5ZBnRQyLflgDj5uSvG-x35oEJTsphkw"
    
    var latitude:String!
    var longitude:String!
    
    var placeDictionaries:[Dictionary<String,String>]!
    var placeDictionary:Dictionary<String,String> = [:]
    var cityDictionary:Dictionary<String,String>!
    
    var activityIndicator:UIActivityIndicatorView!
    var searchResultController:PlacesSearchController!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    @IBOutlet var mapViewContainer: UIView!
    var placeName:String!
    var selectedCity:Dictionary<String,String>!
    var selectedPlace:Dictionary<String,String>!

    
    @IBOutlet var addTitle: UINavigationItem!
    
    var userTappedCoordinates:CLLocationCoordinate2D! = CLLocationCoordinate2D()
    var userLongpressedCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    @IBAction func home(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
        
    }
    
    @IBAction func showSearchController(_ sender: AnyObject) {
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func addPlaces(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func goToMainMenu(_ sender: AnyObject) {
        
        let viewController = self.storyboard! .instantiateViewController(withIdentifier: "mainMenu") as UIViewController; self.present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is ViewDidLoad from GoogleAddPlacesViewController")
        
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

        if UserDefaults.standard.value(forKey: "placeDictionaries") != nil {
            
            placeDictionaries = UserDefaults.standard.object(forKey: "placeDictionaries") as! [Dictionary<String, String>]
            
        } else {
            
            placeDictionaries = [[:]]
            
        }
        
        if UserDefaults.standard.value(forKey: "cityDictionary") != nil {
            
            cityDictionary = UserDefaults.standard.object(forKey: "cityDictionary") as! Dictionary<String, String>
            
        }
        
        //cityName = cityDictionary["City Name"]!

        //addTitle.title = "Add Places to \(cityName!)"
        
        if UserDefaults.standard.object(forKey: "selectedCity") != nil {
            
            selectedCity = UserDefaults.standard.object(forKey: "selectedCity") as! Dictionary<String,String>
            
            addTitle.title = ("Add places to \(selectedCity["City Name"]!)")
            
            
            
        }
        
        if UserDefaults.standard.object(forKey: "selectedPlace") != nil {
            
            selectedPlace = UserDefaults.standard.object(forKey: "selectedPlace") as! Dictionary<String,String>
            
            addTitle.title = ("Add places to \(selectedPlace["Place Name"]!)")
            
            //let viewport = selectedPlace["Place Viewport"]
            
            //cityViewPort = GMSCoordinateBounds(viewport)
            
            let cityViewPortNELat = Double(selectedPlace["Viewport NE Latitude"]!)
            let cityViewPortNELon = Double(selectedPlace["Viewport NE Longitude"]!)
            let cityViewPortSWLat = Double(selectedPlace["Viewport SW Latitude"]!)
            let cityViewPortSWLon = Double(selectedPlace["Viewport SW Longitude"]!)
            
            let neViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortNELat!, longitude: cityViewPortNELon!)
            let swViewPortCityCorner = CLLocationCoordinate2D(latitude: cityViewPortSWLat!, longitude: cityViewPortSWLon!)
            cityViewPort = GMSCoordinateBounds(coordinate: neViewPortCityCorner, coordinate: swViewPortCityCorner)
            
            //cityViewPort = GMSCoordinateBounds(selectedPlace["Place Viewport"]!)
            
        }
        
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
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
                
            case UISwipeGestureRecognizerDirection.right:
                
                print("swiped right")
                
                let viewController = self.storyboard! .instantiateViewController(withIdentifier: "GoogleAddCity") as UIViewController; self.present(viewController, animated: true, completion: nil)
                
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
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView =  GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultController = PlacesSearchController()
        searchResultController.delegate = self
        
        self.googleMapsView.animate(with: GMSCameraUpdate.fit(cityViewPort, withPadding: 5.0))
        
        mapView(googleMapsView, didTapAt: userTappedCoordinates)
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async() { () -> Void in
            
            self.googleMapsView.delegate = self
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.title = cityName
            marker.map = self.googleMapsView
            
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(placeViewPort, withPadding: 5.0))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                
                if UserDefaults.standard.value(forKey: "placeDictionary") != nil {
                    
                    self.placeDictionary = UserDefaults.standard.object(forKey: "placeDictionary") as! Dictionary<String, String>
                    
                }
                
                let alert = UIAlertController(title: "Add \(self.placeDictionary["Place Name"]!) to \(cityName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    
                    self.placeDictionaries.append(self.placeDictionary)
                    
                    if self.placeDictionaries[0] == [:] {
                        
                        self.placeDictionaries.remove(at: 0)
                        
                    }
                    
                    
                    UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")
                    
                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                    
                    print("placeDictionaries = \(self.placeDictionaries)")
                    
                   self.googleMapsView.animate(with: GMSCameraUpdate.fit(cityViewPort, withPadding: 5.0))
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                    
                    self.placeDictionary.removeValue(forKey: "Place Name")
                    self.placeDictionary.removeValue(forKey: "Place ID")
                    self.placeDictionary.removeValue(forKey: "Latitude Center")
                    self.placeDictionary.removeValue(forKey: "Longitude Center")
                    self.placeDictionary.removeValue(forKey: "Viewport NE Latitude")
                    self.placeDictionary.removeValue(forKey: "Viewport NE Longitude")
                    self.placeDictionary.removeValue(forKey: "Viewport SW Latitude")
                    self.placeDictionary.removeValue(forKey: "Viewport SW Longitude")
                    
                    UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")
                    
                    self.googleMapsView.animate(with: GMSCameraUpdate.fit(cityViewPort, withPadding: 5.0))
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            })
        }
            
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.geocode

        //var visibleRegion : GMSVisibleRegion = self.googleMapsView.projection.visibleRegion()
        //visibleRegion.nearLeft = CLLocationCoordinate2DMake(cityViewPortSWLat, cityViewPortSWLon)
        //visibleRegion.farRight = CLLocationCoordinate2DMake(cityViewPortNELat, cityViewPortNELon)
        //let bounds = countryViewPort//GMSCoordinateBounds(coordinate: visibleRegion.nearLeft,coordinate: visibleRegion.farRight)

        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: cityViewPort, filter: nil) { (results, error:Error?) -> Void in
            
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
                    var place:String!
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
                            
                            self.placeName = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("result = \(result)")
                            print("city = \(self.placeName)")
                            
                            let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            print("lat = \(lat)")
                            
                            let placeLatitudeCenter = lat
                            print("placeLatitudeCenter = \(placeLatitudeCenter)")
                            
                            
                            let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            
                            let placeLongitudeCenter = lon
                            print("placeLongitudeCenter = \(placeLongitudeCenter)")
                            
                            
                            placeCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                            
                            let placeViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortNELat = \(placeViewPortNELat)")
                            
                            
                            let placeViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortNELon = \(placeViewPortNELon)")
                            
                            
                            let neViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortNELat, longitude: placeViewPortNELon)
                            
                            let placeViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortSWLat = \(placeViewPortSWLat)")
                            
                            
                            let placeViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortSWLon = \(placeViewPortSWLon)")
                            
                            
                            let swViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortSWLat, longitude: placeViewPortSWLon)
                            
                            placeViewPort = GMSCoordinateBounds(coordinate: neViewPortPlaceCorner, coordinate: swViewPortPlaceCorner)
                            
                            let placeID = ((result as? NSDictionary)?["place_id"] as? String)!
                            
                            print("placeID = \(placeID)")
                            
                            self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.placeName!)
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add \(self.placeName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    self.placeDictionary["Place Name"] = "\(self.placeName!)"
                                    self.placeDictionary["Place ID"] = "\(placeID)"
                                    
                                    self.placeDictionary["Latitude Center"] = "\(placeLatitudeCenter)"
                                    self.placeDictionary["Longitude Center"] = "\(placeLongitudeCenter)"
                                    
                                    
                                    
                                    self.placeDictionary["Viewport NE Latitude"] = "\(placeViewPortNELat)"
                                    self.placeDictionary["Viewport NE Longitude"] = "\(placeViewPortNELon)"
                                    self.placeDictionary["Viewport SW Latitude"] = "\(placeViewPortSWLat)"
                                    self.placeDictionary["Viewport SW Longitude"] = "\(placeViewPortSWLon)"
                                    
                                    self.placeDictionary["Place Viewport"] = "\(placeViewPort)"
                                    
                                    print("placeDictionary = \(self.placeDictionary)")
                                    
                                    self.placeDictionaries.append(self.placeDictionary)
                                    
                                    if self.placeDictionaries[0] == [:] {
                                        
                                        self.placeDictionaries.remove(at: 0)
                                        
                                        
                                    }
                                    
                                    print("placeDictionaries = \(self.placeDictionaries)")
                                    
                                    UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")
                                    
                                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                                    
                                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                    
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                    
                                    
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        } else if addressTypeDescriptor == "neighborhood" {
                            
                            neighborhood = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("neighborhood = \(neighborhood)")
                            
                        } else if addressTypeDescriptor == "locality" {
                            /*
                            place = ((result as! NSDictionary)["formatted_address"]) as? String
                            
                            print("city = \(city)")
                            
                            self.placeName = ((result as! NSDictionary)["formatted_address"]) as? String
                            print("result = \(result)")
                            print("city = \(self.placeName)")
                            
                            let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            print("lat = \(lat)")
                            
                            let placeLatitudeCenter = lat
                            print("placeLatitudeCenter = \(placeLatitudeCenter)")
                            
                            
                            let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            
                            let placeLongitudeCenter = lon
                            print("placeLongitudeCenter = \(placeLongitudeCenter)")
                            
                            
                            placeCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                            
                            let placeViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortNELat = \(placeViewPortNELat)")
                            
                            
                            let placeViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortNELon = \(placeViewPortNELon)")
                            
                            
                            let neViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortNELat, longitude: placeViewPortNELon)
                            
                            let placeViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortSWLat = \(placeViewPortSWLat)")
                            
                            
                            let placeViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortSWLon = \(placeViewPortSWLon)")
                            
                            
                            let swViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortSWLat, longitude: placeViewPortSWLon)
                            
                            placeViewPort = GMSCoordinateBounds(coordinate: neViewPortPlaceCorner, coordinate: swViewPortPlaceCorner)
                            
                            let placeID = ((result as? NSDictionary)?["place_id"] as? String)!
                            
                            print("placeID = \(placeID)")
                            
                            self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.placeName!)
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add \(self.placeName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    self.placeDictionary["Place Name"] = "\(self.placeName!)"
                                    self.placeDictionary["Place ID"] = "\(placeID)"
                                    
                                    self.placeDictionary["Latitude Center"] = "\(placeLatitudeCenter)"
                                    self.placeDictionary["Longitude Center"] = "\(placeLongitudeCenter)"
                                    
                                    
                                    
                                    self.placeDictionary["Viewport NE Latitude"] = "\(placeViewPortNELat)"
                                    self.placeDictionary["Viewport NE Longitude"] = "\(placeViewPortNELon)"
                                    self.placeDictionary["Viewport SW Latitude"] = "\(placeViewPortSWLat)"
                                    self.placeDictionary["Viewport SW Longitude"] = "\(placeViewPortSWLon)"
                                    
                                    self.placeDictionary["Place Viewport"] = "\(placeViewPort)"
                                    
                                    print("placeDictionary = \(self.placeDictionary)")
                                    
                                    self.placeDictionaries.append(self.placeDictionary)
                                    
                                    if self.placeDictionaries[0] == [:] {
                                        
                                        self.placeDictionaries.remove(at: 0)
                                        
                                        
                                    }
                                    
                                    print("placeDictionaries = \(self.placeDictionaries)")
                                    
                                    UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")
                                    
                                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                                    
                                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                    
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                    
                                    
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }*/
                            
                            
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
                            
                            self.placeName = ((result as! NSDictionary)["formatted_address"]) as? String
                            //print("result = \(result)")
                            print("city = \(self.placeName)")
                            
                            let lat = (((((result as! NSDictionary)["geometry"]) as? NSDictionary)?["location"] as! NSDictionary)["lat"] as? Double)!
                            print("lat = \(lat)")
                            
                            let placeLatitudeCenter = lat
                            print("placeLatitudeCenter = \(placeLatitudeCenter)")
                            
                            
                            let lon = ((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as! NSDictionary)["lng"] as? Double)!
                            
                            
                            let placeLongitudeCenter = lon
                            print("placeLongitudeCenter = \(placeLongitudeCenter)")
                            
                            
                            placeCoordinates = CLLocationCoordinate2D(latitude: cityLatitudeCenter, longitude: cityLongitudeCenter)
                            
                            let placeViewPortNELat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortNELat = \(placeViewPortNELat)")
                            
                            
                            let placeViewPortNELon = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["northeast"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortNELon = \(placeViewPortNELon)")
                            
                            
                            let neViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortNELat, longitude: placeViewPortNELon)
                            
                            let placeViewPortSWLat = (((((result as? NSDictionary)?["geometry"] as? NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lat"] as? Double)!
                            print("placeViewPortSWLat = \(placeViewPortSWLat)")
                            
                            
                            let placeViewPortSWLon = (((((result as? NSDictionary)?["geometry"] as?  NSDictionary)?["viewport"] as! NSDictionary)["southwest"] as? NSDictionary)?["lng"] as? Double)!
                            print("placeViewPortSWLon = \(placeViewPortSWLon)")
                            
                            
                            let swViewPortPlaceCorner = CLLocationCoordinate2D(latitude: placeViewPortSWLat, longitude: placeViewPortSWLon)
                            
                            placeViewPort = GMSCoordinateBounds(coordinate: neViewPortPlaceCorner, coordinate: swViewPortPlaceCorner)
                            
                            let placeID = ((result as? NSDictionary)?["place_id"] as? String)!
                            
                            print("placeID = \(placeID)")
                            
                            self.locateWithLongitudeByTap(lon, andLatitude: lat , andTitle: self.placeName!)
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add \(self.placeName!)?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                    
                                    self.placeDictionary["Place Name"] = "\(self.placeName!)"
                                    self.placeDictionary["Place ID"] = "\(placeID)"
                                    
                                    self.placeDictionary["Latitude Center"] = "\(placeLatitudeCenter)"
                                    self.placeDictionary["Longitude Center"] = "\(placeLongitudeCenter)"
                                    
                                    
                                    
                                    self.placeDictionary["Viewport NE Latitude"] = "\(placeViewPortNELat)"
                                    self.placeDictionary["Viewport NE Longitude"] = "\(placeViewPortNELon)"
                                    self.placeDictionary["Viewport SW Latitude"] = "\(placeViewPortSWLat)"
                                    self.placeDictionary["Viewport SW Longitude"] = "\(placeViewPortSWLon)"
                                    
                                    self.placeDictionary["Place Viewport"] = "\(placeViewPort)"
                                    
                                    print("placeDictionary = \(self.placeDictionary)")
                                    
                                    self.placeDictionaries.append(self.placeDictionary)
                                    
                                    if self.placeDictionaries[0] == [:] {
                                        
                                        self.placeDictionaries.remove(at: 0)
                                        
                                        
                                    }
                                    
                                    print("placeDictionaries = \(self.placeDictionaries)")
                                    
                                    UserDefaults.standard.set(self.placeDictionary, forKey: "placeDictionary")
                                    
                                    UserDefaults.standard.set(self.placeDictionaries, forKey: "placeDictionaries")
                                    
                                    let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripOverview") as UIViewController; self.present(viewController, animated: true, completion: nil)
                                    
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                                    
                                    
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                            
                            
                            
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
            marker.title = self.placeName
            marker.map = self.googleMapsView
            self.googleMapsView.animate(with: GMSCameraUpdate.fit(placeViewPort, withPadding: 5.0))
            
            
            
        }
        
    }

    
}
