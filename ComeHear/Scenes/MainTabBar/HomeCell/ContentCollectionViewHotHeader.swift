//
//  ContentCollectionViewHotHeader.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import Foundation

import UIKit

final class ContentCollectionViewHotHeader: UICollectionReusableView {
    private let intervalSize: CGFloat = 16.0
    
    lazy var sectionNameRedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemRed
        return label
    }()
    
    lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.text = ""
        
        return label
    }()
    
    func setup() {
        [sectionNameRedLabel, sectionNameLabel].forEach {
            addSubview($0)
        }
        
        sectionNameRedLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(5)
        }
        
        sectionNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(sectionNameRedLabel.snp.trailing).offset(10)
        }
    }
}
