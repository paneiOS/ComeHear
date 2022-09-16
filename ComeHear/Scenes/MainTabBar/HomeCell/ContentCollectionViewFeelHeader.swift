//
//  ContentCollectionViewFeelHeader.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import UIKit

final class ContentCollectionViewFeelHeader: UICollectionReusableView {
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .label
        label.text = "최신 인기느낌"
        
        return label
    }()
    
    private lazy var subNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.text = "Play 해보세요"
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [sectionNameLabel, subNameLabel].forEach {
            addSubview($0)
        }
        
        sectionNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        subNameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(sectionNameLabel.snp.trailing).offset(10)
        }
    }
}


