//
//  ContentCollectionViewFooter.swift
//  ComeHear
//
//  Created by Pane on 2022/06/26.
//

import UIKit

final class ContentCollectionViewFooter: UICollectionReusableView {
//    lazy var indexLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .label
//        label.font = .systemFont(ofSize: 10.0, weight: .semibold)
//        label.textAlignment = .center
//        return label
//    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .clear
        return separator
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(separator)
        separator.snp.makeConstraints {
            $0.edges.equalToSuperview()
//            $0.leading.equalToSuperview().inset(16.0)
//            $0.trailing.equalToSuperview()
//            $0.top.equalToSuperview()
//            $0.height.equalTo(0.5)
        }
    }
    
    

}

