//
//  ContentCollectionViewThemaCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/23.
//

import UIKit

final class ContentCollectionViewThemaCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
        configureImg()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureImg()
    }
    
    func configureImg() {
        imageView.layer.cornerRadius = imageView.frame.width / 2//contentView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .tertiaryLabel
    }
    
    var imageView = UIImageView()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 10.0, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    func setup() {
        [imageView, titleLabel].forEach { addSubview($0) }
        let intervalSize: CGFloat = 5.0
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(intervalSize)
            $0.bottom.trailing.leading.equalToSuperview()
        }
    }
}
