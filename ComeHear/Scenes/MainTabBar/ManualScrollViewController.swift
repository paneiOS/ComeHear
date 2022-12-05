//
//  ManualScrollViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/08/28.
//

import UIKit

class ManualScrollViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        if UIAccessibility.isVoiceOverRunning {
            label.isHidden = false
        } else {
            label.isHidden = true
        }
        label.text = " "
        label.accessibilityLabel = "메뉴얼해설"
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "ko" {
            imageView.image = UIImage(named: "Manual_Image_ko")
        } else if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "en" {
            imageView.image = UIImage(named: "Manual_Image_en")
        } else {
            imageView.image = UIImage(named: "Manual_Image_ja")
        }
        imageView.contentMode = .top
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .white
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        button.isHidden = true
        return button
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        closeButton.isHidden = false
    }
}

extension ManualScrollViewController {
    private func setupLayout() {
        view.backgroundColor = .white
        [mainContentView, closeButton, titleLabel].forEach {
            view.addSubview($0)
        }
        
        mainContentView.hero.id = "manual"
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(constantSize.intervalSize)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }

        mainContentView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(subContentView)
        
        subContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        subContentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func tapClose() {
        closeButton.isHidden = true
        dismiss(animated: true)
    }
}
