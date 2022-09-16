//
//  MyFavoriteTableViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/07/28.
//

import UIKit
import Kingfisher

protocol MyFavoriteTableViewDelegate: AnyObject {
    func favoriteButtonTapped(_ tag: Int)
}

class MyFavoriteTableViewCell: UITableViewCell {
    private let intervalSize: CGFloat = 16
    
    var cellDelegate: MyFavoriteTableViewDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.backgroundColor = .clear
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 12
        label.isAccessibilityElement = false
        return label
    }()
    
    lazy var buttonView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.3
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapFavoriteButton))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        return view
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(systemName: "star.fill", pointSize: 20)
        button.addTarget(self, action: #selector(tapFavoriteButton), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    lazy var bgImageShadowView: UIView = {
        let view = UIView()
        view.setupShadow()
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        return view
    }()
    
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = moreLightGrayColor?.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .button
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setupLayout()
    }
    
    private func setupLayout() {
//        contentView.backgroundColor = UIColor(named: moreLightGrayColor)
        
        [bgImageShadowView, buttonView].forEach {
            addSubview($0)
        }

        bgImageShadowView.addSubview(bgImageView)
        
        bgImageShadowView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        bgImageView.addSubview(titleLabel)
        buttonView.addSubview(favoriteButton)

        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(intervalSize/2)
            $0.bottom.equalToSuperview().inset(intervalSize/2)
            $0.height.equalTo(30)
        }
        buttonView.snp.makeConstraints {
            $0.trailing.equalTo(bgImageView.snp.trailing).inset(intervalSize/2)
            $0.bottom.equalTo(bgImageView.snp.bottom).inset(intervalSize/2)
            $0.height.width.equalTo(40)
        }
//
        favoriteButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc func tapFavoriteButton() {
        cellDelegate?.favoriteButtonTapped(self.favoriteButton.tag)
    }
}
