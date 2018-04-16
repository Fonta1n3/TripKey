//
//  placesAutocompleteController.swift
//  TripKey2
//
//  Created by Peter on 1/23/17.
//  Copyright © 2017 Fontaine. All rights reserved.
//

import UIKit
import GooglePlaces

class placesAutocompleteController: GMSAutocompleteResultsViewController, GMSAutocompleteResultsViewControllerDelegate {
    
    override func viewDidLoad() {
        delegate = self
    }
    
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
        
    }
    
    
    /**
     * Called when a non-retryable error occurred when retrieving autocomplete predictions or place
     * details. A non-retryable error is defined as one that is unlikely to be fixed by immediately
     * retrying the operation.
     * <p>
     * Only the following values of |GMSPlacesErrorCode| are retryable:
     * <ul>
     * <li>kGMSPlacesNetworkError
     * <li>kGMSPlacesServerError
     * <li>kGMSPlacesInternalError
     * </ul>
     * All other error codes are non-retryable.
     * @param resultsController The |GMSAutocompleteResultsViewController| that generated the event.
     * @param error The |NSError| that was returned.
     */
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        
        
    }
    
    


}
