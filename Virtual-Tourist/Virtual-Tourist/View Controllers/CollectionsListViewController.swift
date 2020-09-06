//
//  CollectionsListViewController.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 15/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CollectionsListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of collections
    @IBOutlet weak var tableView: UITableView!
    
    var dataController:DataController!
    
    var pin:Pin!
    var collection: PhotoCollection!
    
    var fetchedResultsController:NSFetchedResultsController<PhotoCollection>!
    
    var isSaveButtonClick:Bool!
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "collections")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        if isSaveButtonClick == true {
            isSaveButtonClick = !isSaveButtonClick
            presentNewcollectionAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    
    
    
    
    //    @IBAction func addTapped(sender: Any) {
    //        presentNewcollectionAlert()
    //    }
    //
    // -------------------------------------------------------------------------
    // MARK: - Editing
    
    /// Display an alert prompting the user to name a new collection. Calls
    /// `addcollection(name:)`.
    func presentNewcollectionAlert() {
        let alert = UIAlertController(title: "New Collection", message: "Enter a name for this collection", preferredStyle: .alert)
        
        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addCollection(name: name)
            }
        }
        saveAction.isEnabled = false
        
        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    /// Adds a new collection to the end of the `collections` array
    
    
    
    func addCollection(name: String) {
        let collection = PhotoCollection(context: dataController.viewContext)
        collection.name = name
        collection.creationDate = Date()
        for _ in pin.photos! {
            
            let photo = Photo(context: dataController.viewContext)
            photo.creationDate = Date()
            photo.photoCollection = collection
            do {
                try dataController.viewContext.save()
            }
            catch{
                print("Error in saving view context change!")
            }
        }
        try? dataController.viewContext.save()
        
    }
    
    /// Deletes the collection at the specified index path
    func deletecollection(at indexPath: IndexPath) {
        let collectionToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(collectionToDelete)
        try? dataController.viewContext.save()
    }
    
    //    func updateEditButtonState() {
    //        if let sections = fetchedResultsController.sections {
    //            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
    //        }
    //    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let acollection = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionCell.defaultReuseIdentifier, for: indexPath) as! CollectionCell
        
        // Configure cell
        cell.nameLabel.text = acollection.name
        
        if let count = acollection.photos?.count {
            let photoString = count == 1 ? "photo" : "photos"
            cell.photoCountLabel.text = "\(count) \(photoString)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deletecollection(at: indexPath)
        default: () // Unsupported
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CollectionDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.collection = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController
            }
        }
    }
}

extension CollectionsListViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
