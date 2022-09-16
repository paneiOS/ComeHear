//
//  UIImageView+.swift
//  ComeHear
//
//  Created by Pane on 2022/08/29.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String, placeholder: UIImage?, cornerRadius: CGFloat) {
        let cache = ImageCache.default
        cache.retrieveImage(forKey: urlString, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    self.image = image
                } else {
                    guard let url = URL(string: urlString) else { return }
                              let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    let retryStrategy = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(3))
                    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: cornerRadius)
                    self.kf.setImage(
                      with: resource,
                      placeholder: placeholder ?? UIImage(),
                      options: [
                        .retryStrategy(retryStrategy),
                        .forceTransition,
                        .processor(cornerImageProcessor)
                      ],
                      completionHandler: nil)
                }
            case .failure(let error):
#if DEBUG
                    print(error)
#endif
            }
        }
    }
}
