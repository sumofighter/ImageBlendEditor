//
//  ImageBlendOperation.swift
//  ImageBlendEditor
//
//  Created by beequri on 10.03.21.
//  Copyright © 2021 beequri. All rights reserved.
//

import UIKit

public protocol ImageBlendOperationDelegate : AnyObject {
    
    func imageBlendOperation(_ operation: ImageBlendOperation, image didFinishBlendProcess: UIImage)
    
    func imageBlendOperationDidFailBlendOperation(_ operation: ImageBlendOperation)
}

public class ImageBlendOperation: Operation {
    
    let blend:ImageBlend
    let image:UIImage
    weak var delegate: ImageBlendOperationDelegate?
    
    init(blend:ImageBlend, image:UIImage) {
        self.blend = blend
        self.image = image
        super.init()
    }

    public override func main () {
        if isCancelled {
            return
        }
        let img = blend.apply(image: image)
        
        guard let i = img else {
            delegate?.imageBlendOperationDidFailBlendOperation(self)
            return
        }
        
        delegate?.imageBlendOperation(self, image: i)
    }
}
