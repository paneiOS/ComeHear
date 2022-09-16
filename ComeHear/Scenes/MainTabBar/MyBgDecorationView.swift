//
//  MyBgDecorationView.swift
//  ComeHear
//
//  Created by Pane on 2022/08/08.
//

import Foundation

class MyBgDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.lightGray.cgColor
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}
