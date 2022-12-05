//
//  NoticeSectionTableViewCell.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import UIKit

class NoticeSectionTableViewCell: UITableViewCell {
    private let constantSize = ConstantSize()
    private lazy var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        label.isAccessibilityElement = false
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .label
        label.isAccessibilityElement = false
        return label
    }()
    
    lazy var openButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "plus.circle", pointSize: constantSize.buttonSize)
        button.isEnabled = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.isAccessibilityElement = false
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    func setupLayout() {
        [titleView, openButton].forEach {
            addSubview($0)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [titleLabel, subTitleLabel].forEach {
            titleView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
        }
        
        openButton.snp.makeConstraints {
            $0.leading.equalTo(titleView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(50)
        }
    }
}
