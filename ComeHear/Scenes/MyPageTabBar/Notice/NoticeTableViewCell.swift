//
//  NoticeTableViewCell.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {
    private let constantSize = ConstantSize()
    
    private lazy var contentSubView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.moreLightGrayColor.getColor()
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    func setupLayout() {
        addSubview(contentSubView)
        contentSubView.addSubview(contentLabel)
        
        contentSubView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(contentSubView.snp.top).offset(constantSize.intervalSize)
            $0.bottom.equalTo(contentSubView.snp.bottom).inset(constantSize.intervalSize)
            $0.leading.equalTo(contentSubView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(contentSubView.snp.trailing).inset(constantSize.intervalSize)
        }
    }
}
