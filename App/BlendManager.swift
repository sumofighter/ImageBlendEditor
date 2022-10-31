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
        
        let model1 = ImageBlendModel.retroOverlay(image: image)
        let model2 = ImageBlendModel.newspaperOverlay(image: image)
        
        guard
            let m1 = model1,
            let m2 = model2
        else {
            return []
        }
        
        return [m1, m2]
    }
}
