import UIKit
import ImageBlendEditor

class ViewController: UIViewController {

    @IBOutlet weak fileprivate var imageView: UIImageView?
    
    fileprivate var image: UIImage!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                       target: self,
                                       action: #selector(openEdit))
        
        let libraryItem = UIBarButtonItem(barButtonSystemItem: .camera,
                                          target: self,
                                          action: #selector(openLibrary))
        
        self.navigationItem.leftBarButtonItem = libraryItem
        self.navigationItem.rightBarButtonItem = editItem
        
        if (self.image == nil) {
            openLibrary()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Funcs
    
    @objc func openLibrary() {
        let pickerView = UIImagePickerController.init()
        pickerView.delegate = self
        pickerView.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @objc func openEdit() {
        self.edit(image: self.image)
    }
    
    func edit(image: UIImage) {
        let models = BlendManager.models(image: image)
        let editorViewController = EditorViewController.instance(models: models, delegate: self)
        addChild(editorViewController)
        view.addSubview(editorViewController.view)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.image = image.fixedOrientation()
        
        picker.dismiss(animated: true) {
            self.edit(image: self.image)
        }
    }
}

extension ViewController: EditorViewControllerDelegate {
    func photoCropController(_ controller: EditorViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.imageView?.image = croppedImage
        guard let editorViewController = children.first as? EditorViewController else {
            fatalError("Unable to load EditorViewController from xib")
        }
        editorViewController.view.removeFromSuperview()
        editorViewController.removeFromParent()
    }
    
    func photoCropControllerDidCancel(_ controller: EditorViewController) {
        guard let editorViewController = children.first as? EditorViewController else {
            fatalError("Unable to load EditorViewController from xib")
        }
        editorViewController.view.removeFromSuperview()
        editorViewController.removeFromParent()
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {

        if imageOrientation == .up {
            return self
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Unknown")
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Unknown")
            break
        }

        if let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace,
            let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            ctx.concatenate(transform)

            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            if let ctxImage: CGImage = ctx.makeImage() {
                return UIImage(cgImage: ctxImage)
            } else {
                return self
            }
        } else {
            return self
        }
    }
}
