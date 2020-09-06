//
//  CollectionCell.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 16/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit

internal final class CollectionCell: UITableViewCell, Cell {
    // Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoCountLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        photoCountLabel.text = nil
    }

}
