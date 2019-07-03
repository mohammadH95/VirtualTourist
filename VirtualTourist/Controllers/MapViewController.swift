//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 19/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Location>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        updateMapView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    @IBAction func gestureAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began { return }
        let touchPoint = sender.location(in: mapView)
        
        let location = Location(context: dataController.viewContext)
        location.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        try? dataController.viewContext.save()
    }
    
    
    func updateMapView() {
        guard let locations = fetchedResultsController.fetchedObjects else { return }
        
        for location in locations {
            if mapView.annotations.contains(where: { location.compare(to: $0.coordinate) }) { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CollectionViewController {
            vc.location = sender as? Location
            vc.dataController = dataController
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = fetchedResultsController.fetchedObjects?.filter {
            $0.compare(to: view.annotation!.coordinate)
            }.first!
        performSegue(withIdentifier: "ShowPhoto", sender: location)
    }
}


extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMapView()
    }
}
