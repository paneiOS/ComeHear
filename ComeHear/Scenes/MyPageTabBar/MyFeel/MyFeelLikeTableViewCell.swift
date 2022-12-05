//
//  MyFeelLikeTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/08/01.
//

import UIKit

protocol MyFeelLikeTableViewDelegate: AnyObject {
    // 위임해줄 기능
    func feelListenButtonTapped( _ feel: FeelListData)
    func feelLikeButtonTapped(_ indexPath: IndexPath, _ tag: Int?)
    func feelReportTapped( _ feel: FeelListData)
}

class MyFeelLikeTableViewCell: UITableViewCell {
    private let constantSize = ConstantSize()
    var feelList: FeelListData?
    var indexPath: IndexPath?
    var tableIndex: Int?
    var cellDelegate: MyFeelLikeTableViewDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        
        [
            listenButton,
            likeButton,
            reportButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var listenButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "headphones", pointSize: constantSize.buttonSize)
        button.addTarget(self, action: #selector(feelListenButtonTap), for: .touchUpInside)
        button.accessibilityLabel = "듣기".localized()
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "heart", pointSize: constantSize.buttonSize)
        button.addTarget(self, action: #selector(feelLikeButtonTap), for: .touchUpInside)
        return button
    }()
    
    lazy var reportButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "exclamationmark.bubble", pointSize: constantSize.buttonSize)
        button.addTarget(self, action: #selector(feelListReportTap), for: .touchUpInside)
        button.accessibilityLabel = "신고하기".localized()
        return button
    }()
    
    func setupLayout() {
        [titleLabel, stackView].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
    }
    
    @objc func feelListenButtonTap() {
        guard let feel = feelList else { return }
        cellDelegate?.feelListenButtonTapped(feel)
    }
    
    @objc func feelLikeButtonTap() {
        guard let index = indexPath else { return }
        cellDelegate?.feelLikeButtonTapped(index, tableIndex ?? 0)
    }
    
    @objc func feelListReportTap() {
        guard let feel = feelList else { return }
        cellDelegate?.feelReportTapped(feel)
    }
}

