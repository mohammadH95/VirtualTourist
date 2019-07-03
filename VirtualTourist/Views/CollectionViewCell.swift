//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 19/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: Photo? {
        willSet {
            if photo != nil {
                return
            }
            
            guard let photo = newValue else { return }
            guard let url = photo.imageURL else { return }
            
            if let image = photo.imageview  {
                imageView.image = image
                return
            }
            
            activityIndicator.startAnimating()
            guard let data = try? Data(contentsOf: url) else { return }
            activityIndicator.stopAnimating()
            
            imageView.image = UIImage(data: data)
            
            photo.image = data
            try? photo.managedObjectContext?.save()
            
        }
    }
    
}
