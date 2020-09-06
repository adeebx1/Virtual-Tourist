//
//  Cell.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 16/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import UIKit

protocol Cell: class {
    /// A default reuse identifier for the cell class
    static var defaultReuseIdentifier: String { get }
}

extension Cell {
    static var defaultReuseIdentifier: String {
        return "\(self)"
    }
}
