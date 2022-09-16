//
//  MyFeelRegTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/07/29.
//

import UIKit

protocol MyFeelRegTableViewDelegate: AnyObject {
    // 위임해줄 기능
    func feelListenButtonTapped( _ feel: FeelListData)
    func feelLikeButtonTapped(_ indexPath: IndexPath)
    func feelDeleteTapped( _ feel: FeelListData, _ indexPath: IndexPath)
}

class MyFeelRegTableViewCell: UITableViewCell {
    var feelList: FeelListData?
    var indexPath: IndexPath?
    var cellDelegate: MyFeelRegTableViewDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
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
            deleteButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var listenButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "headphones", pointSize: buttonSize)
        button.addTarget(self, action: #selector(feelListenButtonTap), for: .touchUpInside)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "heart", pointSize: buttonSize)
        button.addTarget(self, action: #selector(feelLikeButtonTap), for: .touchUpInside)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(systemName: "trash", pointSize: buttonSize)
        button.addTarget(self, action: #selector(feelDeleteTap), for: .touchUpInside)
        return button
    }()
    
    func setupLayout() {
        [titleLabel, stackView].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
    }
    
    @objc func feelListenButtonTap() {
        guard let feel = feelList else { return }
        cellDelegate?.feelListenButtonTapped(feel)
    }
    
    @objc func feelLikeButtonTap() {
        guard let index = indexPath else { return }
        cellDelegate?.feelLikeButtonTapped(index)
    }
    
    @objc func feelDeleteTap() {
        guard let feel = feelList else { return }
        guard let index = indexPath else { return }
        cellDelegate?.feelDeleteTapped(feel, index)
    }
}
