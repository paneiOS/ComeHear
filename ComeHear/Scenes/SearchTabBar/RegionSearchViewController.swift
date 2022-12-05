//
//  RegionSearchViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/29.
//

import UIKit
import Alamofire
import SnapKit
protocol RegionPopupDelegate {
    func recieveCityData(city : String)
    func recieveCountryData(country : String)
}

class RegionSearchViewController: UIViewController {
    //MARK: - 변수, 상수
    private let constantSize = ConstantSize()
    private var cityItems = [String]()
    private var countryItems = [[String]]()
    private var regions: [RegionDetail] = []
    private var nowPage = 1
    private var totalPage = 0
    private let cityPicker = UIPickerView()
    private let countryPicker = UIPickerView()
    
    // MARK: - 지역검색 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.thirdCellColor.getColor()
        return view
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var placeholdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "어디를 둘러볼까요?".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = constantSize.intervalSize * 2
        
        [
            cityView,
            countryView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        cityView.addSubview(cityLabel)
        
        cityLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        countryView.addSubview(countryLabel)
        countryLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        return stackView
    }()
    
        private lazy var cityView: UIView = {
            let view = UIView()
            view.setupShadow(color: ContentColor.thirdCellColor.getColor())
            view.hero.id = "RegionCityPopupViewController_MainContentView"
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCityPopupView)))
            return view
        }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "시/도".localized()
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        label.tintColor = .clear
        label.accessibilityLabel = "도시를 선택해주세요.".localized()
        return label
    }()
    
        private lazy var countryView: UIView = {
            let view = UIView()
            view.setupShadow(color: ContentColor.thirdCellColor.getColor())
            view.hero.id = "RegionCountryPopupViewController_MainContentView"
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCountryPopupView)))
            return view
        }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "시/군/구".localized()
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        label.tintColor = .clear
        label.accessibilityLabel = "지역구를 선택해주세요.".localized()
        return label
    }()
    
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Map_Search_Logo_Image")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("검색하기".localized(), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.layer.cornerRadius = 12.0
        button.layer.borderWidth = 1
        button.setupShadow()
        button.addTarget(self, action: #selector(tapSearch), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRegionData()
        setupNavigation()
        setupLayout()
        cityLabel.accessibilityTraits = .button
        countryLabel.accessibilityTraits = .button
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 지역별 검색화면입니다. 지역을 선택해주세요.")
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
        
        [
            subContentView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        subContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            placeholdLabel,
            stackView,
            placeImageView,
            searchButton
        ].forEach {
            subContentView.addSubview($0)
        }
        
        placeholdLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize * 2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(placeholdLabel.snp.bottom).offset(constantSize.intervalSize * 2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize * 2)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.height.equalTo(150)
        }
        
        placeImageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        searchButton.snp.makeConstraints {
            $0.top.equalTo(placeImageView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize * 2)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.height.equalTo(50)
        }
    }
    
    @objc func tapSearch() {
        requestSearch()
    }
    
    @objc func tapCityPopupView() {
        let cityPopupViewController = RegionCityPopupViewController(cityItems: cityItems)
        cityPopupViewController.delegate = self
        cityPopupViewController.hero.isEnabled = true
        cityLabel.isHidden = true
        cityPopupViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        guard let topViewController = keyWindow?.visibleViewController else { return }
        topViewController.present(cityPopupViewController, animated: true, completion: nil)
    }
    
    @objc func tapCountryPopupView() {
        if let cityIndex = cityItems.firstIndex(of: cityLabel.text ?? "") {
            guard countryItems[cityIndex].count != 0 else { return }
            let countryPopupViewController = RegionCountryPopupViewController(countryItems: countryItems[cityIndex])
            countryPopupViewController.delegate = self
            countryPopupViewController.hero.isEnabled = true
            countryLabel.isHidden = true
            countryPopupViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
            guard let topViewController = keyWindow?.visibleViewController else { return }
            topViewController.present(countryPopupViewController, animated: true, completion: nil)
        } else {
            showConfirmAlert(type: .selectCity)
        }
    }
    
    private func getRegionData() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.languageCode == "ko" {
            guard let url = Bundle.main.url(forResource: "RegionData_ko", withExtension: "plist") else { return }
            guard let dictionary = NSDictionary(contentsOf: url) else { return }
            guard let cityItems = dictionary["cityItem"] as? [String] else { return }
            guard let countryItems = dictionary["countryItems"] as? [[String]] else { return }
            self.cityItems = cityItems
            self.countryItems = countryItems
        } else if app.languageCode == "en" {
            guard let url = Bundle.main.url(forResource: "RegionData_en", withExtension: "plist") else { return }
            guard let dictionary = NSDictionary(contentsOf: url) else { return }
            guard let cityItems = dictionary["cityItem"] as? [String] else { return }
            guard let countryItems = dictionary["countryItems"] as? [[String]] else { return }
            self.cityItems = cityItems
            self.countryItems = countryItems
        } else {
            guard let url = Bundle.main.url(forResource: "RegionData_jp", withExtension: "plist") else { return }
            guard let dictionary = NSDictionary(contentsOf: url) else { return }
            guard let cityItems = dictionary["cityItem"] as? [String] else { return }
            guard let countryItems = dictionary["countryItems"] as? [[String]] else { return }
            self.cityItems = cityItems
            self.countryItems = countryItems
        }
    }
    
    private func setupNavigation() {
        navigationItem.title = "지역별 검색".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func requestSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let city = cityLabel.text, city != "시/도".localized() else { return showConfirmAlert(type: .selectCity)}
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        var urlString = URLString.apiURL.rawValue + "/api/v1/tour/place/region?langCode=\(languageCode)&pageNo=\(nowPage)&pageSize=20000&depth1=\(city)"
        var country = ""
        if countryLabel.text != "시/군/구".localized() {
            country = countryLabel.text ?? "시/군/구".localized()
            urlString += "&depth2=\(country)"
        }
        print("urlString", urlString)
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "").responseDecodable(of: RegionDetailModel.self) { response in
            switch response.result {
            case .success(let data):
                let viewController = RegionSearchSubViewController(regions: data.regionDetails, totalPage: data.pages.totalPages)
                if let topViewController = keyWindow?.visibleViewController {
                    topViewController.navigationController?.pushViewController(viewController, animated: true)
                }
            case .failure(_):
                self.showCloseAlert(type: .unknownError)
            }
        }
    }
}

extension RegionSearchViewController: RegionPopupDelegate {
    func recieveCityData(city : String) {
        if city != "" {
            cityLabel.text = city
            countryLabel.text = "시/군/구".localized()
            if let index = cityItems.firstIndex(of: city), countryItems[index].count == 0 {
                countryView.alpha = 0.5
            } else {
                countryView.alpha = 1
            }
        }
        cityLabel.isHidden = false
    }
    
    func recieveCountryData(country : String) {
        if country != "" {
            countryLabel.text = country
        }
        countryLabel.isHidden = false
    }
}
