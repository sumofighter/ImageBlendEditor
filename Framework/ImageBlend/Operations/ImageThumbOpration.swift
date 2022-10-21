import UIKit
import AVFoundation

public class ImageResizingOperation: Operation {
    let images: [UIImage]
    var completion:(([UIImage])->())?

    internal init(images: [UIImage], completion: (([UIImage]) -> ())? = nil) {
        self.images = images
        self.completion = completion
    }
    
    public override func main () {
        if isCancelled {
            return
        }
        var croppedImages:[UIImage] = []
        for image in images {
            croppedImages.append(resize(image: image))
        }
        DispatchQueue.main.async {
            self.completion?(croppedImages)
        }
    }
    
    func resize(image: UIImage) -> UIImage {
        let size = CGSize(width: kThumbCompact, height: kThumbCompact)
        
        let availableRect = AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: size))
        let targetSize = availableRect.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

//class ImageThumbBlendOperation: Operation {
//    let image: UIImage
//    let overlay: UIImage
//
//    lazy fileprivate var blendingOperations:OperationQueue = {
//        var queue = OperationQueue()
//        queue.name = "Blend queue"
//        queue.maxConcurrentOperationCount = 1
//        return queue
//    }()
//
//    init(model:ImageBlendModel) {
//        self.model = model
//        super.init()
//    }
//
//    override func main () {
//        if isCancelled {
//            return
//        }
//
//        update(model: model)
//    }
//
//    // MARK: - Private
//    public func update(model: ImageBlendModel) {
//
//        guard model.workingLayers?.count > 0 else {
//            print("No layers provided. At least 2 images needs to be provided to create blend action")
//            return
//        }
//
//        if model.size == .zero {
//            model.size = overlay.size
//        }
//
////        if let workingLayers = model.workingLayers {
////            completion(workingLayers)
////            return
////        }
////
////        var indexOfLayer:Int?
////
////        for blend in model.blends {
////
////            if workingImage == nil {
////                workingImage = select(layers)
////                indexOfLayer = layers.firstIndex(of: workingImage!)
////            }
////
////            let blendOperation = ImageBlendOperation(blend: blend, model: self)
////            operations.addOperation(blendOperation)
////
////            blendOperation.completionBlock = {
////                if blendOperation.isCancelled {
////                    completion(self.layers)
////                    return
////                }
////                if self.operations.operationCount == 0 {
////                    guard let img = self.workingImage, let index = indexOfLayer else {
////                        assertionFailure("There was an error during filter operation")
////                        return
////                    }
////                    self.readyImage = img
////                    self.workingLayers = self.layers.map {$0}
////
////                    // replace updated image at selected index
////                    self.workingLayers![index] = img
////                    completion(self.workingLayers!)
////                }
////            }
////        }
//    }
//}
