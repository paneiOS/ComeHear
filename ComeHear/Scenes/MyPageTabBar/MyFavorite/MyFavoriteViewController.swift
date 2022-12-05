//
//  MyFavoriteViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/28.
//

import UIKit
import Alamofire

class MyFavoriteViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    // MARK: - 변수, 상수
    private var myFavoriteList = [DestinationDetailData]()
    
    //MARK: - 나의 즐겨찾기 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    private lazy var coverView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var coverPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "아직 \"즐겨찾기\"에 추가된 관광지가 없습니다.\n\n어떤곳들이 있는지 검색해보세요!".localized()
        return label
    }()
    
    private lazy var searchTabButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "관광지 검색하러 가기".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(tapSearchTabButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ContentImage.landScapeImage.getImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(MyFavoriteTableViewCell.self, forCellReuseIdentifier: "MyFavoriteTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = ContentColor.personalColor.getColor()
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 나의 즐겨찾기 화면입니다.")
    }
}

//MARK: - Extension
extension MyFavoriteViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "나의 즐겨찾기".localized()
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
        
        [
            coverView, tableView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        coverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [coverPlaceholderLabel, searchTabButton, coverImageView].forEach {
            coverView.addSubview($0)
        }
        
        coverPlaceholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        searchTabButton.snp.makeConstraints {
            $0.top.equalTo(coverPlaceholderLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        coverImageView.snp.makeConstraints {
            $0.top.equalTo(searchTabButton.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.height.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - API Request
    private func requestData() {
        self.coverView.isHidden = true
        self.tableView.isHidden = true
        guard let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, let memberIdx = app.userMemberIdx else { return }
        let urlString = URLString.SubDomain.favoritePlace.getURL() + "?memberIdx=\(memberIdx)&pageNo=1&pageSize=20000"
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: DestinationModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.myFavoriteList = data.destinations
                    self.tableView.reloadData()
                    if self.myFavoriteList.count == 0 {
                        self.coverView.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        self.coverView.isHidden = true
                        self.tableView.isHidden = false
                    }
                case .failure(_):
                    self.showCloseAlert(type: .unknownError)
                    self.coverPlaceholderLabel.isHidden = false
                }
            }
    }
    
    //MARK: - @objc
    @objc private func tapSearchTabButton() {
        if UIAccessibility.isVoiceOverRunning {
            self.tabBarController?.selectedIndex = 0
        } else {
            self.tabBarController?.selectedIndex = 2
        }
    }
}

extension MyFavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favoriteData = self.myFavoriteList[indexPath.row]
        let viewController = StorySearchSubViewController(storyTitle: favoriteData.title, tid: favoriteData.tid, tlid: favoriteData.tlid, image: favoriteData.imageUrl, favorite: favoriteData.memberLike)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFavoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewCell") as? MyFavoriteTableViewCell else { return UITableViewCell() }
        guard let memberLike = myFavoriteList[indexPath.row].memberLike else { return UITableViewCell() }
        cell.bgImageView.setImage(with: myFavoriteList[indexPath.row].imageUrl ?? "", placeholder: ContentImage.landScapeImage.getImage(), cornerRadius: 0)
        cell.titleLabel.text = "  # " + myFavoriteList[indexPath.row].title + "  "
        cell.favoriteButton.tag = indexPath.row
        if memberLike {
            cell.bgImageView.layer.borderColor = ContentColor.checkButtonColor.getColor().cgColor
            cell.buttonView.backgroundColor = ContentColor.checkButtonColor.getColor()
            cell.bgImageView.alpha = 1.0
            if app.languageCode == "ko" {
                cell.buttonView.accessibilityLabel = "즐겨찾기 취소하는"
            }
        } else {
            cell.bgImageView.layer.borderColor = ContentColor.moreLightGrayColor.getColor().cgColor
            cell.buttonView.backgroundColor = ContentColor.moreLightGrayColor.getColor()
            cell.bgImageView.alpha = 0.3
            if app.languageCode == "ko" {
                cell.buttonView.accessibilityLabel = "즐겨찾기 추가하는"
            }
        }
        cell.selectionStyle = .none
        cell.cellDelegate = self
        cell.bgImageShadowView.accessibilityLabel = myFavoriteList[indexPath.row].title + "관광지 선택".localized()
        cell.shouldGroupAccessibilityChildren = true
        return cell
    }
}

extension MyFavoriteViewController: MyFavoriteTableViewDelegate {
     func favoriteButtonTapped(_ tag: Int) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            topViewController.showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let favoriteData = myFavoriteList[tag]
            guard let memberIdx = app.userMemberIdx else { return }
            guard let memberLike = favoriteData.memberLike else { return }
            guard let url = URL(string: URLString.SubDomain.favoritePlace.getURL()) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = memberLike ? "DELETE" : "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let params = [
                "memberIdx": memberIdx,
                "place" : favoriteData.title,
                "tid" : favoriteData.tid,
                "tlid" : favoriteData.tlid
            ] as [String : Any]

            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                    print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "favoriteButtonTapped")
            AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    print(data.status, data.message)
                    if data.status == 201 || data.status == 204 {
                        self.myFavoriteList[tag].memberLike = !memberLike
                        self.showToast(message: !memberLike ?  "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: !memberLike ?  "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.")
                        self.tableView.reloadRows(at: [IndexPath(row: tag, section: 0)], with: .automatic)
                    } else {
                        print(data.status, data.message)
                    }
                case .failure(_):
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.showCloseAlert(type: .unknownError)
                }
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
            }
        }
    }
}
