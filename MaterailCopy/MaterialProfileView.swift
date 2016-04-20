//
//  File.swift
//  MaterailCopy
//
//  Created by User on 4/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import UIKit

class MaterialProfileView: UIImageView {
    
    override func awakeFromNib() {
         super.awakeFromNib()
        
        layer.cornerRadius = 15.0
        layer.masksToBounds = true 
    }
}
