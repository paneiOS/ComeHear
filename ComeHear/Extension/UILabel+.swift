//
//  UILabel+.swift
//  ComeHear
//
//  Created by Pane on 2022/08/08.
//

extension UILabel {
    func setupTagTypeLayout(fontSize: CGFloat) {
        self.textColor = .label
        self.font = .systemFont(ofSize: 15.0, weight: .semibold)
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.alpha = 0.7
    }
    
    func setupTagTypeLayout() {
        self.textColor = .label
        self.font = .systemFont(ofSize: 12.0, weight: .semibold)
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.alpha = 0.7
    }
}
