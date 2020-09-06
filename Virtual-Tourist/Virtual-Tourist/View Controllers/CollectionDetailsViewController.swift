//
//  CollectionDetailsViewController.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 15/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CollectionDetailsViewController: UIViewController,UICollectionViewDelegate {
    
    
    
    var pin:Pin!
    var collection:PhotoCollection!
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "photoCollection == %@", collection)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = collection.name
//        navigationItem.rightBarButtonItem = editButtonItem
        collectionView.dataSource = self
        collectionView.delegate = self
        setupFetchedResultsController()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
}
extension CollectionDetailsViewController: UICollectionViewDelegateFlowLayout {
    
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

extension CollectionDetailsViewController: UICollectionViewDataSource {
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedCollectionViewCell", for: indexPath) as! SavedCollectionViewCell
        
        if let photoCoreData = aPhoto.data {
            cell.imageView.image = UIImage(data: photoCoreData)
        }
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "CollectionPhotoCell") as! CollectionPhotoCell
        detailController.image = fetchedResultsController.object(at: indexPath)
        self.navigationController!.pushViewController(detailController, animated: true)
        
        
    }
    
}
extension CollectionDetailsViewController:NSFetchedResultsControllerDelegate {
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
