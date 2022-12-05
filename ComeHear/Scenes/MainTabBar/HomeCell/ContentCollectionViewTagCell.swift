//
//  ContentCollectionViewTagCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/26.
//

import UIKit

final class ContentCollectionViewTagCell: UICollectionViewCell {
    private let constantSize = ConstantSize()
    
    lazy var firstTag: UILabel = {
        let label = UILabel()
        label.setupTagTypeLayout()
        return label
    }()
    
    lazy var secondTag: UILabel = {
        let label = UILabel()
        label.setupTagTypeLayout()
        return label
    }()
    
    lazy var thirdTag: UILabel = {
        let label = UILabel()
        label.setupTagTypeLayout()
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .tertiaryLabel
        return imageView
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.setupTagTypeLayout(fontSize: 15)
        return label
    }()
    
    
    override func layoutSubviews() {
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [firstTag, secondTag, thirdTag, detailLabel].forEach {
            imageView.addSubview($0)
        }
        
        firstTag.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.height.equalTo(30)
        }
        
        secondTag.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.leading.equalTo(firstTag.snp.trailing).offset(constantSize.intervalSize/2)
            $0.height.equalTo(30)
        }
        
        thirdTag.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.leading.equalTo(secondTag.snp.trailing).offset(constantSize.intervalSize/2)
            $0.height.equalTo(30)
        }
        
        detailLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.height.equalTo(30)
        }
    }
}
