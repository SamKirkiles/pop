//
//  SelectPhotoCollectionViewController.swift
//  POP
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
let BlankCanvasReuseIdentifier = "BlankCanvasID"
let HeaderReuseId = "reuseHeader"

protocol SelectPhotoDelegate {
    func sendPhoto(photo:UIImage)
    func requestStyle(presentationStyle:MSMessagesAppPresentationStyle)
}

class SelectPhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SendImageDelegate, TransitionDelegate, CameraDelegate, PresentationStyleDelegate, RequestAccessDelegate, SelectedImageDelegate, BlankCanvasDelegate{
    
    var delegate:SelectPhotoDelegate? = nil
    
    var transitionDelegate: TransitionDelegate? = nil
    var presentationStyleDelegate: PresentationStyleDelegate? = nil
    
    var photosFetchAsset:PHFetchResult<PHAsset>?
    
    
    var cellSize:CGFloat = 100
    
    let buttonSize:CGFloat = 60
    var settingsButton:UIButton?
    
    
    override func viewDidAppear(_ animated: Bool) {
        if PHPhotoLibrary.authorizationStatus() == .authorized{
        }else{
            print("not authorized")
            self.performSegue(withIdentifier: RequestAccessSegueID, sender: self)
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateCollectionViewInsets(preferredSize: size,transitioning: false)
    }
    
    
    func updateCollectionViewInsets(preferredSize: CGSize?,transitioning: Bool){
        // set the height of the table view
        
        
        guard let delegate = self.presentationStyleDelegate else {
            fatalError("Transition delegate not assigned!")
        }
        
        
        var size:CGSize
        
        if  preferredSize != nil{
            size = preferredSize!
        }else{
            size = self.view.frame.size
        }
        
        
        
        self.collectionView?.contentInset = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        self.collectionView?.scrollIndicatorInsets = LayoutManager.getEdgeInsets(size: size, style: delegate.getPresentationStyle())
        
        if self.collectionView?.contentOffset == CGPoint(x:0,y:0) || transitioning{
            self.collectionView?.contentOffset = CGPoint(x: 0, y: -LayoutManager.getTopInsetAmount(size: size, style: delegate.getPresentationStyle()))
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photosFetchAsset = self.fetchPhotos()
        
        updateCollectionViewInsets(preferredSize: nil,transitioning: false)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RequestAccessSegueID{
            let requestController = segue.destination as! RequestAccessToPhotosViewController
            self.transitionDelegate = requestController
            requestController.delegate = self
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        guard let fetchAssetCount = self.photosFetchAsset?.count else{
            fatalError("fetchAssetCount was nil")
        }
        
        return fetchAssetCount + 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCellReuseIdentifier, for: indexPath)
            
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 5.0
            
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 5.0
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            return cell
        }else if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlankCanvasReuseIdentifier, for: indexPath)
            
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 5.0
            
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 5.0
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            return cell
            
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath) as! PhotoCollectionViewCell
            
            
            guard let fetchAssets = self.photosFetchAsset else{
                fatalError("fetched assets was nil!!")
            }
            
            cell.imageView.image = nil
            
            let asset = fetchAssets.object(at: indexPath.row-2)
            cell.asset = asset
            
