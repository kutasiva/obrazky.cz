//
//  ImageViewCell.swift
//  iHledej
//
//  Created by kutasov on 14/01/15.
//  Copyright (c) 2015 kutasov. All rights reserved.
//

import Foundation
import UIKit

var imageHeight: CGFloat = 200.0
var imageWidth: CGFloat = 200.0
var imageTopSpace: CGFloat = 10.0

class ImageViewCell: UITableViewCell {
    
    @IBOutlet weak var webLabel: UILabel!

    @IBOutlet weak var sizeLabel: UILabel!
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        //println("d = \(self.imageView?.frame)")
        if let view = imageView?.superview {
            self.imageView?.frame = CGRectMake(view.center.x - (imageHeight/2) , imageTopSpace, imageWidth, imageHeight)
        }
    }
}