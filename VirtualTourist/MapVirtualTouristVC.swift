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
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
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

    
    
    // Edit button Pressed
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        // First Execution will happen in else statement , as "isEditingMode" Default value set is "False"
        
        // After pressing Done on Edit Button
        
        if isEditingMode {
            isEditingMode = false
            editButton.title = "Edit"
            deletionLabel.isHidden = true
            
            
            // Save after user pressed "Done" with the Pins
            CoreDataStack.sharedInstance().saveContext()
            //Debug Print
            print("User Pins saved after deletion")
            
        }
            //Default Execution
        else {
            isEditingMode = true
            editButton.title = "Done"
            deletionLabel.isHidden = false
            
        }
        
        
    }

    //MARK: Incomplete
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Debug Print
        print(" In Function Map View Delegate did select")
        if isEditingMode {
            
        }
        else {
            
        }
    }
    
    
    // Adds Pin when user holds the touch Gesture for more than 1.2 secs.
    //MARK: Incomplete
    func addUserPin(gesture : UIGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            print("input Gesture received")
            
            let touch = gesture.location(in: MapVTMapView)
            let convertedCoordinates = MapVTMapView.convert(touch, toCoordinateFrom: MapVTMapView)
            
            // Update the View with Pin
            
            // get Pin context & update Object
            let newPin  = Pin(context: CoreDataStack.sharedInstance().persistentContainer.viewContext)
            newPin.latitude = convertedCoordinates.latitude
            newPin.longitude = convertedCoordinates.longitude
            
            MapVTMapView.addAnnotation(newPin)
            
            // Get Flickr Photos for that Pin
            FlickrParseClient.sharedInstance().parsePhotoURLFromFlickrJSON(pin: newPin, managedcontext: CoreDataStack.sharedInstance().persistentContainer.viewContext)
            
            
            // Save Pin to Core Data 
            
            do {
                try CoreDataStack.sharedInstance().persistentContainer.viewContext.save()
            }
            catch {
                print("Couldnt save Pin to Core Data")
                // Debug text 
                print("func addUserPin in MapVTVC Couldn't save")
            }
            
        }
    } //  func addUserPin Ends
    
    
    

    
    //Retrieves Core Data Pins stored from the User Data.
    func getStoredPins() {
        
        do {
            userPins = try CoreDataStack.sharedInstance().persistentContainer.viewContext.fetch(Pin.fetchRequest())
        } catch {
            print("Couldn't fetch the user Stored Pins from Core Data")
        }
        
    }
    
    
    
    // Segue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePhotoViewController" {
            // back button is set directly in Storyboard 
           // Link :  http://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift/34268936#34268936
            
            
            
            let controller = segue.destination as! PhotoVirtualTouristVC
            controller.mapSegueSelectedPin = userSelectedPin
            
        }
 
    } // segue end
    

    
    
    
    
}
