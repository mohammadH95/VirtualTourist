//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 26/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import Foundation
import UIKit


extension Photo {
    
    var imageview: UIImage? {
        guard let data = image else {
            return nil
        }
        return UIImage(data: data)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func set(image: UIImage) {
        self.image = image.pngData()
    }
    
    func getImage() -> UIImage? {
        return (image == nil) ? nil : UIImage(data: image!)
    }
    
    
}

