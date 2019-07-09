//
//  Extinsion.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 06/11/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .cancel, handler:   nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

