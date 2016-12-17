//
//  PhotoVirtualTouristVC.swift
//  VirtualTourist
//
//  Created by Sensehack on 11/12/16.
//  Copyright © 2016 Sensehack. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoVirtualTouristVC : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    
    
    // IBOutlets Connections
    
    @IBOutlet weak var PhotoVTMap: MKMapView!
    @IBOutlet weak var PhotoVTCollection: UICollectionView!
    @IBOutlet weak var getMorePhotosorDeletePhotos: UIButton!
    
    
    
    
    
    //Variables Declaration
    
    // Selected User Pin passed from Map View controller
    var mapSegueSelectedPin : Pin!
    
    // Selected Pin's Photos store in Core Data retrieved from Flickr
    var selectedPinPhotos : [Photo] = []
    
    // Currently displayed Photos of user selected Pin on Collection View
    var collectionViewPhoto : [Photo] = []
    
    // User selected photos which user doesn't want it , Photos to be deleted from Core Data & also removed from CollectionView
    var photosDeleted : [Photo] = []
    
    //Default View Active is set false , Set to true in View Did Load. Easier to track view Active when going in Background or View will Disappear.
    var isPhotoViewActive : Bool = false
    var randomPhoto : Int!
    
    //MARK: View DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Map on PhotoVT
        
        let regionDist: CLLocationDistance = 1200
        let mapArea = MKCoordinateRegionMakeWithDistance(mapSegueSelectedPin.coordinate, regionDist * 2.0, regionDist * 2.0)
        // Current Region displayed
        PhotoVTMap.setRegion(mapArea, animated: true)
        //  adding Pin to that region
        PhotoVTMap.addAnnotation(mapSegueSelectedPin)
        
        
        // View Loaded so Active
        isPhotoViewActive = true
        
        // show the user selected photos
        selectedPinPhotos = Array(mapSegueSelectedPin!.photos!) as! [Photo]
        
        //Random Photo number generated from selected Pin Photos
        randomPhoto = Int(arc4random_uniform(UInt32(selectedPinPhotos.count)))
        
        
        // check Photos boolean property whether it is located in Collection View "isInAlbum" Default is False when they are been created.
        
        var albumPhotos:[Photo] = []
        
        for p in selectedPinPhotos {
            if p.isInAlbum{
                albumPhotos.append(p)
            }
        }
        
        collectionViewPhoto = albumPhotos
        
        
        
        
        // Check the CollectionView Photos whether they are empty ( new Pin ) or old Pin Photos from Core data boolean property 
        
        if collectionViewPhoto.isEmpty {
            
            var storedPhotos :[Photo] = []
            
            // if photos of selected pin retrieve are less than 21 then return all photos of Selected Pin to the collectionView Photo display grid
            if selectedPinPhotos.count <= 21 {
                collectionViewPhoto = selectedPinPhotos
            }
                // else randomly select photos from 21 using arc4random_uniform
            else {
                for _ in 1...21 {
                    
                    let arcRandomIndex = Int(arc4random_uniform(UInt32(selectedPinPhotos.count)))
                    storedPhotos.append(selectedPinPhotos[arcRandomIndex])
                    //Debug print
                    print("Random Index: \(arcRandomIndex)")
                    
                    //  Change selectedPin photo property "isInAlbum" = true
                    selectedPinPhotos[arcRandomIndex].isInAlbum = true
                    
                }
            }
            
            collectionViewPhoto = storedPhotos
            
            
        }
        
        
        
        // Set the selectedPinPhotos managed Context into Pin "photos" relationship.
        mapSegueSelectedPin.photos = Set(selectedPinPhotos) as NSSet
        
        // Save the changes from Collection View to Core Data
         CoreDataStack.sharedInstance().saveContext()
        
        PhotoVTCollection.dataSource = self
        PhotoVTCollection.delegate   = self
        
        
        
    } // View Did Load func ends
    
    
    
    //MARK: View Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isPhotoViewActive = false
        
        // Save the context core data the pin
        mapSegueSelectedPin.photos = Set(self.selectedPinPhotos) as NSSet
        CoreDataStack.sharedInstance().saveContext()
    }
    
    
    
    @IBAction func getNewPhotosOrDelete(_ sender: AnyObject) {
        //Check whether Photos to be deleted or not
        
        
        if photosDeleted.isEmpty {
            //New collection Button , No photos to be deleted
            
            //Falsify Boolean value of "isInAlbum" for Photos
            for p in selectedPinPhotos {
                p.isInAlbum = false
            }
            
            //Remove old photos as new photos are being retrieved. To delete old photos call the function itself.
            
            photosDeleted = collectionViewPhoto
            if selectedPinPhotos.count > 0 {
                getNewPhotosOrDelete(sender)
                
            }
            else {
                showAlert(message: "No Photos to get from this pin")
            }
            
            
            // Get random photos from remaining Photos Pins
            
            var storedPhotos :[Photo] = []
            
            // if photos of selected pin retrieve are less than 21 then return all photos of Selected Pin to the collectionView Photo display grid
            if selectedPinPhotos.count <= 21 {
                collectionViewPhoto = selectedPinPhotos
            }
                // else randomly select photos from 21 using arc4random_uniform
            else {
                for _ in 1...21 {
                    
                    let arcRandomIndex = Int(arc4random_uniform(UInt32(selectedPinPhotos.count)))
                    storedPhotos.append(selectedPinPhotos[arcRandomIndex])
                    //Debug print
                    print("Random Index: \(arcRandomIndex)")
                    
                    //  Change selectedPin photo property "isInAlbum" = true
                    selectedPinPhotos[arcRandomIndex].isInAlbum = true
                    
                }
            }
            
            // Saved the random photos in Collection View Photo Array to display it.
            collectionViewPhoto = storedPhotos
            
            // Reload the Collection View
            PhotoVTCollection.reloadData()
        }
        else {
            // Delete selectedPhoto specific of Collection view delegate , did select at returning specific photos to be delete , stored in PhotosDeleted.
            
            //filter out the soon to be deleted photos from the main context & resave it. Collection View Display Photos Filter
            collectionViewPhoto = collectionViewPhoto.filter{!photosDeleted.contains($0)}
            
            //filter out the soon to be deleted photos from the main context & resave it. UserSelectedPinPhotos Display Photos Filter
            
            selectedPinPhotos = selectedPinPhotos.filter{!photosDeleted.contains($0)}
            
            // Update the random variable with updated photos remaining
            randomPhoto = Int(arc4random_uniform(UInt32(selectedPinPhotos.count)))
            
            
            // delete from Core data
            for p in photosDeleted {
               CoreDataStack.sharedInstance().persistentContainer.viewContext.delete(p)
            }
            
            // Save to core data
            
            do {
                try CoreDataStack.sharedInstance().persistentContainer.viewContext.save()
            } catch {
                print("Couldn't save the deleted items removed in Core data")
            }
            
            let photosDeletedCount = photosDeleted.count
            
            showAlert(message: "\(photosDeletedCount) photos were deleted ")
            
            // Small changes after Deletion
            
            // Clear the array
            photosDeleted = []
            
            //Set the text
            getMorePhotosorDeletePhotos.setTitle("Get More Photos", for: .normal)
            
            // Reload data 
            PhotoVTCollection.reloadData()
            
            
            
        }
        
        
    }
    
    
    
    
    
    //MARK: Collection View Delegate & DataSource
    
    // viewDidLayoutSubviews
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    */
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return collectionViewPhoto.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrPhotoCollectionCell", for: indexPath) as! PhotoCellVT
        
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCellVT
        
        
        //debug print 
        print("In collectionView function ,'Did select Item At'")
        if photosDeleted.contains(collectionViewPhoto[indexPath.row]) {
            
            //debug print
            print("In collectionView function ,'Did select Item At' if statement")
            
            let selectItem = [collectionViewPhoto[indexPath.row]]
            let image = collectionViewPhoto[indexPath.row].image as! Data
            cell.imageViewCell.image = UIImage(data: image)
            
            // Check photosDeleted Array for empty after removing cell photos & change the Button Title
            photosDeleted = photosDeleted.filter{selectItem.contains($0)}
            if photosDeleted.isEmpty {
                getMorePhotosorDeletePhotos.setTitle("Get New Images", for: .normal)
            }
            

            
        }
        else {
            //debug print
            print("In collectionView function ,'Did select Item At' else statement")

            
            // User Taps the image , default button text should be "Delete Selected Images"
            getMorePhotosorDeletePhotos.setTitle("Delete Selected Photos", for: .normal)
            
            // Color change
            cell.imageViewCell.image = cell.imageViewCell.image?.withRenderingMode(.alwaysTemplate)
            cell.imageViewCell.tintColor = UIColor.brown
            
            photosDeleted.append(collectionViewPhoto[indexPath.row])
            

        }
        
        
    } // func collectionView didSelectItemAt ends
    
    
    
    func imageLoadFromCoreOrFlickr (indexPath : IndexPath , cell : PhotoCellVT ) {
        
        // Clear out the imageView of Photo Cell Collection first
        cell.imageViewCell.image = nil
        
        
        // Check whether Core Data Image data present or we have to retrieve from Flickr Api 
        
        // First run or Deleted images. Retrieve data from URL Flickr
        if collectionViewPhoto[indexPath.row].image == nil {
            
            
            //Code Reviewer Suggestion (Starting and stopping the activity indicator should perform in the main queue:)
            // Start Animation of loading activity
            DispatchQueue.main.async{
            cell.activityIndicatorInCell.startAnimating()
            }
            
            
            DispatchQueue.global(qos: .userInitiated).sync {
                
                
                // Run this on same Thread
                CoreDataStack.sharedInstance().persistentContainer.viewContext.perform {
                    
                    guard let imageDataFlickr = FlickrParseClient.sharedInstance().getImageDataFlickrURL(urlString: self.collectionViewPhoto[indexPath.row].url!) else {
                        print("error in getting image Data from flickr")
                        return
                    }
                    
                    for photo in self.selectedPinPhotos {
                        if photo.index == self.collectionViewPhoto[indexPath.row].index {
                            CoreDataStack.sharedInstance().persistentContainer.viewContext.perform {
                                photo.image = imageDataFlickr as NSData
                                cell.activityIndicatorInCell.stopAnimating()
                                cell.imageViewCell.image = UIImage(data: imageDataFlickr)
                            } // Context 2nd  End Function
                        } // if photo index end declaration
                    } // For loop end
                    
                    
                    // Save context Method Call
                    CoreDataStack.sharedInstance().persistentContainer.viewContext.perform {
                        CoreDataStack.sharedInstance().saveContext()
                    }
                } // context perform 1st end

            } // DispatchQueue.global(qos: .userInitiated).sync End
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            
            
                if self.isPhotoViewActive {
                    print("Function check whether view active or not -> True")
                }
            
            }) // DispatchQueue.main.asyncAfter(deadline: .now() end
            
    
        }
        // In Core Data Objects
        else {
            let corePhotoData = UIImage(data: collectionViewPhoto[indexPath.row].image as! Data)
            
            
            //Code Reviewer Suggestion (Starting and stopping the activity indicator should perform in the main queue:)
             // Stop Animation of loading activity
                DispatchQueue.main.async{
                cell.activityIndicatorInCell.stopAnimating()
            }
            
            // Display the Photo Image Data on Photo Cell VT image
            cell.imageViewCell.image = corePhotoData
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    

    // MARK: Show Alert Methods
    
    func showAlert(message: String) {
        let alertDisplay = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let pressOK = UIAlertAction(title: "OK", style: .default){
            _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertDisplay.addAction(pressOK)
        present(alertDisplay, animated: true, completion: nil)
    }
    
}

