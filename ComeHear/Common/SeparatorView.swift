//
//  SeparatorView.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import UIKit

final class SeparatorView: UIView {
    lazy var separator: UIView = {
        let separator = UIView()
        return separator
    }()

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        separator.backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
