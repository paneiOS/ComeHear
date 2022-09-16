//
//  UIButton+.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import UIKit

//import UIKit

extension UIButton {
    func setImage(systemName: String) {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill

        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = .zero

        setImage(UIImage(systemName: systemName), for: .normal)
    }
    
    func setImage(systemName: String, pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) {
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center

        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = .zero

        setImage(UIImage(systemName: systemName), for: .normal)
        setPreferredSymbolConfiguration(.init(pointSize: pointSize, weight: weight, scale: .default), forImageIn: .normal)
    }

    func setUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }
    
    func setupHalfButton(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        self.backgroundColor = personalColor
        self.layer.cornerRadius = (frameSizeWidth / 2) / 10
        self.layer.borderWidth = 0.5
    }
    
    func setupHalfButton(title: String, color: UIColor?) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        self.backgroundColor = color ?? .white
        self.layer.cornerRadius = (frameSizeWidth / 2) / 10
        self.layer.borderWidth = 0.5
    }
    
    func setupLongButton(title: String, fontSize: CGFloat) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .bold)
        self.backgroundColor = personalColor
        self.layer.cornerRadius = 12
    }
    
    func setupValidButton(textColor: UIColor, backgroundColor: UIColor?, alpha: CGFloat, enable: Bool) {
        self.setTitleColor(textColor, for: .normal)
        self.backgroundColor = backgroundColor ?? .white
        self.alpha = alpha
        self.isEnabled = enable
        self.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 12.0
    }
    
    func setupValidButton(title: String, textColor: UIColor, backgroundColor: UIColor?, alpha: CGFloat, enable: Bool) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.backgroundColor = backgroundColor ?? .white
        self.alpha = alpha
        self.isEnabled = enable
        self.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .regular)
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 12.0
    }
}
