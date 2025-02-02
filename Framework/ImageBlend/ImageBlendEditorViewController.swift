//
//  PhotoCropEditorViewController.swift
//  PhotoCrop
//
//  Created by beequri on 04.04.20.
//  Copyright © 2020 beequri. All rights reserved.
//

import UIKit

@objc public protocol ImageBlendEditorViewControllerDelegate : AnyObject {
    
    /**
     Called on image cropped.
     */
    @objc func imageBlendController(_ controller: ImageBlendEditorViewController, didFinishWithCroppedImage croppedImage: UIImage)
    
    /**
     Called on cropping image canceled
     */
    @objc func imageBlendControllerDidCancel(_ controller: ImageBlendEditorViewController)
}

@objc public class ImageBlendEditorViewController: UIViewController {
    
    public weak var delegate:ImageBlendEditorViewControllerDelegate?
    private var models: [ImageBlendModel] = []
    
    @objc public var image: UIImage?
    @objc public var overlayImage: UIImage?
    
    @IBOutlet weak var thumbLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var hCollectionView: UICollectionView?
    @IBOutlet weak var vCollectionView: UICollectionView?
    @IBOutlet var circularIndicatorViews: [CircularAngleIndicator]!
    @IBOutlet weak fileprivate var photoCropView: UIView!
    @IBOutlet weak fileprivate var placeholderView: UIView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet fileprivate var angleLabels: [UILabel]?
    @IBOutlet fileprivate var croppingDials:[BaseCroppingDial]? {
        didSet {
            croppingDials?.forEach { $0.migneticOption = .none }
        }
    }
    
    lazy fileprivate var resizingOperations:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Resizing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy fileprivate var thumbsBlendingOperations:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Thumbs blending queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var imageBlendViewController: ImageBlendViewController = {
        guard let imgBlendViewController = children.first as? ImageBlendViewController else {
            fatalError("Unable to load ImageBlendViewController from xib")
        }
        imgBlendViewController.delegate = self
        return imgBlendViewController
    }()
    
    var currentCircularIndicatorView: CircularAngleIndicator? {
        if circularIndicatorViews.first?.isHidden == false {
            return circularIndicatorViews.first
        }
        return circularIndicatorViews.last
    }
    
    // MARK: - Life Cycle
    
    @objc class public func instance(delegate: ImageBlendEditorViewControllerDelegate?, models: [ImageBlendModel]) -> ImageBlendEditorViewController {
        
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "ImageBlendEditorViewController", bundle: bundle)
        
        guard let photoCropEditorViewController = storyboard.instantiateInitialViewController() as? ImageBlendEditorViewController else {
            fatalError("Unable to load ImageBlendEditorViewController xib")
        }
        photoCropEditorViewController.delegate = delegate
        photoCropEditorViewController.models = models
        
        return photoCropEditorViewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ImageBlendEditorCollectionViewCell", bundle: Bundle(for: self.classForCoder))
        hCollectionView?.register(nib, forCellWithReuseIdentifier: "cell")
        vCollectionView?.register(nib, forCellWithReuseIdentifier: "cell")
        
        guard models.isEmpty == false else {
            return
        }
        currentCircularIndicatorView?.angle = 0
        photoCropView.alpha = 0
        
        // Fetch default model
        applyModel(at: 0)
        
