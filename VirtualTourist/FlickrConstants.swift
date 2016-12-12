//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Sensehack on 11/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation

struct FlickrConstants {
    
    // Sample URL
    
    // URL: https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=6452d34959c669303d0a3b16435aa05d&gallery_id=72157675621648192&format=json&nojsoncallback=1&api_sig=d5be1897030c6877e6be417a47e2cfbe
    
    
    
    
    static let APIScheme = "https:"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    
    // Latitude & Longitude Square Box Constants
    static let SearchBBoxHalfWidth = 1.0
    static let SearchBBoxHalfHeight = 1.0
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
    
    
    
    
    
}
