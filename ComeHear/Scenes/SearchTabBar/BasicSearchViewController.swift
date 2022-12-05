//
//  BasicSearchViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import UIKit

class BasicSearchViewController: UIViewController {
    private let constantSize = ConstantSize()
    //MARK: - 검색탭 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = constantSize.intervalSize
        
        [
            tourSearchButton,
            storySearchButton,
            regionSearchButton,
            locateSearchButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var tourSearchButton: UIButton = {
        let button = UIButton()
        button.setTitle("관광지 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.setupShadow(color: ContentColor.firstCellColor.getColor())
        button.addTarget(self, action: #selector(keywordSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var storySearchButton: UIButton = {
        let button = UIButton()
        button.setTitle("이야기 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.setupShadow(color: ContentColor.secondCellColor.getColor())
        button.addTarget(self, action: #selector(storySearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var regionSearchButton: UIButton = {
        let button = UIButton()
        button.setTitle("지역별 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.setupShadow(color: ContentColor.thirdCellColor.getColor())
        button.addTarget(self, action: #selector(regionSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var locateSearchButton: UIButton = {
        let button = UIButton()
        button.setTitle("현재 위치로 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.setupShadow(color: ContentColor.fourthCellColor.getColor())
        button.addTarget(self, action: #selector(locateSearch), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "Come Hear와 함께 여행을 떠나요!\n다양한 방법으로 검색해보세요!".localized()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var carrierImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dog_Man_Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
    }
}

//MARK: - Extension
extension BasicSearchViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "맞춤형 검색".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
            
        mainContentView.addSubview(subContentView)
                
        [
            buttonStackView, carrierImageView, placeHolderLabel
        ].forEach {
            subContentView.addSubview($0)
        }
        
        subContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        placeHolderLabel.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(constantSize.intervalSize * 2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        carrierImageView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
    }
    
    @objc func keywordSearch() {
        let viewController = DestinationSearchViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func storySearch() {
        let viewController = StorySearchViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func regionSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.authorizationState == .authorizedAlways || app.authorizationState == .authorizedWhenInUse {
            let viewController = RegionSearchViewController()
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            showSettingAlert(type: .gps)
        }
    }
    
    @objc func locateSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.authorizationState == .authorizedAlways || app.authorizationState == .authorizedWhenInUse {
            let viewController = LocateSearchViewController()
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            showSettingAlert(type: .gps)
        }
    }
}
