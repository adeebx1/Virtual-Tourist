//
//  MapViewController.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 02/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    private func loadPins(){
        if let pins = fetchedResultsController.fetchedObjects{
            mapView.addAnnotations(pins)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        loadPins()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            newPin(lat: locationOnMap.latitude, long: locationOnMap.longitude)
        }
        
    }
    
    func newPin(lat:Double, long:Double){
        let pin = Pin(context: dataController.viewContext)
        pin.creationDate = Date()
        pin.lat = lat
        pin.long = long
        try? dataController.viewContext.save()
    }
    
}

extension MapViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let view = MKCircleRenderer(overlay: overlay)
            view.fillColor = UIColor.black.withAlphaComponent(0.2)
            return view
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    // MARK: - Navigation
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
        mapView.deselectAnnotation(view.annotation! , animated: true)
        let pin: Pin = view.annotation as! Pin
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController;
        
        photoAlbumVC.pin = pin
        photoAlbumVC.dataController = dataController
        
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
}
extension MapViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("This is not a PIN!")
        }
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            break
        default: ()
        }
        
    }
}

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}

