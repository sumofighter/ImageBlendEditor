//
//  LayerSet.swift
//  ImageBlendEditor
//
//  Created by Piotr on 21.10.22.
//  Copyright © 2022 beequri. All rights reserved.
//

import UIKit

public class BlendingSet {
    public let layers: [UIImage] // Top layer is represented by first image
    public var workingLayers: [UIImage] = [] // Working copy of layers
    public var workingImage: UIImage?
    public var readyImage: UIImage?
    
    lazy fileprivate var operations:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Filter queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public var overlay: UIImage? {
        layers.first
    }
    
    internal init(layers: [UIImage]) {
        self.layers = layers
    }
    
    public func apply(filter: ImageBlend, completion: @escaping ([UIImage])->()) {
        
        // If the working layers are present, the filter process was already applied
        // Do not apply filters again
        if workingLayers.count > 0 {
            completion(workingLayers)
            return
        }
        
        guard let workingImage = workingImage, let indexOfLayer:Int = layers.firstIndex(of: workingImage) else {
            print("No working image defined.")
            return
        }
        
        guard layers.count > 1 else {
            print("No layers provided. At least 2 images needs to be provided to create blend action")
            return
        }
        
        
        let blendOperation = ImageBlendOperation(blend: filter, image: workingImage)
        blendOperation.delegate = self
        operations.addOperation(blendOperation)
        
        blendOperation.completionBlock = {
            if blendOperation.isCancelled {
                completion(self.layers)
                return
            }
            if self.operations.operationCount == 0 {
                guard let img = self.workingImage else {
                    assertionFailure("There was an error during filter operation")
                    return
                }
                self.readyImage = img
                self.workingImage = nil
                
                // copy all layers to working layers
                self.workingLayers = self.layers.map {$0}
                // replace updated image at selected index
                self.workingLayers[indexOfLayer] = img
                
                completion(self.workingLayers)
            }
        }
    }
}

extension BlendingSet: ImageBlendOperationDelegate {
    public func imageBlendOperationDidFail(_ operation: ImageBlendOperation) {
        print("Failed blending process")
    }
    
    public func imageBlendOperationDidCancel(_ operation: ImageBlendOperation) {
        print("Cancelled blending process")
    }
    
    public func imageBlendOperation(_ operation: ImageBlendOperation, image: UIImage) {
        workingImage = image
    }
}
