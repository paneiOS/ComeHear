//
//  UIImage+.swift
//  ComeHear
//
//  Created by Pane on 2022/07/03.
//

extension UIImage {
    func applyBlur_usingClamp(radius: CGFloat) -> UIImage {
        let context = CIContext()
        guard let ciImage = CIImage(image: self),
              let clampFilter = CIFilter(name: "CIAffineClamp"),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return self
        }
        
        clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = blurFilter.outputImage,
              let cgimg = context.createCGImage(output, from: ciImage.extent) else {
            return self
        }
        return UIImage(cgImage: cgimg)
    }
    
    func resizeImage(size: CGSize) -> UIImage {
      let originalSize = self.size
      let ratio: CGFloat = {
          return originalSize.width > originalSize.height ? 1 / (size.width / originalSize.width) :
                                                            1 / (size.height / originalSize.height)
      }()

      return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
    }
}