        // Prepare thumbnails
        prepareThumbs()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.setupAngleLabelValue(radians: 0)
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
        }) { (context) in
            
        }
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.setupAngleLabelValue(radians: 0)
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
        }) { (context) in
            
        }
    }
    
    // MARK: Public
    
    @objc public func applyModel(at index: Int) {
        photoCropView.alpha = 0
        placeholderView.isHidden = false
        imageLoadingIndicator.isHidden = false
        imageLoadingIndicator.startAnimating()
        
        // Fetch default model
        let model = models[index]
        
        model.processImage { images in
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.overlayImage = images[0]
                self.image = images[1]
                self.imageBlendViewController.overlayImage = images[0]
                self.imageBlendViewController.image = images[1]
                self.imageBlendViewController.setupSubviews()
                
                self.croppingDials?.forEach { $0.value = 0.0 }
                self.setupAngleLabelValue(radians: 0.0)
                self.imageBlendViewController.refresh()
                self.imageLoadingIndicator.stopAnimating()
                self.imageLoadingIndicator.isHidden = true
                self.placeholderView.isHidden = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.photoCropView.alpha = 1.0
                })
            })
        }
    }
    
    @objc public func rotateLeft(completion: (()->())?) {
        rotate(angle: CGFloat.pi / -2, completion: completion)
    }
    
    @objc public func rotateRight(completion: (()->())?) {
        rotate(angle: CGFloat.pi / 2, completion: completion)
    }
    
    fileprivate func rotate(angle: CGFloat, completion: (()->())?) {
        UIView.animate(withDuration: 0.25) {
            self.imageBlendViewController.resetView()
        } completion: { _ in
            self.resetPlaceholder()
            let scale = self.imageBlendViewController.photoView.scale()
            let img = self.imageBlendViewController.photoView.photoContentView.takeScreenshot()
            self.placeholderImageView.image = img
            
            var t = CGAffineTransform.identity
            UIView.animate(withDuration: 0.3) {
                t = t.rotated(by: angle)
                t = t.scaledBy(x: scale, y: scale)
                self.placeholderImageView.transform = t
            } completion: { _ in
                completion?()
            }
        }
    }
    
    @objc public func finalizeRotation() {
        
        UIView.animate(withDuration: 0.5) {
            self.placeholderView.alpha = 0
        } completion: { _ in
            self.placeholderView.isHidden = true
        }
    }
    
    @objc public func dismissAction() {
        imageBlendViewController.dismissAction()
    }
    
    @objc public func cropAndBlend() {
        imageBlendViewController.cropAction()
    }
    
    // MARK: - Private
    
    fileprivate func resetPlaceholder() {
        var t = CGAffineTransform.identity
        t = t.rotated(by: 0)
        t = t.scaledBy(x: 1, y: 1)
        placeholderImageView.transform = t
        placeholderImageView.frame = imageBlendViewController.photoView.cropView.frame

        placeholderView.isHidden = false
        placeholderView.alpha = 1
    }
    
    fileprivate func setupAngleLabelValue(radians: CGFloat) {
        let intDegrees: Int = Int(RadianAngle.toDegrees(radians))
        self.angleLabels?.forEach { $0.text = "\(intDegrees)°" }
    }
    
    fileprivate func prepareThumbs() {
        
        hCollectionView?.alpha = 0
        vCollectionView?.alpha = 0
        
        hCollectionView?.isHidden = true
        vCollectionView?.isHidden = true
        
        thumbLoadingIndicator.startAnimating()
        thumbLoadingIndicator.isHidden = false
        thumbLoadingIndicator.alpha = 0
        
        UIView.animate(withDuration: 0.1) {
            self.thumbLoadingIndicator.alpha = 1
        } completion: { _ in
            self.hCollectionView?.isHidden = false
            self.vCollectionView?.isHidden = false
            
            let resizeOperation = ImageResizingOperation(images: self.models[0].images.layers)
            resizeOperation.completion = { images in
                
                for model in self.models {
                    model.thumbs = BlendingSet(layers: images)
                }
                
                let blendingOperation = ThumbsBlendingOperation(blendModels: self.models, image: images[1]) {
                    UIView.animate(withDuration: 0.2, delay: 1.5) {
                        self.hCollectionView?.alpha = 1
                        self.vCollectionView?.alpha = 1
                        self.thumbLoadingIndicator.alpha = 0
                    } completion: { _ in
                        self.thumbLoadingIndicator.isHidden = false
                        self.hCollectionView?.reloadData()
                        self.vCollectionView?.reloadData()
                    }
                }
                self.thumbsBlendingOperations.addOperation(blendingOperation)
            }
            self.resizingOperations.addOperation(resizeOperation)
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onChandeAngleSliderValue(_ sender: UISlider) {
        let radians: CGFloat = CGFloat(sender.value)
        setupAngleLabelValue(radians: radians)
        imageBlendViewController.changeAngle(radians: radians)
    }
    
    @IBAction func onEndTouchAngleControl(_ sender: UIControl) {
        imageBlendViewController.stopChangeAngle()
    }
    
    @IBAction func onTouchResetButton(_ sender: UIButton) {
        
        croppingDials?.forEach { $0.value = 0.0 }
        setupAngleLabelValue(radians: 0.0)
        
        imageBlendViewController.resetView()
    }
}

extension ImageBlendEditorViewController: CroppingDialDelegate {
    public func croppingDialDidValueChanged(_ baseCroppingDial: BaseCroppingDial) {
        let degrees = baseCroppingDial.value
        let radians = RadianAngle.toRadians(CGFloat(degrees))
        
        let dg:Double
        
        if degrees < 0 {
            currentCircularIndicatorView?.clockwise = false
            dg = abs(degrees) * 2
        } else {
            currentCircularIndicatorView?.clockwise = true
            dg = degrees * 2
        }
        
        currentCircularIndicatorView?.change(toAngle: dg)
        
        setupAngleLabelValue(radians: radians)
        imageBlendViewController.changeAngle(radians: radians)
    }
    
    public func croppingDialDidEndScroll(_ baseCroppingDial: BaseCroppingDial) {
        imageBlendViewController.stopChangeAngle()
    }
}

extension ImageBlendEditorViewController: ImageBlendViewControllerDelegate {
    public func photoTweaksController(_ controller: ImageBlendViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        
        guard let overlayImage = overlayImage else {
            delegate?.imageBlendController(self, didFinishWithCroppedImage: croppedImage)
            return
        }
        
        // Blend 2 images
        let finalImage = croppedImage.overlayWith(image: overlayImage, posX: 0, posY: 0)
        delegate?.imageBlendController(self, didFinishWithCroppedImage: finalImage)
    }
    
    public func photoTweaksControllerDidCancel(_ controller: ImageBlendViewController) {
        delegate?.imageBlendControllerDidCancel(self)
    }
}

extension  ImageBlendEditorViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageBlendEditorCollectionViewCell
        cell.imageView.image = models[indexPath.row].thumbs?.readyImage
        // TODO: Implement
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        applyModel(at: indexPath.row)
    }
    
}

extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}


