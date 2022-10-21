//
//  ImageBlend.swift
//  ImageBlendEditor
//
//  Created by beequri on 10.03.21.
//  Copyright © 2021 beequri. All rights reserved.
//

import UIKit

@objc public class ImageBlend: NSObject {
    
    @objc public enum Action:Int {
        case filter
        case contrast
        case brightness
        case saturation
        case noise
    }
    
    private var availableFilters: [String] = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear",
        "CISepiaTone",
        "CIVignette"
    ]
    
    private var action: Action
    
    @objc public var filter: Filter = .process
    @objc public var brightness: CGFloat = 0
    @objc public var contrast: CGFloat = 0
    @objc public var saturation: CGFloat = 1
    @objc public var noise: CGFloat = 20
    @objc public var imageAlpha = 1.0
    @objc public var overlayImageAlpha = 1.0
    
    @objc public init(action: Action) {
        self.action = action
    }
    
    public func apply(image: UIImage) -> UIImage? {
        switch action {
        case .filter:
            return image.createFilteredImage(filterName: availableFilters[filter.rawValue])
        case .contrast:
            return image.imageContrast(value: contrast)
        case .brightness:
            return image.imageBrightness(value: brightness)
        case .saturation:
            return image.imageSaturation(value: saturation)
        case .noise:
            return image.imageNoise(value: noise)
        }
    }
}

extension UIImage {
    func createFilteredImage(filterName: String) -> UIImage {
        let sourceImage = CIImage(image: self)
        let filter = CIFilter(name: filterName)
        let context = CIContext(options: nil)
        
        filter?.setDefaults()
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)

        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let outputCGImage = context.createCGImage(filteredImageData, from: filteredImageData.extent)

        let originalOrientation = self.imageOrientation
        let originalScale = self.scale
        let filteredImage = UIImage.init(cgImage: outputCGImage!, scale: originalScale, orientation: originalOrientation)

        return filteredImage
    }
    
    func imageContrast(value : CGFloat) -> UIImage? {
        let aUIImage = self
        let aCGImage = aUIImage.cgImage
        
        let aCIImage = CIImage(cgImage: aCGImage!)
        let context = CIContext(options: nil)
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            print("unable to obtain contrastFilter")
            return nil
        }
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        contrastFilter.setValue(value, forKey: "inputContrast")
        let outputImage = contrastFilter.outputImage!
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: cgimg!)
        
    }
    
    func imageBrightness(value : CGFloat) -> UIImage? {
        let aUIImage = self
        let aCGImage = aUIImage.cgImage
        
        let aCIImage = CIImage(cgImage: aCGImage!)
        let context = CIContext(options: nil)
        guard let brightnessFilter = CIFilter(name: "CIColorControls") else {
            print("unable to obtain brightnessFilter")
            return nil
        }
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter.setValue(value, forKey: "inputBrightness")
        let outputImage = brightnessFilter.outputImage!
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: cgimg!)
    }
    
    func imageSaturation(value : CGFloat) -> UIImage? {
        let aUIImage = self
        let aCGImage = aUIImage.cgImage
        
        let aCIImage = CIImage(cgImage: aCGImage!)
        let context = CIContext(options: nil)
        guard let saturationFilter = CIFilter(name: "CIColorControls") else {
            print("unable to obtain brightnessFilter")
            return nil
        }
        saturationFilter.setValue(aCIImage, forKey: "inputImage")
        saturationFilter.setValue(value, forKey: "inputSaturation")
        let outputImage = saturationFilter.outputImage!
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: cgimg!)
    }
    
    func imageNoise(value : CGFloat) -> UIImage? {
        let aUIImage = self
        let aCGImage = aUIImage.cgImage
        
        let aCIImage = CIImage(cgImage: aCGImage!)
        let context = CIContext(options: nil)
        guard let noiseFilter = CIFilter(name: "CIUnsharpMask") else {
            print("unable to obtain brightnessFilter")
            return nil
        }
        noiseFilter.setValue(aCIImage, forKey: "inputImage")
        noiseFilter.setValue(7, forKey: kCIInputRadiusKey)
        noiseFilter.setValue(value, forKey: kCIInputIntensityKey)
        
        let outputImage = noiseFilter.outputImage!
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: cgimg!)
    }
}
