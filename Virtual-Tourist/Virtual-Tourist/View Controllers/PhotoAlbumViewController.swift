//
//  PhotoAlbumViewController.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 02/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate {
    
    
    var dataController:DataController!
    var pin:Pin!
    var collection: PhotoCollection!

    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var getNewCollectionButton: UIButton!
    
    fileprivate func setupFetchedResulsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        }
        catch{
            fatalError("The fetch could note be performed: \(error.localizedDescription)")
        }
    }
    
    private func checkAndGet(){
        getNewCollectionButton.isEnabled = false
        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0){
            getPhotoCollection()
        }
        else {
            getNewCollectionButton.isEnabled = true
        }
    }
    private func setMapView(){
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        setupFetchedResulsController()
        checkAndGet()
        setMapView()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResulsController()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func addPhoto(url:String) {
        let photo = Photo(context: dataController.viewContext)
        photo.url = url
        photo.creationDate = Date()
        photo.pin = pin
        try? dataController.viewContext.save()
        
    }
    
    func deletePhoto(_ photo: Photo){
        dataController.viewContext.delete(photo)
        //make sure to save chnages after deletion
        do {
            try dataController.viewContext.save()
        }
        catch{
            print("Error in saving view context change!")
        }
    }
    
    private func getPhotoCollection() {
        getNewCollectionButton.isEnabled = false
        FlickerAPIClient.requestPhotos(lat: pin.lat, long: pin.long) { (photosURL,ConnectionError) in
            switch ConnectionError {
            case .connected:
                for photoURL in photosURL! {
                    self.addPhoto(url: photoURL)
                }
                break
            case .notConnected:
                DispatchQueue.main.async {
                    self.showAlert(message:  "No network connection", title: "Getting photos failed")
                }
                break
            case .connctedWithError:
                DispatchQueue.main.async {
                    self.showAlert(message:  "Try again!", title: "Getting photos failed")
                }
                break
                
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.getNewCollectionButton.isEnabled = true
            }
        }
    }
    
    
    @IBAction func updateCollection(_ sender: Any) {
        //first we delete the current collection
        if let photos = fetchedResultsController.fetchedObjects{
            for photo in photos {
                dataController.viewContext.delete(photo)
            }
            do {
                try dataController.viewContext.save()
            }
            catch{
                print("Error in saving view context change!")
            }
        }
        getPhotoCollection()
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCollectionTable") {
            let vc : CollectionsListViewController = segue.destination as! CollectionsListViewController
            vc.isSaveButtonClick = true
            vc.dataController = dataController
            vc.pin = pin
        }
    }
    
    
    
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 0, left: 2, bottom: 0, right: 2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = collectionView.bounds
        
        return CGSize(width: (bounds.width/2)-4 , height: bounds.height/2)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        
        //Cell configuration
        if let photoCoreData = aPhoto.data {
            cell.imageView.image = UIImage(data: photoCoreData)
        } else if let photoURL = aPhoto.url {
            guard let url = URL(string: photoURL) else {
                return cell
            }
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: [.transition(.fade(0.5))],progressBlock: nil){ result in
                switch result {
                case .success(let value):
                    aPhoto.data = value.image.jpegData(compressionQuality: 1)
                    try? self.dataController.viewContext.save()
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhoto(photoToDelete)
    }
    
}
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
        
    }
}

extension UIViewController {
    func showAlert(message:String, title:String){
        let alertVC = UIAlertController(title: title , message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true, completion: nil)
    }
}
