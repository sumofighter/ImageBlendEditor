import UIKit

public extension ImageBlendModel {
    static func retroOverlay(image: UIImage) -> ImageBlendModel? {
        guard
            let overlayImage = UIImage(named: "overlay_1", in: Bundle.this, with: nil)
        else {
            return nil
        }
        
        let layers = [overlayImage, image]
        let model = ImageBlendModel(layers: layers, name: "retro overlay")
        
        let filter = ImageBlend(action: .filter)
        filter.filter = .sepia
        
        let brightness = ImageBlend(action: .brightness)
        brightness.brightness = 0.3

        let contrast = ImageBlend(action: .contrast)
        contrast.contrast = 2.0
        
        
        model.blends = [brightness, filter, contrast, filter]
        
        return model
    }
    
    static func newspaperOverlay(image: UIImage) -> ImageBlendModel? {
        
        guard
            let overlayImage = UIImage(named: "overlay_4", in: Bundle.this, with: nil)
        else {
            return nil
        }
        
        let layers = [overlayImage, image]
        let model = ImageBlendModel(layers: layers, name: "noise overlay")
        
        let blend1 = ImageBlend(action: .filter)
        blend1.filter = .fade
        
        let blend2 = ImageBlend(action: .saturation)
        blend2.saturation = 2.0
        
        let blend3 = ImageBlend(action: .brightness)
        blend3.brightness = 0.2
        
        let blend4 = ImageBlend(action: .noise)
        blend4.noise = 2
        
        model.blends = [blend2, blend3, blend4]
        
        return model
    }
    
    
    
    static func basicOverlay(image: UIImage) -> ImageBlendModel? {
        guard
            let overlayImage = UIImage(named: "overlay_2", in: Bundle.this, with: nil)
        else {
            return nil
        }
        
        let layers = [overlayImage, image]
        let model = ImageBlendModel(layers: layers, name: "basic overlay")
        
        let blend1 = ImageBlend(action: .filter)
        blend1.filter = .vignette
        
        let blend2 = ImageBlend(action: .contrast)
        blend2.contrast = 1
        
        let blend3 = ImageBlend(action: .brightness)
        blend3.brightness = 0
        
        model.blends = [blend1, blend2, blend3]
        
        return model
    }
    
    static func noiseOverlay(image: UIImage) -> ImageBlendModel? {
        
        guard
            let overlayImage = UIImage(named: "overlay_3", in: Bundle.this, with: nil)
        else {
            return nil
        }
        
        let layers = [overlayImage, image]
        let model = ImageBlendModel(layers: layers, name: "noise overlay")
        
        let blend1 = ImageBlend(action: .filter)
        blend1.filter = .fade
        
        let blend2 = ImageBlend(action: .saturation)
        blend2.saturation = 10.0
        
        let blend3 = ImageBlend(action: .brightness)
        blend3.brightness = 0.5
        
        let blend4 = ImageBlend(action: .noise)
        blend4.noise = 40
        
        model.blends = [blend2, blend3, blend4]
        
        return model
    }
}
