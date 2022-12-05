//
//  ContentCollectionViewSearchCell.swift
//  ComeHear
//
//  Created by Pane on 2022/06/27.
//

import Foundation
import UIKit

final class ContentCollectionViewSearchCell: UICollectionViewCell {
    
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        [
            tourSearchButton, storySearchButton, regionSearchButton, locateSearchButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var tourSearchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ContentColor.firstCellColor.getColor()
        button.setTitle("관광지 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .bold)
        button.addTarget(self, action: #selector(keywordSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var storySearchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ContentColor.secondCellColor.getColor()
        button.setTitle("이야기 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .bold)
        button.addTarget(self, action: #selector(storySearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var regionSearchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ContentColor.thirdCellColor.getColor()
        button.setTitle("지역 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .bold)
        button.addTarget(self, action: #selector(regionSearch), for: .touchUpInside)
        return button
    }()
    
    lazy var locateSearchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ContentColor.fourthCellColor.getColor()
        button.setTitle("현재 위치 검색".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .bold)
        button.addTarget(self, action: #selector(locateSearch), for: .touchUpInside)
        return button
    }()
    
    func setup() {
        addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainContentView.addSubview(subStackView)
        
        subStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        
    }
    
    @objc func keywordSearch() {
        let viewController = DestinationSearchViewController()
        if let topViewController = keyWindow?.visibleViewController {
            topViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func storySearch() {
        let viewController = StorySearchViewController()
        if let topViewController = keyWindow?.visibleViewController {
            topViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func regionSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.authorizationState == .authorizedAlways || app.authorizationState == .authorizedWhenInUse {
            let viewController = RegionSearchViewController()
            topViewController.navigationController?.pushViewController(viewController, animated: true)
        } else {
            topViewController.showSettingAlert(type: .gps)
        }
    }
    
    @objc func locateSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.authorizationState == .authorizedAlways || app.authorizationState == .authorizedWhenInUse {
            let viewController = LocateSearchViewController()
            topViewController.navigationController?.pushViewController(viewController, animated: true)
        } else {
            topViewController.showSettingAlert(type: .gps)
        }
    }
}
