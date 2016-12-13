//
//  FlickrParseClient.swift
//  VirtualTourist
//
//  Created by Sensehack on 11/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation
class FlickrParseClient {
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrParseClient {
        struct Singleton {
            static var sharedInstance = FlickrParseClient()
        }
        return Singleton.sharedInstance
    }

    
    
    // Used from "Flick Finder" Jarod Udacity, Created by Jarrod Parkes on 11/5/15.
    private func bboxString( latitude : Double , longitude : Double ) -> String {
        
        // Checking Valid Map Coordinates
        if(latitude == 0.0 && longitude == 0.0) {
            return "0,0,0,0"
        }
        
            let minimumLon = max ( longitude - FlickrConstants.SearchBBoxHalfWidth , FlickrConstants.SearchLonRange.0)
            let minimumLat = max ( latitude - FlickrConstants.SearchBBoxHalfHeight , FlickrConstants.SearchLatRange.0)
            let maximumLon = max ( longitude - FlickrConstants.SearchBBoxHalfWidth , FlickrConstants.SearchLonRange.1)
            let maximumLat = max ( latitude - FlickrConstants.SearchBBoxHalfHeight , FlickrConstants.SearchLatRange.1)

            return "\(minimumLon) , \(minimumLat) , \(maximumLon) , \(maximumLat) "
        
    }
    
    
    // function for initializing session task.
    func initTask(request : URLRequest , completionHandlerForTask : @escaping (_ result : AnyObject? , _ error : Error?)-> URLSessionDataTask) {
        
        let task = URLSession.shared.dataTask(with: request) {
            data , response , error in
            
            // guard statements incoming 
            
            guard let data = data else {
                print("Data not present,")
                //Debug print
                print("Error in InitTask Guard Statement")

                return
            }
            
            guard error == nil else {
                print("error present")
                //Debug print
                print("Error in InitTask Guard Statement")
                return
            }
            // Status code msgs
            guard let statusCodes = (response as? HTTPURLResponse)?.statusCode , statusCodes >= 200 && statusCodes <= 299 else {
                print("Wrong status codes returned")
                return
            }
            
            var parsedResult : Any!
            
            do {
           parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                print(" Catched Error in JSON serialization Json Object creation")
                
            }
            
            completionHandlerForTask(parsedResult as AnyObject, nil)
            
        }
        
        task.resume()
         // Gets Non void error for returning task
        //return task
        
        
    }
    
    
    
    // Build URL & return the request.
    
    func getBuildURL(parameters : [String:AnyObject]) -> URLRequest {
        
        // Building URL Components
        var components = URLComponents()
        components.scheme = FlickrConstants.APIScheme
        components.host   = FlickrConstants.APIHost
        components.path   = FlickrConstants.APIPath
        
        components.queryItems = [URLQueryItem]()
        
        for (keys , values) in parameters {
            let queryItem = URLQueryItem(name: keys, value: values as? String)
            components.queryItems?.append(queryItem)
        }
        
        if  components.url == nil
        {
            print("Error in URL Creation")
        }
        
        guard let urlrequested = components.url else {
            print("Error in URL Creation")
            let url2 = NSURL(string: "https://www.flickr.com/photos/flickr/30709520093/in/feed")
            let url = URLRequest.init(url: url2 as! URL)
            return url
        }
        
        
        let request = URLRequest(url: urlrequested)
        return request
        
        
    }
    
    

    
    
    
    
    
    
}
