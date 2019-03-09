//
//  HTTPRequest.swift
//  TripKey
//
//  Created by Peter on 07/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import Foundation

final class MakeHttpRequest {
    
    static let sharedInstance = MakeHttpRequest()
    let url_base = "https://api.flightstats.com/flex/"
    let apiKey = "?appId=16d11b16&appKey=821a18ad545a57408964a537526b1e87"
    var dictToReturn = NSDictionary()
    
    func getRequest(api: String, completion: @escaping () -> Void) {
        
        guard let destination = URL(string: url_base + api + apiKey) else { return }
        let request = URLRequest(url: destination)
        //request.timeoutInterval = 5
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    if error != nil {
                        
                        print(error as Any)
                        completion()
                        
                    } else {
                        
                        self.dictToReturn = json
                        completion()
                        
                    }
                    
                } catch {
                    
                    print(error)
                    completion()
                }
                
            } else {
                
                print(error ?? "")
                completion()
                
            }
            
        }
        
        task.resume()
        print(url_base + api)
        
    }
    
    private init() {
        
    }
    
}
