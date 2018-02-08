//
//  Meme.swift
//  MemeMe1.0
//
//  Created by Raphael Araújo on 2018-02-07.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import Foundation
import UIKit
struct Meme {
    var topText: NSAttributedString?
    var bottomText: NSAttributedString?
    var originalImage: UIImage?
    var image: UIImage?
    var topTextPosition: CGPoint = CGPoint(x: 0, y: 0)
    var bottomTextPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    init(texts: [String: NSAttributedString], toImage image: UIImage, withImageSize imageSize: CGSize, atPositions positions: [String: CGPoint]){

        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        
        image.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
        
        if let topText = texts["top"] {
            if let topP = positions["top"] {
                self.topTextPosition = topP
            }
            self.topText = topText
            let rect = CGRect(origin: self.topTextPosition, size: imageSize)
            self.topText!.draw(in: rect)
        }
        
        if let bottomText = texts["bottom"] {
            if let bottomP = positions["bottom"] {
                self.bottomTextPosition = bottomP
            }
            self.bottomText = bottomText
            let rect = CGRect(origin: self.bottomTextPosition, size: imageSize)
            self.bottomText!.draw(in: rect)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = newImage
        self.originalImage = image
    }
}
