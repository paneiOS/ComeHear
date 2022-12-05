//
//  RegionCountryPopupViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/09/02.
//

import UIKit

class RegionCountryPopupViewController: UIViewController {
    private let constantSize = ConstantSize()
    private let commonFunc = CommonFunc()
    private var countryItems = [String]()
    
    var delegate: RegionPopupDelegate?
    
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.hero.id = "RegionCountryPopupViewController_MainContentView"
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "지역구를 선택해주세요."
        label.layer.cornerRadius = 20
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: - LifeCycle_생명주기
    init(countryItems: [String]) {
        self.countryItems = countryItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension RegionCountryPopupViewController {
    func setupLayout() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        view.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [titleLabel, closeButton, tableView].forEach {
            mainContentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalTo(closeButton.snp.leading)
            $0.height.equalTo(50)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.width.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40 * 11)
        }
    }
    
    @objc func tapClose() {
        dismiss(animated: true)
        delegate?.recieveCountryData(country: "")
    }
}

// MARK: - TableView Delegate
extension RegionCountryPopupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.recieveCountryData(country: countryItems[indexPath.row])
        dismiss(animated: true)
    }
}

// MARK: - TableView DataSource
extension RegionCountryPopupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none

        let country = countryItems[indexPath.row]
        cell.textLabel?.text = country
        cell.textLabel?.accessibilityLabel = "\(commonFunc.intToString(indexPath.row + 1))번 " + country
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


