//
//  BlendManager.swift
//  Example
//
//  Created by beequri on 12.03.21.
//  Copyright © 2021 IGR Software. All rights reserved.
//

import UIKit
import ImageBlendEditor

class BlendManager {
    
    class func models(image:UIImage) -> [ImageBlendModel] {
        
        let manager = BlendManager()
        let model1 = ImageBlendModel.basicOverlay(image: image)
        let model2 = ImageBlendModel.retroOverlay(image: image)
        let model3 = ImageBlendModel.noiseOverlay(image: image)
        let model4 = ImageBlendModel.newspaperOverlay(image: image)
        
        guard
            let m1 = model1,
            let m2 = model2,
            let m3 = model3,
            let m4 = model4
        else {
            return []
        }
        
        return [m1, m2, m3, m4]
    }
}
