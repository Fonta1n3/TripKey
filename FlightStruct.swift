//
//  FlightStruct.swift
//  TripKey
//
//  Created by Peter on 10/02/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation


public struct FlightStruct: CustomStringConvertible {
    
    let lastUpdated:String
    let flightNumber:String
    let publishedDepartureUtc:String
    let airlineCode:String
    let arrivalAirportCode:String
    let arrivalCity:String
    let arrivalDate:String
    let arrivalGate:String
    let arrivalLat:Double
    let arrivalLon:Double
    let arrivalTerminal:String
    let arrivalUtcOffset:Double
    let baggageClaim:String
    let departureAirport:String
    let departureCity:String
    let departureGate:String
    let departureLat:Double
    let departureLon:Double
    let departureTerminal:String
    let departureDate:String
    let departureUtcOffset:Double
    let flightDuration:String
    let airplaneType:String
    let flightId:String
    let flightStatus:String
    let identifier:String
    let phoneNumber:String
    let primaryCarrier:String
    let publishedArrival:String
    let publishedDeparture:String
    let urlArrivalDate:String
    
    init(dictionary: [String: Any]) {
        
        self.flightNumber = dictionary["flightNumber"] as? String ?? ""
        self.publishedDepartureUtc = dictionary["publishedDepartureUtc"] as? String ?? ""
        self.airlineCode = dictionary["airlineCode"] as? String ?? ""
        self.arrivalAirportCode = dictionary["arrivalAirportCode"] as? String ?? ""
        self.arrivalCity = dictionary["arrivalCity"] as? String ?? ""
        self.arrivalDate = dictionary["arrivalDate"] as? String ?? ""
        self.arrivalGate = dictionary["arrivalGate"] as? String ?? ""
        self.arrivalLat = dictionary["arrivalLat"] as? Double ?? 0
        self.arrivalLon = dictionary["arrivalLon"] as? Double ?? 0
        self.arrivalTerminal = dictionary["arrivalTerminal"] as? String ?? ""
        self.arrivalUtcOffset = dictionary["arrivalUtcOffset"] as? Double ?? 0
        self.baggageClaim = dictionary["baggageClaim"] as? String ?? ""
        self.departureAirport = dictionary["departureAirport"] as? String ?? ""
        self.departureCity = dictionary["departureCity"] as? String ?? ""
        self.departureGate = dictionary["departureGate"] as? String ?? ""
        self.departureLat = dictionary["departureLat"] as? Double ?? 0
        self.departureLon = dictionary["departureLon"] as? Double ?? 0
        self.departureTerminal = dictionary["departureTerminal"] as? String ?? ""
        self.departureDate = dictionary["departureTime"] as? String ?? ""
        self.departureUtcOffset = dictionary["departureUtcOffset"] as? Double ?? 0
        self.flightDuration = dictionary["flightDuration"] as? String ?? ""
        self.airplaneType = dictionary["flightEquipment"] as? String ?? ""
        self.flightId = dictionary["flightId"] as? String ?? ""
        self.flightStatus = dictionary["flightStatus"] as? String ?? ""
        self.identifier = dictionary["identifier"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.primaryCarrier = dictionary["primaryCarrier"] as? String ?? ""
        self.publishedArrival = dictionary["publishedArrival"] as? String ?? ""
        self.publishedDeparture = dictionary["publishedDeparture"] as? String ?? ""
        self.urlArrivalDate = dictionary["urlArrivalDate"] as? String ?? ""
        self.lastUpdated = dictionary["lastUpdated"] as? String ?? ""
    }
    
    public var description: String {
        return ""
    }
    
}
