//
//  AroundPlaceHolderCollectionViewCell.swift
//  ComeHear
//
//  Created by Pane on 2022/08/08.
//

import UIKit

final class AroundPlaceHolderCollectionViewCell: UICollectionViewCell {
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BasicLogo")
        return imageView
    }()
    
    private lazy var placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "위치기반서비스 이용을 위해 접근권한이 필요합니다."
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("접근권한 설정하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.addTarget(self, action: #selector(tapSettingButton), for: .touchUpInside)
        button.setUnderline()
        button.isAccessibilityElement = false
        return button
    }()
    
    override func layoutSubviews() {
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [imageView, placeHolderView].forEach {
            mainContentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        placeHolderView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).inset(intervalSize * 2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        [placeHolderLabel, settingButton].forEach {
            placeHolderView.addSubview($0)
        }
        
        placeHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalTo(placeHolderLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(intervalSize/2)
            $0.height.equalTo(30)
        }
    }
    
    @objc private func tapSettingButton() {
        guard let topViewController = keyWindow?.visibleViewController else { return }
        topViewController.showSettingAlert(title: "GPS권한 요청", message: "현재위치 정보를 얻기 위해 권한을 허용해주세요.")
    }
}
