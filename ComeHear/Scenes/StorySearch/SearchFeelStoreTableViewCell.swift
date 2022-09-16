//
//  SearchFeelStoreTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import UIKit

protocol FeelStoreTableViewDelegate: AnyObject {
    // 위임해줄 기능
    func feelListenButtonTapped( _ feel: FeelListData)
    func feelLikeButtonTapped(_ tag: Int)
    func feelListReportTapped( _ feel: FeelListData)
}

final class SearchFeelStoreTableViewCell: UITableViewCell {
    private let intervalSize: CGFloat = 10
    private let buttonSize: CGFloat = 25
    var feelList: FeelListData?
    var cellDelegate: FeelStoreTableViewDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        listenButton.addTarget(self, action: #selector(feelListenButtonTap), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(feelLikeButtonTap), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(feelListReportTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
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
            sendButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var listenButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "headphones", pointSize: buttonSize)
        button.accessibilityLabel = "듣기".localized()
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "heart", pointSize: buttonSize)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "exclamationmark.bubble", pointSize: buttonSize)
        button.accessibilityLabel = "신고하기".localized()
        return button
    }()
    
    func setupLayout() {
        [titleLabel, stackView].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    @objc func feelListenButtonTap() {
        guard let feel = feelList else { return }
        cellDelegate?.feelListenButtonTapped(feel)
    }
    
    @objc func feelLikeButtonTap() {
        cellDelegate?.feelLikeButtonTapped(self.likeButton.tag)
    }
    
    @objc func feelListReportTap() {
        guard let feel = feelList else { return }
        cellDelegate?.feelListReportTapped(feel)
    }
}
