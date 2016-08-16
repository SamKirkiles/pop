//
//  PhotoCollectionViewCell.swift
//  pop
//
//  Created by Sam Kirkiles on 8/15/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Photos

let PhotoCellIdentifier = "PhotoCell"

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var asset: PHAsset?
    
}
