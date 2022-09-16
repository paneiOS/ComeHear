//
//  ContentCollectionViewBasicHeader.swift
//  ComeHear
//
//  Created by Pane on 2022/06/26.
//

import UIKit

final class ContentCollectionViewBasicHeader: UICollectionReusableView {
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .label
        label.text = "듣고 보고 즐기는 추천 테마"
        
        return label
    }()
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(sectionNameLabel)
        sectionNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().offset(20)
        }
    }
}

