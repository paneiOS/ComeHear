//
//  MyFeelSectionTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/07/30.
//

import UIKit
import Kingfisher

class MyFeelSectionTableViewCell: UITableViewCell {
    private let constantSize = ConstantSize()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var openButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "chevron.down", pointSize: constantSize.buttonSize)
        button.isEnabled = false
        return button
    }()
    
    override func layoutSubviews() {
        setupLayout()
    }
    
    private func setupLayout() {
        [titleLabel, openButton].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        openButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
    }
}
