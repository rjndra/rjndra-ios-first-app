//
//  MaterialButtom.swift
//  MaterailCopy
//
//  Created by User on 4/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

import UIKit

class MaterialButton: UIButton {
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        
        layer.shadowOffset = CGSizeMake(0.0, 5.0)
        layer.shadowColor = UIColor.init(colorLiteralRed: SHADOW_COLOR , green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.7
    }
}
