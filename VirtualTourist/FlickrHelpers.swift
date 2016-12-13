//
//  FlickrHelpers.swift
//  VirtualTourist
//
//  Created by Sensehack on 11/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation
import CoreData


extension FlickrParseClient {
    
    //Parse Image URLs from Flickr JSON Response Objects
    
    
    func parsePhotoURLFromFlickrJSON(pin selectedPin : Pin, managedcontext coreDataContext:NSManagedObjectContext ){
        
        
        // Parameters adding
        
        let flickrParameters : [String : String?] = [
            FlickrConstants.ParameterKeys.Method : FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey : FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BBOX : FlickrParseClient.sharedInstance().bboxString(latitude: selectedPin.coordinateValues.latitude, longitude: selectedPin.coordinateValues.longitude),
            FlickrConstants.ParameterKeys.SearchType : FlickrConstants.ParameterValues.SafeSearch,
            FlickrConstants.ParameterKeys.Extras : FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format : FlickrConstants.ParameterValues.JSONFormat,
            FlickrConstants.ParameterKeys.JSONCallback : FlickrConstants.ParameterValues.NoJSONCallback
        
        ]
        
      // Request Setup
        
        
        let getRequestSetup = FlickrParseClient.sharedInstance().getBuildURL(parameters: flickrParameters as [String : AnyObject])
        
        
        /*
        // Start Task 
        let task = FlickrParseClient.sharedInstance().initTask(request: getRequestSetup, completionHandlerForTask:  { (data , error)  in
        
        
            guard error == nil else {
                print("Error present")
                return
            }
        
            guard let data = data else {
                print("Error in data not present")
                return
            }
            
        
            
        
        
        
        
        
        })
        task.resume()
        
        */
        
        let task2 = URLSession.shared.dataTask(with: getRequestSetup) {
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
            
            var parsedResult : [String:AnyObject]?
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                
                
            } catch {
                print(" Catched Error in JSON serialization Json Object creation")
                
            }
            
            
            guard let photosDictionary = parsedResult?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject],
                let photosArray = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String:AnyObject]]
                else {
                    print(" find \(FlickrConstants.ResponseKeys.Photos) and \(FlickrConstants.ResponseKeys.Photo) in \(parsedResult)")
                    return
            }
            
            guard photosArray.count > 0 else {
                print("photosarray is empty.")
                return
            }

            
            for index in 0...(photosArray.count-1){
                
                let photoDictionary = photosArray[index] as [String:AnyObject]
                
                guard let imageURLString = photoDictionary[FlickrConstants.ResponseKeys.MediumURL] as? String else {
                    print("Unable to locate image URL in photo dictionary")
                    return
                }
                
                // asynchronously run same thread
                coreDataContext.perform{
                    // Create a photo object
                    let photo = Photo(context: coreDataContext)
                    
                    // Save the  url
                    photo.url = imageURLString
                    
                    // Save the  index
                    photo.index = index + 1
                    
                    // Make Bool isinAlbum = false
                    photo.isInAlbum = false
                    
                    // Save photo for selected pin
                    selectedPin.addToPhotos(photo)
                }
                
            }

            
        
        }
        
        
        
        task2.resume()
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Convert Flickr URLs to  Image Data.
    func getImageDataFlickrURL (urlString : String) -> Data? {
        
        guard let url = URL(string: urlString),
            let imageData = try? Data(contentsOf: url) else {
                print("Error converting URL string to Image data")
                return nil
        }
        return imageData
    }
    
    
}
