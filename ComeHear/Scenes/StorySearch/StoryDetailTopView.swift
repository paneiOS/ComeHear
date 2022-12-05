//
//  StoryDetailTopView.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import SnapKit
import UIKit

final class StoryDetailTopView: UIView {
    private let constantSize = ConstantSize()
    
    //MARK: - 상단 UI
    private lazy var imageBGView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    lazy var scriptView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 4
        label.isAccessibilityElement = false
        if UIAccessibility.isVoiceOverRunning {
            label.isHidden = true
        }
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("펼치기 ".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "arrowtriangle.down.fill", pointSize: 10)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(moreLabel), for: .touchUpInside)
        button.isAccessibilityElement = false
        if UIAccessibility.isVoiceOverRunning {
            button.isHidden = true
        }
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = constantSize.intervalSize
        
        [
            actorSound,
            defaultSound
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    lazy var actorSound: UIButton = {
        let button = UIButton()
        button.setTitle("성우 해설  ".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "headphones", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor(named: "ListenButton")
        button.layer.cornerRadius = 20.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    lazy var defaultSound: UIButton = {
        let button = UIButton()
        button.setTitle("기본 해설  ".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "headphones", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .white
        button.layer.cornerRadius = 20.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StoryDetailTopView {
    func setupLayout() {
        setupShadow()
        
        [
            imageBGView,
            scriptView,
            moreButton,
            stackView
        ].forEach { addSubview($0) }
        
        imageBGView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            if UIAccessibility.isVoiceOverRunning {
                $0.height.equalTo(0)
            } else {
                $0.height.equalTo((constantSize.frameSizeWidth - 64) * 0.9)
            }
        }
        
        imageBGView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scriptView.snp.makeConstraints {
            $0.top.equalTo(imageBGView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            if UIAccessibility.isVoiceOverRunning {
                $0.height.equalTo(0)
            }
        }
        
        moreButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            if UIAccessibility.isVoiceOverRunning {
                $0.height.equalTo(0)
            } else {
                $0.height.equalTo(25)
            }
            $0.top.equalTo(scriptView.snp.bottom).offset(constantSize.intervalSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(moreButton.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
    }
    
    @objc func moreLabel() {
        if scriptView.numberOfLines == 0 {
            scriptView.numberOfLines = 4
            moreButton.setTitle("펼치기 ".localized(), for: .normal)
            moreButton.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        } else {
            scriptView.numberOfLines = 0
            moreButton.setTitle("접기 ".localized(), for: .normal)
            moreButton.setImage(UIImage(systemName: "arrowtriangle.up.fill"), for: .normal)
        }
    }
}
