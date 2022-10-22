//
//  ImageBlendOperation.swift
//  ImageBlendEditor
//
//  Created by beequri on 10.03.21.
//  Copyright © 2021 beequri. All rights reserved.
//

import UIKit

public class ThumbsBlendingOperation: Operation {
    
    let blendModels: [ImageBlendModel]
    let image:UIImage
    var completion: (()->())?
    
    lazy fileprivate var operations:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Blending model queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(blendModels: [ImageBlendModel], image:UIImage, completion: (()->())? = nil) {
        self.blendModels = blendModels
        self.image = image
        self.completion = completion
        super.init()
    }

    public override func main () {
        if isCancelled {
            return
        }
        
        for blendModel in blendModels {
            // For each blend model fresh working image
            
            let blendOperation = ThumbsBlendingProcess(
                blendModel: blendModel,
                image: image
            )
            blendOperation.delegate = self
            operations.addOperation(blendOperation)
            
            blendOperation.completionBlock = {
                if blendOperation.isCancelled {
                    DispatchQueue.main.async {
                        self.completion?()
                    }
                    return
                }
                
                if self.operations.operationCount == 0 {
                    DispatchQueue.main.async {
                        self.completion?()
                    }
                    return
                }
            }
        }
    }
}

extension ThumbsBlendingOperation: ThumbsBlendingProcessDelegate {
    
    func thumbsBlendingProcess(_ operation: ThumbsBlendingProcess, image didFinishBlendProcess: UIImage) {
        print("Thumb Blending Process did finish processing image")
    }
    
    func thumbsBlendingProcessDidFinishAllProcesses(_ operation: ThumbsBlendingProcess, image didFinishBlendProcess: UIImage) {
        print("Thumb Blending Process did finish all processes")
    }
    
    func thumbsBlendingProcessDidFail(_ operation: ThumbsBlendingProcess) {
        print("Thumb Blending Process did fail")
    }
    
    func thumbsBlendingProcessDidCancel(_ operation: ThumbsBlendingProcess) {
        print("Thumb Blending Process did cancel")
    }
    
}

protocol ThumbsBlendingProcessDelegate: AnyObject {
    
    func thumbsBlendingProcess(_ operation: ThumbsBlendingProcess, image didFinishBlendProcess: UIImage)
    
    func thumbsBlendingProcessDidFinishAllProcesses(_ operation: ThumbsBlendingProcess, image didFinishBlendProcess: UIImage)
    
    func thumbsBlendingProcessDidFail(_ operation: ThumbsBlendingProcess)
    
    func thumbsBlendingProcessDidCancel(_ operation: ThumbsBlendingProcess)
}

public class ThumbsBlendingProcess: Operation {
    
    let blendModel: ImageBlendModel
    var image:UIImage
    weak var delegate: ThumbsBlendingProcessDelegate?
    
    lazy fileprivate var operations:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Blend model queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(blendModel: ImageBlendModel, image:UIImage) {
        self.blendModel = blendModel
        self.image = image
        super.init()
    }

    public override func main () {
        if isCancelled {
            self.delegate?.thumbsBlendingProcessDidCancel(self)
            return
        }
        
        for blend in blendModel.blends {
            DispatchQueue.main.async {
                self.apply(filter: blend, image: self.image) { img in
                    self.image = img
                }
            }
        }
    }
    
    public func apply(filter: ImageBlend, image: UIImage, completion: @escaping (UIImage)->()) {
        
        let blendOperation = ImageBlendOperation(blend: filter, image: image)
        blendOperation.delegate = self
        operations.addOperation(blendOperation)
        
        blendOperation.completionBlock = {
            if blendOperation.isCancelled {
                self.delegate?.thumbsBlendingProcessDidCancel(self)
                return
            }
            
            self.delegate?.thumbsBlendingProcess(self, image: self.image)
            
            if self.operations.operationCount == 0 {
                self.blendModel.thumbs?.readyImage = self.image
                self.delegate?.thumbsBlendingProcessDidFinishAllProcesses(self, image: self.image)
                return
            }
        }
    }
}

extension ThumbsBlendingProcess: ImageBlendOperationDelegate {
    public func imageBlendOperation(_ operation: ImageBlendOperation, image: UIImage) {
        self.image = image
    }
    
    public func imageBlendOperationDidFail(_ operation: ImageBlendOperation) {
        print("Image Blend Operation did fail")
    }
    
    public func imageBlendOperationDidCancel(_ operation: ImageBlendOperation) {
        print("Image Blend Operation did cancel")
    }
}
