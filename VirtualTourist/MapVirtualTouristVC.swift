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
        
        //Change text of deletionLabel
        deletionLabel.text = "Hold press to drop Pin or Delete Existing Pin"
        
        //Step 1 Get user core data stored Pins
        getStoredPins()
        
        // Step 2 Display user Pins from Step 1.
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
            //deletionLabel.isHidden = true
            
            // After deleting again give user information
            deletionLabel.text = "Create new Pin or Select Pin for Photos"
            
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
            deletionLabel.text = "Touch the pins to Delete"
        }
        
        
    }

    //MARK: Incomplete
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        // Code Reviewer SUGGESTION (I suggest deselecting the pin here, because if we move back to the map view after opening the photo album the specific pin cannot be selected again:)
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        // Debug Print
        print(" In Function Map View Delegate did select")
        
        let mapPinFetch: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        
       //  Core Data Double stores too much high precision in .000000000000 Values. We can remove that much precision & only use till .00001
        let precision = 0.00001
        
        let lowerBLatitude  = (view.annotation?.coordinate.latitude)! - precision
        let lowerBLongitude = (view.annotation?.coordinate.longitude)! - precision
        let upperBLatitude  = (view.annotation?.coordinate.latitude)! + precision
        let upperBLongitude  = (view.annotation?.coordinate.longitude)! + precision
        
        //NS Predicate Syntax for getting the pins on Latitude & longitude respectively
        // Took help for NSPRedicate Syntax from http://nshipster.com/nspredicate/ , https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
        mapPinFetch.predicate = NSPredicate(format: "(%K BETWEEN {\(lowerBLatitude) , \(upperBLatitude)}) AND (%K BETWEEN {\(lowerBLongitude), \(upperBLongitude) })", #keyPath(Pin.latitude) , #keyPath(Pin.longitude) )
        
        var resultsPins : [Pin] = []
        
        do {
          resultsPins =  try CoreDataStack.sharedInstance().persistentContainer.viewContext.fetch(mapPinFetch)
        } catch {
            print("Couldn't get the results Pins via NSPRedicate")
        }
        
        
        
        if isEditingMode {
            // Run the results Pins Variable after fetching via NSPRedicate
            
            // Edit Button has pressed & IBAction set bool "isEditingMode" = true
            if resultsPins.count > 0 {
                
                
                // Remove Map Annotations of Pins
              mapView.removeAnnotation(resultsPins.first!)
                print("Pin removed from MapView")
                
                // Delete from CoreData 
                CoreDataStack.sharedInstance().persistentContainer.viewContext.delete(resultsPins.first!)
                print("Pin deleted from Core Data")
                
                // Code Review Suggestion.  Always save context after any updates or make auto save every 1 min approx.
                CoreDataStack.sharedInstance().saveContext()
            }
            else {
                print("Couldn't fetch pins to delete")
                
            }
        }
            // Edit Button hasn't been pressed & IBAction set bool "isEditingMode" = false (Default)
            //Default Execution
        else {
            
            if resultsPins.count > 0 {
                userSelectedPin = resultsPins.first
                
                // Code Reviewer Suggestion (When a pin is selected the photo album should open:)
                let detailController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoVirtualTouristVC") as! PhotoVirtualTouristVC
                detailController.mapSegueSelectedPin = userSelectedPin
              // Perform the transition in Main thread , as UI should be done.
                DispatchQueue.main.async {
                    self.navigationController!.pushViewController(detailController, animated: true)
                }
                
                
            } else {
                print("Unable to find any Pins from Core data")
            }
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
            
           // MKAnnotation  http://stackoverflow.com/a/7213540/5177704
            MapVTMapView.addAnnotation(newPin)
            
            // Also update the label 
            deletionLabel.text = "Select the Pin for Photos"
            
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
