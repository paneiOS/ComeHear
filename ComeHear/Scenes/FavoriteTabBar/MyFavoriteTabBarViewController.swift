//
//  MyFavoriteTabBarViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/29.
//

import UIKit
import Alamofire

class MyFavoriteTabBarViewController: UIViewController {
    private let constantSize = ConstantSize()
    // MARK: - 변수, 상수
    private let seguementedItems = ["즐겨찾기 한 관광지".localized(), "내가 좋아요 한 느낌".localized()]
    private var myFavoriteList = [DestinationDetailData]()
    private var myFeelBoolList = [Bool]()
    private var myFeelShareList = [MyFeelShareDataList]()
    
    // MARK: - 즐겨찾기_로그아웃상태 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    private lazy var logoutStateCoverView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var logoutStatePlacehold: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "ComeHear는 다양한 서비스를 제공하고 있습니다.\n\n로그인 후 다양한 서비스를 만나보세요!!".localized()
        return label
    }()
    
    private lazy var logoutStateCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LandScape_Puzzle_Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "로그인".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 로그인상태 UI
    private lazy var loginStateView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var seguementedControlView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        seguementedControl.setupShadow(cornerRadius: 0)
        return view
    }()
    
    private lazy var seguementedControl: UISegmentedControl = {
        let seguementedControl = UISegmentedControl(items: seguementedItems)
        seguementedControl.selectedSegmentIndex = 0
        seguementedControl.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
        return seguementedControl
    }()
    
    // MARK: - 로그인상태_즐겨찾기 UI
    private lazy var favoriteView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var favoriteCoverView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var favoriteCoverPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakStrategy = .hangulWordPriority
        label.text = "아직 \"즐겨찾기\"에 추가된 관광지가 없습니다.\n\n어떤곳들이 있는지 검색해보세요!".localized()
        return label
    }()
    
    private lazy var favoriteSearchTabButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "관광지 검색하러 가기".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(tapSearchTabButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoriteCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ContentImage.landScapeImage.getImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var favoriteTableView: UITableView = {
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
        tableView.clipsToBounds = true
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - 로그인상태_좋아요느낌 UI
    private lazy var feelLikeView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var feelLikeCoverView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var feelLikeCoverPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "아직 \"좋아요\"를 누르신 느낌이 없습니다.\n\n좋아하는 느낌을 추가하기 위해 여행지를 검색해보세요!".localized()
        return label
    }()
    
    private lazy var feelLikeSearchTabButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "관광지 검색하러 가기".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(tapSearchTabButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var feelLikeCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Woman_Logo_Record_Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var feelLikeTableShadowView: UIView = {
        let view = UIView()
        view.setupShadow()
        view.isHidden = true
        return view
    }()
    
    private lazy var feelLikeTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(MyFeelSectionTableViewCell.self, forCellReuseIdentifier: "MyFavoriteTableViewSectionCell")
        tableView.register(MyFeelLikeTableViewCell.self, forCellReuseIdentifier: "MyFeelLikeTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
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
        NotificationCenter.default.addObserver(self, selector: #selector(indexChanged), name: NSNotification.Name("reportAfterReload"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 즐겨찾기화면입니다. 관광지와 느낌 두종류의 즐겨찾기를 제공하고있습니다.")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reportAfterReload"), object: nil)
    }
}


extension MyFavoriteTabBarViewController {
    // MARK: - 함수_기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "탭바4".localized()
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
            seguementedControlView,
            logoutStateCoverView,
            loginStateView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        seguementedControlView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        seguementedControlView.addSubview(seguementedControl)
        
        seguementedControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        // MARK: - 로그아웃상태 UI_SETUP
        logoutStateCoverView.snp.makeConstraints {
            $0.top.equalTo(seguementedControlView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(constantSize.intervalSize)
        }
        
        [
            logoutStatePlacehold, loginButton, logoutStateCoverImageView
        ].forEach {
            logoutStateCoverView.addSubview($0)
        }
        
        logoutStatePlacehold.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        logoutStateCoverImageView.snp.makeConstraints {
            $0.top.equalTo(logoutStatePlacehold.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(logoutStateCoverImageView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        // MARK: - 로그인상태 UI_SETUP
        loginStateView.snp.makeConstraints {
            $0.top.equalTo(seguementedControlView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [favoriteView, feelLikeView].forEach {
            loginStateView.addSubview($0)
        }
        
        // MARK: - 로그인상태_즐겨찾기 UI_SETUP
        favoriteView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [favoriteCoverView, favoriteTableView].forEach {
            favoriteView.addSubview($0)
        }
        
        favoriteCoverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            favoriteCoverPlaceholderLabel, favoriteSearchTabButton, favoriteCoverImageView
        ].forEach {
            favoriteCoverView.addSubview($0)
        }
        
        favoriteCoverPlaceholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        favoriteSearchTabButton.snp.makeConstraints {
            $0.top.equalTo(favoriteCoverPlaceholderLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        favoriteCoverImageView.snp.makeConstraints {
            $0.top.equalTo(favoriteSearchTabButton.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.height.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
        }
        
        favoriteTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // MARK: - 로그인상태_좋아요느낌 UI_SETUP
        feelLikeView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [feelLikeCoverView, feelLikeTableShadowView].forEach {
            feelLikeView.addSubview($0)
        }
        
        feelLikeCoverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            feelLikeCoverPlaceholderLabel, feelLikeSearchTabButton, feelLikeCoverImageView
        ].forEach {
            feelLikeCoverView.addSubview($0)
        }
        
        feelLikeCoverPlaceholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        feelLikeSearchTabButton.snp.makeConstraints {
            $0.top.equalTo(feelLikeCoverPlaceholderLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        feelLikeCoverImageView.snp.makeConstraints {
            $0.top.equalTo(feelLikeSearchTabButton.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
        }
        
        feelLikeTableShadowView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        feelLikeTableShadowView.addSubview(feelLikeTableView)
        
        feelLikeTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - 함수_API
    private func requestData() {
        if seguementedControl.selectedSegmentIndex == 0 {
            self.favoriteCoverView.isHidden = true
            self.favoriteTableView.isHidden = true
            guard let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, let memberIdx = app.userMemberIdx else { return }
            let urlString = URLString.SubDomain.favoritePlace.getURL() + "?memberIdx=\(memberIdx)&pageNo=1&pageSize=20000"
            LoadingIndicator.showLoading(className: self.className, function: "requestData")
            AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                .responseDecodable(of: DestinationModel.self) { [weak self] response in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        self.myFavoriteList = data.destinations
                        self.favoriteTableView.reloadData()
                        if self.myFavoriteList.count == 0 {
                            self.favoriteCoverView.isHidden = false
                            self.favoriteTableView.isHidden = true
                        } else {
                            self.favoriteCoverView.isHidden = true
                            self.favoriteTableView.isHidden = false
                        }
                        LoadingIndicator.hideLoading()
                    case .failure(_):
                        LoadingIndicator.hideLoading()
                        self.showCloseAlert(type: .unknownError)
                        self.favoriteCoverView.isHidden = false
                    }
                }
        } else {
            self.feelLikeCoverView.isHidden = true
            self.feelLikeTableView.isHidden = true
            self.feelLikeTableShadowView.isHidden = true
            guard let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, let memberIdx = app.userMemberIdx else { return }
            let urlString = URLString.SubDomain.feelLikeURL.getURL() + "?memberIdx=\(memberIdx)"
            
            AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                .responseDecodable(of: MyFeelShareDataModel.self) { [weak self] response in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        self.myFeelShareList = data.myFeelShareList
                        self.myFeelBoolList = Array(repeating: false, count: data.myFeelShareList.count)
                        self.feelLikeTableView.reloadData()
                        if self.myFeelShareList.count == 0 {
                            self.feelLikeCoverView.isHidden = false
                            self.feelLikeTableView.isHidden = true
                            self.feelLikeTableShadowView.isHidden = true
                        } else {
                            self.feelLikeCoverView.isHidden = true
                            self.feelLikeTableView.isHidden = false
                            self.feelLikeTableShadowView.isHidden = false
                        }
                        LoadingIndicator.hideLoading()
                    case .failure(_):
                        LoadingIndicator.hideLoading()
                        self.showCloseAlert(type: .unknownError)
                    }
                }
        }
    }
    private func setupState() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.loginState == .login {
            loginStateView.isHidden = false
            logoutStateCoverView.isHidden = true
            indexChanged()
        } else {
            loginStateView.isHidden = true
            logoutStateCoverView.isHidden = false
        }
    }
    
    // MARK: - @objc
    @objc private func indexChanged() {
        switch seguementedControl.selectedSegmentIndex {
        case 0:
            favoriteView.isHidden = false
            feelLikeView.isHidden = true
            requestData()
        case 1:
            favoriteView.isHidden = true
            feelLikeView.isHidden = false
            requestData()
        default:
            return
        }
    }
    
    @objc private func login() {
        let loginViewContrller = LoginViewController()
        guard let topViewController = keyWindow?.visibleViewController else { return }
        topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
    }
    
    @objc private func tapSearchTabButton() {
        if UIAccessibility.isVoiceOverRunning {
            self.tabBarController?.selectedIndex = 0
        } else {
            self.tabBarController?.selectedIndex = 2
        }
    }
}

// MARK: - TableView Delegate
extension MyFavoriteTabBarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == favoriteTableView {
            let favoriteData = myFavoriteList[indexPath.row]
            let viewController = StorySearchSubViewController(storyTitle: favoriteData.title, tid: favoriteData.tid, tlid: favoriteData.tlid, image: favoriteData.imageUrl, favorite: favoriteData.memberLike)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            if indexPath.row == 0 {
                guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
                if app.languageCode == "ko" {
                    if myFeelBoolList[indexPath.section] {
                        showToVoice2(type: .announcement, text: "\(myFeelShareList[indexPath.section].place)의 느낌목록을 접었습니다.")
                    } else {
                        showToVoice2(type: .announcement, text: "\(myFeelShareList[indexPath.section].place)의 느낌목록을 펼쳤습니다.")
                    }
                }
                myFeelBoolList[indexPath.section] = !myFeelBoolList[indexPath.section]
                tableView.reloadSections([indexPath.section], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == favoriteTableView {
            return 200
        } else {
            return 50
        }
    }
}
// MARK: - TableView DataSource
extension MyFavoriteTabBarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == feelLikeTableView {
            return myFeelShareList.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == favoriteTableView {
            return myFavoriteList.count
        } else {
            if myFeelBoolList[section] {
                return myFeelShareList[section].list.count + 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return UITableViewCell() }
        if tableView == favoriteTableView {
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
            if app.languageCode == "ko" {
                cell.bgImageShadowView.accessibilityLabel = myFavoriteList[indexPath.row].title + "관광지 선택"
            }
            cell.shouldGroupAccessibilityChildren = true
            return cell
            
        } else {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewSectionCell") as? MyFeelSectionTableViewCell else { return UITableViewCell() }
                cell.titleLabel.text = "# \(myFeelShareList[indexPath.section].place) ( \(myFeelShareList[indexPath.section].list.count) )"
                if myFeelBoolList[indexPath.section] {
                    cell.openButton.setImage(systemName: "chevron.up", pointSize: constantSize.buttonSize)
                    cell.contentView.backgroundColor = ContentColor.moreLightGrayColor.getColor()
                    if app.languageCode == "ko" {
                        cell.accessibilityLabel = "\(myFeelShareList[indexPath.section].place)의 이야기 느낌 \(myFeelShareList[indexPath.section].list.count)개 접기 버튼"
                    }
                } else {
                    cell.openButton.setImage(systemName: "chevron.down", pointSize: constantSize.buttonSize)
                    cell.contentView.backgroundColor = .white
                    if app.languageCode == "ko" {
                        cell.accessibilityLabel = "\(myFeelShareList[indexPath.section].place)의 이야기 느낌 \(myFeelShareList[indexPath.section].list.count)개 펼치기 버튼"
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFeelLikeTableViewCell") as? MyFeelLikeTableViewCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.cellDelegate = self
                cell.feelList = myFeelShareList[indexPath.section].list[indexPath.row-1]
                cell.titleLabel.text = myFeelShareList[indexPath.section].list[indexPath.row-1].title
                cell.indexPath = IndexPath(item: indexPath.row-1, section: indexPath.section)
                if (myFeelShareList[indexPath.section].list[indexPath.row-1].memberLike ?? false) {
                    cell.likeButton.setImage(systemName: "heart.fill", pointSize: constantSize.buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "좋아요를 취소하는"
                    }
                } else {
                    cell.likeButton.setImage(systemName: "heart", pointSize: constantSize.buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "좋아요를 누르는"
                    }
                }
                return cell
            }
        }
    }
}

// MARK: - Delegate 버튼(즐겨찾기)
extension MyFavoriteTabBarViewController: MyFavoriteTableViewDelegate {
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
            
            LoadingIndicator.showLoading(className: self.className, function: "MyFavoriteTabBarViewController")
            AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 201 || data.status == 204 {
                        self.myFavoriteList[tag].memberLike = !memberLike
                        self.showToast(message: !memberLike ?  "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: !memberLike ?  "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.")
                        self.favoriteTableView.reloadRows(at: [IndexPath(row: tag, section: 0)], with: .automatic)
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


// MARK: - Delegate 버튼(듣기, 좋아요, 신고)
extension MyFavoriteTabBarViewController: MyFeelLikeTableViewDelegate {
    // MARK: - 듣기_버튼
    func feelListenButtonTapped(_ feel: FeelListData) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            topViewController.showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            LoadingIndicator.showLoading(className: self.className, function: "feelListenButtonTapped")
            let playViewController = FeelPlayViewController()
            playViewController.selectFeel = feel
            playViewController.feelTitleView.text = "재생화면".localized() + " - \(feel.title)"
            playViewController.writer.text = "\(feel.regMemberNickname ?? "") " + "님의 느낌".localized()
            playViewController.audioURL = feel.audioUrl
            
            DispatchQueue.background(
                background: {
                    playViewController.setupAVAudioPlayer()
                },
                completion: {
                    playViewController.hero.isEnabled = true
                    playViewController.hero.modalAnimationType = .fade
                    playViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.present(playViewController, animated: true, completion: nil)
                }
            )
            
        }
    }
    
    // MARK: - 좋아요_버튼
    func feelLikeButtonTapped(_ indexPath: IndexPath, _ tableIndex: Int?) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            topViewController.showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            guard let memberIdx = app.userMemberIdx else { return }
            let feel = myFeelShareList[indexPath.section].list[indexPath.row]
            guard let url = URL(string: URLString.SubDomain.feelLikeURL.getURL()) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = (feel.memberLike ?? false) ? "DELETE" : "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let params = [
                "likeMemberIdx": memberIdx,
                "regMemberIdx": feel.regMemberIdx ?? 0,
                "stid" : feel.stid,
                "stlid" : feel.stlid,
                "title" : feel.title
            ] as [String : Any]
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "feelLikeButtonTapped")
            AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 201 {
                        self.myFeelShareList[indexPath.section].list[indexPath.row].memberLike = !(self.myFeelShareList[indexPath.section].list[indexPath.row].memberLike ?? false)
                        self.showToast(message: "'좋아요'를 눌렀습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "좋아요를 눌렀습니다.")
                        self.feelLikeTableView.reloadData()
                    } else if data.status == 204{
                        self.myFeelShareList[indexPath.section].list[indexPath.row].memberLike = !(self.myFeelShareList[indexPath.section].list[indexPath.row].memberLike ?? false)
                        topViewController.showToast(message: "'좋아요'를 취소하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "좋아요를 취소하였습니다.")
                        self.feelLikeTableView.reloadData()
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
    
    // MARK: - 신고_버튼
    func feelReportTapped(_ feel: FeelListData) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            topViewController.showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let feelReportViewController = FeelReportViewController(selectFeel: feel)
            feelReportViewController.hero.isEnabled = true
            feelReportViewController.hero.modalAnimationType = .fade
            feelReportViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
            present(feelReportViewController, animated: true)
        }
    }
}

