//
//  BGMSelectTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/08/31.
//

import UIKit

protocol BGMSelectDelegate {
    func bgmSelectButtonTapped(_ tag : Int)
}

final class BGMSelectTableViewCell: UITableViewCell {
    private let constantSize = ConstantSize()
    var cellDelegate: BGMSelectDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        label.isAccessibilityElement = false
        return label
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "circle", pointSize: constantSize.buttonSize)
        button.addTarget(self, action: #selector(tapSelectButton), for: .touchUpInside)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    @objc func tapSelectButton() {
        cellDelegate?.bgmSelectButtonTapped(selectButton.tag)
    }
}

extension BGMSelectTableViewCell {
    func setupLayout() {
        [
            titleLabel, selectButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        selectButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(selectButton.snp.height)
        }
    }
}
