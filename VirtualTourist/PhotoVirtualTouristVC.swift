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
    var photoViewActive : Bool = false
    
    
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
        photoViewActive = true
        
        // show the user selected photos
        selectedPinPhotos = Array(mapSegueSelectedPin!.photos!) as! [Photo]
        
        //Random Photo number generated from selected Pin Photos
        let randomPhoto = Int(arc4random_uniform(UInt32(selectedPinPhotos.count)))
        
        
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
        
        photoViewActive = false
        
        // Save the context core data the pin
        mapSegueSelectedPin.photos = Set(self.selectedPinPhotos) as NSSet
        CoreDataStack.sharedInstance().saveContext()
    }
    
    
    
    
    
    
    
    
    //MARK: Collection View Delegate & DataSource
    
    //MARK: viewDidLayoutSubviews
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
            
            photosDeleted.append(collectionViewPhoto[indexPath.row])
            

        }
        
        
    } // func collectionView didSelectItemAt ends
    
    

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
