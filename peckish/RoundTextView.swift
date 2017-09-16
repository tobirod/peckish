//
//  RoundTextView.swift
//  peckish
//
//  Created by Tobias on 2017-09-16.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextView: UITextView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
