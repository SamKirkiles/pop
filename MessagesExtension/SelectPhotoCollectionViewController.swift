//
//  SelectPhotoCollectionViewController.swift
//  pop
//
//  Created by Sam Kirkiles on 8/14/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit
import Messages
import Photos

private let reuseIdentifier = "Cell"

let SelectPhotoCollectionViewSegue = "SelectPhotoSegue"
let SelectPhotoCollectionViewIdentifier = "SelectPhotoID"

let CameraCellReuseIdentifier = "CameraCellID"

class SelectPhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var photosFetchAsset:PHFetchResult<PHAsset>{
        get{
            return fetchPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
            let count = photosFetchAsset.count
            return count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCellReuseIdentifier, for: indexPath)
            
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 3.0
            
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 3.0
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath) as! PhotoCollectionViewCell
            
            
            let asset = photosFetchAsset.object(at: indexPath.row-1)
            cell.asset = asset
            
            asset.requestThumbnailImage(imageResults: {newImage,info in
                guard let image = newImage else{
                    fatalError("newImage was nil")
                }
                cell.imageView.image = image
            })
            
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 3.0
            
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 3.0
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

            
            return cell

        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else{
            fatalError("Cell returned nil!")
        }
        
        if cell is PhotoCollectionViewCell{
            let photoCell = cell as! PhotoCollectionViewCell
            
            let drawController = storyboard?.instantiateViewController(withIdentifier: DrawViewControllerStoryboardID) as! DrawViewController
            
            photoCell.asset?.requestFullImage(imageResults: { (newImage, info) in
                guard let image = newImage else{
                    fatalError("newImage was nil")
                }
                drawController.image = image

                self.present(drawController, animated: true, completion: {
                    //present completed
                })
            })
        }else{
            fatalError("Cell was not PhotoCollectionViewCell")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:90,height:90);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }



    // MARK: Fetching Photos
    
    func fetchPhotos() -> PHFetchResult<PHAsset>{
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let photos = PHAsset.fetchAssets(with: .image, options: options)
        return photos
    }


}

extension PHAsset{
    
    func requestThumbnailImage(imageResults: (UIImage?, [NSObject : AnyObject]?) -> Void){
        let imageManager = PHCachingImageManager();
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: options, resultHandler: {newImage,info in
            imageResults(newImage, info)
        })
    }

    
    func requestFullImage(imageResults: (UIImage?, [NSObject : AnyObject]?) -> Void){
        let imageManager = PHCachingImageManager();
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options, resultHandler: {newImage,info in
            imageResults(newImage, info)
        })
    }
}
