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
    var userPins : [Pin] = []
    var userSelectedPin : Pin!
    var isEditingMode : Bool = false
    
    
    
    
    
    // IBOutlets
    @IBOutlet weak var MapVTMapView: MKMapView!
    
    @IBOutlet weak var deletionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calls to delegate Self
        MapVTMapView.delegate = self
        
        //Step 1 Get user core data stored Pins
        getStoredPins()
        
        // Display user Pins from Step 1.
        MapVTMapView.addAnnotations(userPins)
        
        // add the Touch to create pin Map Annotation
        let holdPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addUserPin))
        holdPress.minimumPressDuration = 1.2
        MapVTMapView.addGestureRecognizer(holdPress)
        
        
    }
    
    // Reference :  http://stackoverflow.com/questions/33200161/change-map-type-hybrid-satellite-via-segmented-control
    
    // Change Map View style
    
    @IBAction func segmentMapAction(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            MapVTMapView.mapType = .standard
        case 1:
            MapVTMapView.mapType = .satellite
        case 2:
            MapVTMapView.mapType = .hybrid
        default: // or case 2
            MapVTMapView.mapType = .standard
        }
        
    }

    
    
    // Adds Pin when user holds the touch Gesture for more than 1.2 secs.
    
    func addUserPin(gesture : UIGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            print("input Gesture received")
            
            
        }
    }
    
    
    //Retrieves Core Data Pins stored from the User Data.
    func getStoredPins() {
        
    }
    
    
    
    // Edit button Pressed
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        if isEditingMode {
            isEditingMode = false
            
            
            
            
        }
        else {
            
            
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    // Segue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePhotoViewController" {
            // back button is set directly in Storyboard 
           // Link :  http://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift/34268936#34268936
            
            
            
            //let controller = segue.destination as! PhotoVirtualTouristVC
            //controller.userSelectPin = userSelectPin
            
        }
 
    } // segue end
    

    
    
    
    
}
