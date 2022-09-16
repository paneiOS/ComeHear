//
//  NavigationShadowView.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/06.
//

import UIKit

final class NavigationShadowView: UIView {
    lazy var separator: UIView = {
        let separator = UIView()
        separator.setupShadow()
        return separator
    }()

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(frameSizeWidth*2)
        } 
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
