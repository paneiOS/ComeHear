//
//  ContentCollectionViewFeelCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import UIKit

final class ContentCollectionViewFeelCell: UICollectionViewCell {
    private let playIntervalSize: CGFloat = 10
    private let intervalSize: CGFloat = 10
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 12.0, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = contentView.bounds.size.width / 2
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var playView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "play.fill")
        imageView.alpha = 0.7
        imageView.tintColor = .white
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    func setupLayout() {
        
        [subContentView, playView, titleLabel].forEach {
            addSubview($0)
        }
        
        subContentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(contentView.snp.width)
        }
        
        playView.snp.makeConstraints {
            $0.center.equalTo(subContentView.snp.center)
            $0.width.equalTo(contentView.bounds.size.width * 0.4)
            $0.height.equalTo(contentView.bounds.size.width * 0.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(subContentView.snp.bottom).offset(intervalSize/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        subContentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.layer.cornerRadius = contentView.bounds.size.width / 2
    }
}
