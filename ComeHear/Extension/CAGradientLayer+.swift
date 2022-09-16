////
////  CAGradientLayer+.swift
////  ComeHear
////
////  Created by Pane on 2022/08/29.
////
//
//import Foundation
//
//extension CAGradientLayer {
//    
//    class func primaryGradient(on view: UIView) -> UIImage? {
//        let gradient = CAGradientLayer()
//        let flareRed = UIColor(displayP3Red: 241.0/255.0, green: 39.0/255.0, blue: 17.0/255.0, alpha: 1.0)
//        let flareOrange = UIColor(displayP3Red: 245.0/255.0, green: 175.0/255.0, blue: 25.0/255.0, alpha: 1.0)
//        var bounds = view.bounds
//        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//        let height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//        bounds.size.height += height
//        gradient.frame = bounds
//        gradient.colors = [flareRed.cgColor, flareOrange.cgColor]
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 1, y: 0)
//        return gradient.createGradientImage(on: view)
//    }
//    
//    private func createGradientImage(on view: UIView) -> UIImage? {
//        var gradientImage: UIImage?
//        UIGraphicsBeginImageContext(view.frame.size)
//        if let context = UIGraphicsGetCurrentContext() {
//            render(in: context)
//            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
//        }
//        UIGraphicsEndImageContext()
//        return gradientImage
//    }
//}
