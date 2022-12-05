//
//  ContentCollectionViewManualCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import UIKit

final class ContentCollectionViewManualCell: UICollectionViewCell {
    private let constantSize = ConstantSize()
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "안내지침서문구".localized()
        label.isAccessibilityElement = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        return label
    }()
    
    private lazy var roundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LoadingImage_Circle_\(constantSize.randumNumber)")
        imageView.tintColor = ContentColor.personalColor.getColor()
        imageView.backgroundColor = .white
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let roundViewSize = contentView.frame.size.height - constantSize.intervalSize * 2
        contentView.backgroundColor = ContentColor.personalColor.getColor()
        
        contentView.hero.id = "manual"
        
        roundView.layer.cornerRadius = roundViewSize / 2
        [topLabel, roundView].forEach {
            addSubview($0)
        }
        
        topLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize*2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize * 1.5)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize*2)
        }
        
        roundView.addSubview(imageView)
        
        roundView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalTo(topLabel.snp.trailing).offset(constantSize.intervalSize * 2)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.width.equalTo(roundViewSize)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

