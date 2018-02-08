//
//  CustomTextField.swift
//  MemeMe1.0
//
//  Created by Raphael Araújo on 2018-02-07.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.attributedText = self.strokeText()
    }
    
    override var text: String? {
        didSet {
            self.attributedText = self.strokeText()
        }
    }
    
    func strokeText() -> NSAttributedString {
         let textAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeWidth : -3.0,
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            ]
        
        return NSAttributedString(string: self.text!, attributes: textAttributes)
    }
}
