//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 19/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController {
    
    var dataController:DataController!
    var location: Location!
    var pageNumber = 1
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var isDeleting = false
    var WeHavePhotos: Bool {
        if (fetchedResultsController.fetchedObjects?.count ?? 0) > 0 {
            return true
        }
        return false
    }

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollButton: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "location == %@", location)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if WeHavePhotos {
                activateIndicator(start: false)
                collectionView.reloadData()
            } else {
                getPhotos()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getPhotos() {
        activateIndicator(start: true)
        FlickerAPI.pageNumber = pageNumber
        
        FlickerAPI.getPhoto(coordinate: location.coordinate, pageNumber: pageNumber) { (urls, error) in
            DispatchQueue.main.async {
                
                guard error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                guard let urls = urls, urls.count > 0 else {
                    self.label.isHidden = false
                    return
                }
                
                self.label.isHidden = true
                
                for url in urls {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = url
                    photo.location = self.location
                    try? self.dataController.viewContext.save()
                }
                self.activateIndicator(start: false)
            }
        }
        pageNumber += 1
    }

    @IBAction func newCollAction(_ sender: Any) {
        
        if WeHavePhotos {
            isDeleting = true
            for photo in fetchedResultsController.fetchedObjects ?? [] {
                dataController.viewContext.delete(photo)
            }
            try? dataController.viewContext.save()
            isDeleting = false
        }
        
        getPhotos()
        
        
    }
    
    
    
    func activateIndicator(start: Bool) {
        collectionView.isUserInteractionEnabled = !start
        if start {
            newCollButton.title = ""
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            newCollButton.title = "New Collection"
        }
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        cell.photo = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        
        let alert = UIAlertController(title: "What to do?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            self.share(image: photo.imageview)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            self.dataController.viewContext.delete(photo)
            try? self.dataController.viewContext.save()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func share(image: UIImage?) {
        guard let image = image else { return }
        
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            if completed {
                self.alert(title: "Success", message: "saved successfully")
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    
    var numberOfItemInarow: CGFloat{
        return 3
    }
    
    var InterSpace: CGFloat{
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalInterSpace = (numberOfItemInarow - 1) * InterSpace
        
        let collectionWidth = collectionView.frame.width - totalInterSpace
        
        let itemWidth = collectionWidth/3
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}


extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !isDeleting {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = newIndexPath, type == .insert {
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
}
