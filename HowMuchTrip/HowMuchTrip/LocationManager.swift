//
//  CreateTripTableViewControllerLocationManager.swift
//  HowMuchTrip
//
//  Created by david on 1/6/16.
//  Copyright © 2016 HowMuchTrip. All rights reserved.
//

import Foundation
import CoreLocation

class CreateTripTableViewControllerLocationManager: NSObject, MapsAPIResultsProtocol, CLLocationManagerDelegate
{
    var controller: CreateTripTableViewController!
    var locationManager: CLLocationManager! {
        didSet {
            if locationManager == nil
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            else
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            }
        }
    }
    
    init(controller: CreateTripTableViewController)
    {
        self.controller = controller
    }
    
    //MARK: - Location
    
    /// Function called when next button is pressed. Passes in a textfield; if the textfield is the destination or departure location text field, starts a google maps api call to find the lat and lng of the location.
    func checkForLocation(textField: UITextField)
    {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        if textField == controller.destinationTextField
        || textField == controller.departureLocationTextField
        {
            dispatch_async(backgroundQueue) { () -> Void in
                if textField == self.controller.destinationTextField
                {
                    //DESTINATION
                    
                    if let term = self.controller.destinationTextField.text
                    {
                        self.controller.mapsAPIController = MapsAPIController(delegate: self)
                        self.controller.destinationTextField.tag = 60
                        self.controller.mapsAPIController?.searchGMapsFor(term, textFieldTag: self.controller.destinationTextField.tag)
                    }
                }
                else if textField == self.controller.departureLocationTextField
                {
                    //ORIGIN
                    
                    if let term = self.controller.departureLocationTextField.text
                    {
                        self.controller.mapsAPIController = MapsAPIController(delegate: self)
                        self.controller.departureLocationTextField.tag = 61
                        self.controller.mapsAPIController?.searchGMapsFor(term, textFieldTag: self.controller.departureLocationTextField.tag)
                    }
                }
            }
        }
    }
    
    /// Function called when the google maps api finished its search. If the search was successful, assigns the found lat and lng to their respective values in the current trip object.
    func didReceiveMapsAPIResults(results: NSDictionary, textFieldTag: Int)
    {
        if let (lat, lng) = controller.trip.tripCoordinateFromJSON(results)
        {
            switch textFieldTag
            {
            case controller.destinationTextField.tag:
                
                controller.trip = controller.calculator.assignValue(controller.trip, propertyAndValue: ["destinationLat" : lat])
                controller.trip = controller.calculator.assignValue(controller.trip, propertyAndValue: ["destinationLng" : lng])
                
            case controller.departureLocationTextField.tag:
                
                controller.trip = controller.calculator.assignValue(controller.trip, propertyAndValue: ["departureLat" : lat])
                controller.trip = controller.calculator.assignValue(controller.trip, propertyAndValue: ["departureLng" : lng])
                
            default: break
            }
        }
    }
    
    // MARK: - Location Manager
    
    /// Function called when location button is pressed. Prompts user for permission to use location services in order to determine departure location. Presents an error popup if there is no current network connection.
    func configureLocationManager()
    {
        if CLLocationManager.authorizationStatus() != .Denied
            && CLLocationManager.authorizationStatus() != .Restricted
            && Reachability.isConnectedToNetwork()
        {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            controller.departureLocationTextField.placeholder = "Finding your location..."
            
            if CLLocationManager.authorizationStatus() == .NotDetermined
            {
                locationManager?.requestWhenInUseAuthorization()
            }
            
            locationManager?.startUpdatingLocation()
        }
        else if !Reachability.isConnectedToNetwork()
        {
            controller.presentErrorPopup("Couldn't access an active network connection. Please try again later. Sorry about that!")
        }
    }
    
    /// Presents an error popup if the location manager fails to find location.
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError)
    {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        //        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        controller.presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
    }
    
    /// Function called when location manager successfully finds user location. Fills in the departure location text field with the user's current location, or presents an error popup if the location manager errors during this step.
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            controller.geocoder = CLGeocoder()
            controller.geocoder?.reverseGeocodeLocation(location,
                completionHandler: { (placemarks, error) -> Void in
                    if error == nil
                    {
                        self.locationManager?.stopUpdatingLocation()
                        self.locationManager = nil
                        
                        let locality: String! = placemarks!.first!.locality
                        let country: String! = placemarks!.first!.country
                        let state: String! = placemarks!.first!.administrativeArea
                        
                        print("didUpdateLocation")
                        
                        self.controller.locationManagerManagerDidFindLocation(
                        
                        "\(locality), \(state), \(country)"
                            
                        )
                        
                        UIApplication
                            .sharedApplication()
                            .networkActivityIndicatorVisible = false
                    }
                    else
                    {
                        self.locationManager?.stopUpdatingLocation()
                        self.locationManager = nil
                        
                        print(error?.localizedDescription)
                        self.controller.presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
                    }
            })
        }
        else
        {
            locationManager?.stopUpdatingLocation()
            locationManager = nil
            
            controller.presentErrorPopup("Something went wrong while trying to find your location. Please try again later. Sorry about that!")
        }
    }
}