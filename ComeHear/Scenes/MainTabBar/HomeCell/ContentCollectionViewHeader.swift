//
//  ContentCollectionViewHeader.swift
//  ComeHear
//
//  Created by Pane on 2022/06/26.
//

import UIKit
import SnapKit

final class ContentCollectionViewHeader: UICollectionReusableView {
    private let constantSize = ConstantSize()
    
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "PlaceHolder_Main1".localized()
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(sectionNameLabel)
        
        sectionNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize * 1.5)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize / 2)
        }
    }
}
