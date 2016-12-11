//
//  MapVirtualTouristVC.swift
//  VirtualTourist
//
//  Created by Sensehack on 11/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class MapVirtualTouristVC : UIViewController , MKMapViewDelegate
{
    
    //var userSelectPin
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePhotoViewController" {
            
            let controller = segue.destination as! PhotoVirtualTouristVC
            //controller.userSelectPin = userSelectPin
            
        }
    }
}