            DispatchQueue.global().async {
                asset.requestThumbnailImage(imageResults: {newImage,info in
                    guard let image = newImage else{
                        return
                    }
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        
                    }
                })
            }
            
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 5.0
            
            cell.layer.masksToBounds = false
            cell.layer.cornerRadius = 5.0
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.shouldRasterize = true
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else{
            fatalError("Cell returned nil!")
        }
        
        
        if cell is PhotoCollectionViewCell{
            
            guard let delegate = self.delegate else{
                fatalError("delegate was nil for select photo controller")
            }
            delegate.requestStyle(presentationStyle: MSMessagesAppPresentationStyle.expanded)
            
            let photoCell = cell as! PhotoCollectionViewCell
            let drawController = storyboard?.instantiateViewController(withIdentifier: DrawViewControllerStoryboardID) as! DrawViewController
            drawController.sendImageDelegate = self
            self.transitionDelegate = drawController
            drawController.presentationStyleDelegate = self
            
            photoCell.asset?.requestFullImage(imageResults: { (newImage, info) in
                guard let image = newImage else{
                    
                    let alert = UIAlertController(title: "Couldn't load photo", message: "There was a problem loading the photo from the camera roll.", preferredStyle: UIAlertControllerStyle.alert)
                    let confirm = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil);
                    })
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: {
                        print("Couldn't load images presenting error");
                    })
                    return;
                };
                

                
                drawController.image = image
                drawController.verifyImage()
            })
            
            

            
            self.present(drawController, animated: true, completion: {
                //present completed
                drawController.verifyImage()
            })
            
            
            
        }else if indexPath.row == 0{
            let cameraController = storyboard?.instantiateViewController(withIdentifier: CameraVCStoryboardID) as! CameraViewController
            cameraController.delegate = self
            self.transitionDelegate = cameraController
            
            guard let delegate = self.delegate else{
                fatalError("delegate was nil for select photo controller")
            }
            delegate.requestStyle(presentationStyle: MSMessagesAppPresentationStyle.expanded)
            
            self.present(cameraController, animated: true, completion: {
            })
        }else{
            let blankCanvas = storyboard?.instantiateViewController(withIdentifier: BlankCanvasReuseIdentifier) as! BlankCanvasViewController
            self.transitionDelegate = blankCanvas
            blankCanvas.delegate = self
            self.present(blankCanvas, animated: true, completion: {
                //presented
            })
        }
    }
    
    //MARK: - SelectedImageDelegate
    func conversationWillSelectImage() {
        DispatchQueue.main.async {
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false, completion: nil)
            }else{
            }
            let drawController = self.storyboard?.instantiateViewController(withIdentifier: DrawViewControllerStoryboardID) as! DrawViewController
            drawController.sendImageDelegate = self
            self.transitionDelegate = drawController
            drawController.presentationStyleDelegate = self
            self.present(drawController, animated: false, completion: {
                //present completed
            })
        }
        
    }
    
    func conversationProgressUpdated(progress:Double){
        DispatchQueue.main.async {
            if self.presentedViewController is DrawViewController{
                let controller = self.presentedViewController as! DrawViewController
                controller.progressView.setProgress(Float(progress), animated: true)
            }
        }
    }
    
    func conversationSaveError(error: Error) {
        DispatchQueue.main.async {
            print(error)
            let controller = UIAlertController(title: "Uh oh! Couldn't Send", message: "Make sure you're connected to wifi and iCloud Drive enabled in Settings > iCloud > iCloud Drive > iCloud Drive ON", preferredStyle: .alert)
            let button = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
            })
            controller.addAction(button)
            self.presentedViewController?.present(controller, animated: true, completion: nil)
        }
    }
    
    func conversationBeganSaving() {
        DispatchQueue.main.async {
            if self.presentedViewController is DrawViewController{
                let controller = self.presentedViewController as! DrawViewController
                controller.progressView.isHidden = false
                controller.sendButton.isEnabled = false
            }
        }
    }
    func conversationEndedSaving() {
        DispatchQueue.main.async {
            if self.presentedViewController is DrawViewController{
                let controller = self.presentedViewController as! DrawViewController
                controller.sendButton.isEnabled = true
                controller.progressView.isHidden = true
                controller.progressView.setProgress(0, animated: false)
            }
        }
        
    }
    
    func conversationImageError() {
        DispatchQueue.main.async {
            
            let controller = UIAlertController(title: "Oops!", message: "We couldn't load your POP photo from the iCloud servers... Make sure iCloud Drive is enabled and wifi is on", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default) { (action) in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
                self.delegate!.requestStyle(presentationStyle: .compact)
            }
            controller.addAction(okButton)
            self.presentedViewController?.present(controller, animated: true, completion: {
                
            })
        }
    }
    
    func conversationDidSelectImage(image: UIImage) {
        if self.presentedViewController is DrawViewController{
            let controller = self.presentedViewController as! DrawViewController
            controller.image = image
            controller.verifyImage()
            controller.contentView.isUserInteractionEnabled = false
        }else{
        }
    }
    
    func didChooseImage(image: UIImage) {
        self.collectionView?.isUserInteractionEnabled = false
        self.dismiss(animated: false, completion: {
            
        })
        let drawController = storyboard?.instantiateViewController(withIdentifier: DrawViewControllerStoryboardID) as! DrawViewController
        drawController.image = image
        drawController.sendImageDelegate = self
        drawController.presentationStyleDelegate = self
        self.transitionDelegate = drawController
        self.present(drawController, animated: false, completion: {
            self.collectionView?.isUserInteractionEnabled = true
        })
    }
    
    func didChooseBlankCanvas(type: BlankCanvasType) {
        
        self.collectionView?.isUserInteractionEnabled = false
        self.dismiss(animated: false, completion: {
            
        })
        
        let drawController = storyboard?.instantiateViewController(withIdentifier: DrawViewControllerStoryboardID) as! DrawViewController
        
        if type == .square{
            drawController.image = #imageLiteral(resourceName: "Blank Canvas Square")
        }else if type == .portrait{
            drawController.image = #imageLiteral(resourceName: "Blank Canvas Portrait")
        }else{
            drawController.image = #imageLiteral(resourceName: "Blank Cavnas Landscape")
        }
        
        drawController.sendImageDelegate = self
        drawController.presentationStyleDelegate = self
        self.transitionDelegate = drawController
        self.present(drawController, animated: false, completion: {
            self.collectionView?.isUserInteractionEnabled = true
            self.delegate?.requestStyle(presentationStyle: .expanded)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Get the number of cells that fit diagonally
        let cellNumber = floor(Float((self.collectionView?.frame.size.width)! - 10)/Float(cellSize))
        
        // Get the size of all these cells combined without spacing
        let cellCombinedSize = cellNumber * Float(cellSize)
        
        
        let remainder = (((self.collectionView?.frame.size.width)! - 20 - (10
            * CGFloat(cellNumber))) - CGFloat(cellCombinedSize))
        
        return CGSize(width: cellSize + (remainder / CGFloat(cellNumber)), height: cellSize + (remainder / CGFloat(cellNumber)))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // MARK: Fetching Photos
    
    func fetchPhotos() -> PHFetchResult<PHAsset>{
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let photos = PHAsset.fetchAssets(with: .image, options: options)
        return photos
    }
    
    //MARK: Send photo Delegate
    
    func sendImage(image: UIImage) {
        if let delegate = self.delegate{
            delegate.sendPhoto(photo: image)
        }else{
            fatalError("Delegate was nil!")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: HeaderReuseId,for: indexPath)
            return headerView
        default:
            //4
            fatalError("kind was not found")
        }
        
    }
    
    //MARK: Transition Delegate
    
    func didTransition(presentationStyle: MSMessagesAppPresentationStyle) {
        
        updateCollectionViewInsets(preferredSize: nil,transitioning: true)
        
        if let delegate = self.transitionDelegate{
            delegate.didTransition(presentationStyle: presentationStyle)
        }else{
        }
        
    }
    
    //MARK: Presentation Style
    
    func getPresentationStyle() -> MSMessagesAppPresentationStyle {
        guard let delegate = self.presentationStyleDelegate else{
            fatalError("Prsenationstyledelegate was nill on Selectphotoviewcontroller")
        }
        
        return delegate.getPresentationStyle()
    }
    
    func requestStyle(style: MSMessagesAppPresentationStyle) {
        guard let delegate = self.delegate else{
            fatalError("delegate was nil for select photo controller")
        }
        delegate.requestStyle(presentationStyle: style)
        
    }
    
    func photosAuthorized() {
        self.photosFetchAsset = fetchPhotos()
        
        self.collectionView?.reloadData()
    }
    
    func isCameraType() -> Bool {
        return false
    }
    
}

extension PHAsset{
    
    func requestThumbnailImage(imageResults: @escaping (UIImage?, [NSObject : AnyObject]?) -> Void){
        
        let retinaScale = UIScreen.main.scale
        let imageManager = PHCachingImageManager();
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        options.isSynchronous = true
        options.version = .current
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100 * retinaScale, height:100 * retinaScale), contentMode: .aspectFill, options: options, resultHandler: {newImage,info in
            imageResults(newImage, info as [NSObject : AnyObject]?)
        })
    }
    
    
    func requestFullImage(imageResults: @escaping (UIImage?, [NSObject : AnyObject]?) -> Void){
        let imageManager = PHCachingImageManager();
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options, resultHandler: {newImage,info in
            imageResults(newImage, info as [NSObject : AnyObject]?)
        })
    }
}
