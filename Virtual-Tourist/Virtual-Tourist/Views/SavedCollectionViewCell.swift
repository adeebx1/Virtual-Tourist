//
//  SavedCollectionViewCell.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 16/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit


class SavedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil

    }
    
}
