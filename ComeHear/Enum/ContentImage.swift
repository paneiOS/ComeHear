//
//  ContentImage.swift
//  ComeHear
//
//  Created by Pane on 2022/08/29.
//

// MARK: - String to UIImage
enum ContentImage: String {
    case landScapeImage = "LandScape_Image"
    case loadingImage = "LoadingImage"
    
    func getImage() -> UIImage {
        guard let image = UIImage(named: self.rawValue) else { return UIImage()}
        return image
    }
}
