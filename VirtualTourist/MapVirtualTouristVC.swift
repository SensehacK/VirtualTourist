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
    
    // variables Declared
    //var userSelectPin
    
    
    
    
    
    // IBOutlets
    @IBOutlet weak var MapVTMapView: MKMapView!
    
    @IBOutlet weak var deletionLabel: UILabel!
    
    
    
    
    
    
    // Edit button Pressed
    @IBAction func editButtonPressed(_ sender: AnyObject) {
    }
    
    
    
    
    // Segue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePhotoViewController" {
            // back button is set directly in Storyboard 
           // Link :  http://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift/34268936#34268936
            
            
            let controller = segue.destination as! PhotoVirtualTouristVC
            //controller.userSelectPin = userSelectPin
            
        }
 
    } // segue end
    
    
    
    
    
}
