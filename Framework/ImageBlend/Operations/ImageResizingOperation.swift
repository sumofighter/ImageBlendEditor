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
            croppedImages.append(image.cropToSquare().resize())
        }
        DispatchQueue.main.async {
            self.completion?(croppedImages)
        }
    }
}

extension UIImage {
    func resize() -> UIImage {
        let size = CGSize(width: kThumbCompact, height: kThumbCompact)
        
        let availableRect = AVMakeRect(aspectRatio: size, insideRect: .init(origin: .zero, size: size))
        let targetSize = availableRect.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func cropToSquare() -> UIImage {
        var imageHeight = size.height
        var imageWidth = size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        } else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth : CGFloat = CGFloat(cgImage!.width)
        let refHeight : CGFloat = CGFloat(cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        let side = min(size.width, size.height)

        let cropRect = CGRect(x: x, y: y, width: side, height: side)
        if let imageRef = cgImage!.cropping(to: cropRect) {
            return UIImage(
                cgImage: imageRef,
                scale: 0,
                orientation: imageOrientation)
        }

        return UIImage()
    }
}
