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
    
    
    
    // Parameter Keys
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Format = "format"
        static let JSONCallback = "nojsoncallback"
        static let Extras = "extras"
        static let Text = "text"
        static let Page = "page"
        static let BBOX = "bbox"
        static let SearchType = "safe_search"
        
        
        
    }
    
    
    // Parameter Values
    
    struct ParameterValues {
        static let APIKey = "359380763d00218092b220c5a81fc38c"
        static let SearchMethod = "flickr.photos.search"
        static let GalleryID = "gallery_id"
        static let JSONFormat = "json"
        static let NoJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
        
        
        
    }
    
    // Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        
        
    }

    
}
