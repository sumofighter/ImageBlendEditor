//
//  ImageBlendModel.swift
//  ImageBlendEditor
//
//  Created by beequri on 05.03.21.
//  Copyright © 2021 beequri. All rights reserved.
//

import UIKit

@objc public enum Filter:Int {
    case none
    case chrome
    case fade
    case instant
    case mono
    case noir
    case process
    case tonal
    case transfer
    case curve
    case linear
    case sepia
    case vignette
}

@objc public class ImageBlendModel:NSObject {
    
    public let images: BlendingSet
    public var thumbs: BlendingSet?
    public var name: String
    
    // Default values
    @objc public var blends: [ImageBlend] = []
    @objc public var origin: CGPoint = .zero
    @objc public var size: CGSize = .zero
    
    @objc public init(layers: [UIImage], name:String) {
        self.images = .init(layers: layers)
        self.name = name
    }
     
    @objc public func processImage(
        completion: @escaping ([UIImage])->()
    ) {
        size = images.overlay?.size ?? .zero
        let workingImage = images.layers[0]
        images.workingImage = workingImage
        
        for blend in blends {
            images.apply(filter: blend) { images in
                completion(images)
            }
        }
    }
    
    @objc public func processThumbs(
        completion: @escaping ()->()
    ) {
        
    }
    
    public override var description : String {
        return "<\(type(of: self)): 0x\(String(unsafeBitCast(self, to: Int.self), radix: 16, uppercase: false))> \(name)"
    }
}


