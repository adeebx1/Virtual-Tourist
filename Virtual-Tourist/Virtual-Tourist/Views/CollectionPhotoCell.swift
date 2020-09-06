//
//  CollectionPhotoCell.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 14/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit

class CollectionPhotoCell:  UIViewController {
    
    var image: Photo!
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Life Cycle
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.tabBarController?.tabBar.isHidden = true
        self.imageView!.image = UIImage(data: image.data!)
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           self.tabBarController?.tabBar.isHidden = false
       }
       
    
}
