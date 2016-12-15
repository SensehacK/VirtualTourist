//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Sensehack on 12/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// Added MKAnnotation subclass to Pin for adding MapKits Annotations directly
public class Pin: NSManagedObject , MKAnnotation {

    
   // MK Annotation  http://stackoverflow.com/a/7213540/5177704
   // https://developer.apple.com/reference/mapkit/mkannotation An object that adopts this protocol must implement the coordinate property. The other methods of this protocol are optional.
    public var coordinate: CLLocationCoordinate2D {
        
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        set(coordinate){
            self.coordinate = coordinate
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(annotationLatitude: Double, annotationLongitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        latitude = annotationLatitude
        longitude = annotationLongitude
    }
}
