//
//  NoticeTableViewCell.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {    
    private lazy var contentSubView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
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
            $0.top.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(contentSubView.snp.top).offset(intervalSize)
            $0.bottom.equalTo(contentSubView.snp.bottom).inset(intervalSize)
            $0.leading.equalTo(contentSubView.snp.leading).offset(intervalSize)
            $0.trailing.equalTo(contentSubView.snp.trailing).inset(intervalSize)
        }
    }
}
