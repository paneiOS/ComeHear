//
//  FeelStoreSearchViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/23.
//

import UIKit
import Alamofire

class FeelStoreSearchViewController: UIViewController {
    // MARK: - 변수, 상수
    private var timer: Timer?
    private var recentSearchKeywordArr = [String]()
    private var recentSearchIdxArr = [Int]()
    
    private let segmentedItems = ["인기 Top10".localized(), "최신 Top10".localized()]
    private var myFeelBoolList = [Bool]()
    private var searchFeelList: [MyFeelShareDataList] = []
    private var topFeelList: [FeelListData] = []
    
    //MARK: - 최근검색어 UI
    private let separatorView = SeparatorView(frame: .zero, color: moreLightGrayColor ?? .white)
    
    private lazy var noSearchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        
        [
            recentBasicStackView,
            noSearchCoverView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var recentBasicStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.isHidden = true
        stackView.setupShadow(cornerRadius: 0)
        [
            separatorView,
            recentSearchHeaderView,
            recentSearchScrollView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var recentSearchHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var recentSearchHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .lightGray
        label.text = "최근검색어".localized()
        label.accessibilityLabel = "최근검색어입니다.".localized()
        return label
    }()
    
    private lazy var recentSearchHeaderButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체삭제".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.addTarget(self, action: #selector(tapAllDeleteKeyRecentSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var recentSearchScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var recentSearchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    // MARK: - 검색화면 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = personalColor
        return view
    }()
    
    private let searchBar = SearchBar(frame: .zero, placeHorder: "느끼고 싶은 곳을 입력해주세요.".localized())
    
    // MARK: - 검색화면_대기_Top10 UI
    private lazy var noSearchCoverView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var noSearchView: UIView = {
        let view = UIView()
        view.setupShadow()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        return view
    }()
    
    private lazy var seguementedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: segmentedItems)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var topTenTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(MyFeelLikeTableViewCell.self, forCellReuseIdentifier: "MyFeelLikeTableViewCell")
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        return tableView
    }()
    
    // MARK: - 검색화면_결과없음 UI
    private lazy var noResultView: UIView = {
        let view = UIView()
        view.setupShadow()
        view.isHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        return view
    }()
    
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var noResultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Book_Search_Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - 검색화면_결과 UI
    private lazy var tableShadowView: UIView = {
        let view = UIView()
        view.setupShadow()
        view.isHidden = true
        return view
    }()
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.register(MyFeelSectionTableViewCell.self, forCellReuseIdentifier: "MyFavoriteTableViewSectionCell")
        tableView.register(MyFeelLikeTableViewCell.self, forCellReuseIdentifier: "MyFeelLikeTableViewCell")
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        return tableView
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        requestRecentSearchKeyword()
        searchTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        NotificationCenter.default.addObserver(self, selector: #selector(recentStackViewCheck(_:)), name: NSNotification.Name("recentCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSearchData), name: NSNotification.Name("reportAfterReload"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupState()
        recentStackViewLayoutCheck()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 느낌저장소입니다. 느낌검색과 인기느낌, 최신느낌 Top10을 제공하고 있습니다.".localized())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("recentCount"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reportAfterReload"), object: nil)
    }
}
// MARK: - Extension
extension FeelStoreSearchViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "느낌 저장소".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        searchBar.delegate = self
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        [searchBar, mainContentView].forEach {
            view.addSubview($0)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        mainContentView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [
            noSearchStackView,
            tableShadowView,
            noResultView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        [recentSearchHeaderLabel, recentSearchHeaderButton].forEach {
            recentSearchHeaderView.addSubview($0)
        }
        
        recentSearchHeaderLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        recentSearchHeaderButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(recentSearchHeaderLabel.snp.trailing).offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        recentBasicStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        recentSearchScrollView.addSubview(recentSearchStackView)
        
        recentSearchStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        noSearchCoverView.snp.makeConstraints {
            $0.top.equalTo(recentBasicStackView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        noSearchCoverView.addSubview(noSearchView)
        
        noSearchView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        // MARK: - 검색화면_Top10 UI_SETUP
        noSearchStackView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [
            seguementedControl, topTenTableView
        ].forEach {
            noSearchView.addSubview($0)
        }
        
        seguementedControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/2)
            $0.leading.equalToSuperview().offset(intervalSize/2)
            $0.trailing.equalToSuperview().inset(intervalSize/2)
        }
        
        topTenTableView.snp.makeConstraints {
            $0.top.equalTo(seguementedControl.snp.bottom).offset(intervalSize)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        // MARK: - 검색화면_결과 UI_SETUP
        tableShadowView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        tableShadowView.addSubview(searchTableView)
        
        searchTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // MARK: - 검색화면_결과없음 UI_SETUP
        noResultView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(intervalSize)
        }
        
        [noResultLabel, noResultImageView].forEach {
            noResultView.addSubview($0)
        }
        
        noResultLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(100)
        }
        
        noResultImageView.snp.makeConstraints {
            $0.top.equalTo(noResultLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
    }
    
    // MARK: - API Request
    private func requestTopData(_ type: String) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        var urlString = feelListTopURL + "?sortType=\(type)" + "&langCode=\(languageCode)"
        if app.loginState == .login, let memberIdx = app.userMemberIdx {
            urlString += "&memberIdx=\(memberIdx)"
        }
        LoadingIndicator.showLoading(className: "FeelStoreSearchViewController", function: "requestTopData")
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: FeelListModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.topFeelList = data.feelList
                    self.topTenTableView.reloadData()
                    LoadingIndicator.hideLoading()
                case .failure(let error):
                    LoadingIndicator.hideLoading()
#if DEBUG
                    print(error)
#endif
                }
            }
    }
    
    private func requestSearchData(searchKeyword: String) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard searchKeyword != "" else { return searchFeelList.removeAll() }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        var urlString = feelSearchURL + "?pageNo=1&pageSize=20000&langCode=\(languageCode)&Place=\(searchKeyword)"
        if let userMemberIdx = app.userMemberIdx {
            urlString += "&memberIdx=\(userMemberIdx)"
        }
        print("urlString", urlString)
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: MyFeelShareDataModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.searchFeelList = data.myFeelShareList
                    self.myFeelBoolList = Array(repeating: false, count: data.myFeelShareList.count)
                    if self.searchFeelList.count == 0 {
                        self.noSearchStackView.isHidden = true
                        self.noResultView.isHidden = false
                        self.tableShadowView.isHidden = true
                        self.noResultLabel.text = "검색결과".localized(with: searchKeyword)
                    } else {
                        self.noSearchStackView.isHidden = true
                        self.noResultView.isHidden = true
                        self.tableShadowView.isHidden = false
                    }
                    self.searchTableView.reloadData()
                case .failure(let error):
                    self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
                    print("error", error)
#endif
                }
            }
    }
    
    private func postSearchKeyword(keyword: String) {
        guard !UIAccessibility.isVoiceOverRunning else { return }
        guard keyword != "" else { return }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let memberIdx = app.userMemberIdx else { return }
        
        var request = URLRequest(url: URL(string: searchHistoryURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params = [
            "keyword": keyword,
            "memberIdx": memberIdx,
            "searchCode": "FEEL"
        ] as [String : Any]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
            print("http Body Error")
#endif
        }
        
        LoadingIndicator.showLoading(className: self.className, function: "postSearchKeyword")
        AF.request(request).responseDecodable(of: RecentSearchKeywordModel.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status != 200 {
                    let index = (self.recentSearchIdxArr.firstIndex(of: data.recentSearchArr[0].historyIdx) ?? 0)
                    self.recentSearchIdxArr.remove(at: index)
                    self.recentSearchKeywordArr.remove(at: index)
                    self.recentSearchStackView.arrangedSubviews[index].removeFromSuperview()
                    self.recentSearchStackView.reloadInputViews()
                    if !self.recentSearchKeywordArr.isEmpty {
                        self.recentBasicStackView.isHidden = false
                    }
                }
                
                let recentSearchView = RecentSearchView(frame: .zero, text: data.recentSearchArr[0].keyword, historyIdx: data.recentSearchArr[0].historyIdx)
                self.recentSearchIdxArr.insert(data.recentSearchArr[0].historyIdx, at: 0)
                self.recentSearchKeywordArr.insert(data.recentSearchArr[0].keyword, at: 0)
                self.recentSearchStackView.insertArrangedSubview(recentSearchView, at: 0)
                self.recentSearchStackView.reloadInputViews()
                recentSearchView.delegate = self
                self.recentStackViewLayoutCheck()
                
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
#if DEBUG
                print(error)
#endif
            }
        }
    }
    
    private func requestRecentSearchKeyword() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let memberIdx = app.userMemberIdx else { return }
        let urlString = searchHistoryURL + "?memberIdx=\(memberIdx)&type=FEEL"
        LoadingIndicator.showLoading(className: self.className, function: "requestRecentSearchKeyword")
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: RecentSearchKeywordModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    for (_, value) in data.recentSearchArr.enumerated() {
                        self.recentSearchKeywordArr.append(value.keyword)
                        self.recentSearchIdxArr.append(value.historyIdx)
                        let recentSearchView = RecentSearchView(frame: .zero, text: value.keyword, historyIdx: value.historyIdx)
                        self.recentSearchStackView.insertArrangedSubview(recentSearchView, at: self.recentSearchKeywordArr.count - 1)
                        self.recentSearchStackView.reloadInputViews()
                        recentSearchView.delegate = self
                    }
                    self.recentStackViewLayoutCheck()
                    
                    DispatchQueue.main.async {
                        LoadingIndicator.hideLoading()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        LoadingIndicator.hideLoading()
                    }
#if DEBUG
                    print(error)
#endif
                }
            }
    }
    
    // MARK: - 함수
    private func setupState() {
        indexChanged()
    }
    
    private func recentStackViewLayoutCheck() {
        if self.recentSearchKeywordArr.isEmpty {
            recentBasicStackView.isHidden = true
        } else {
            if !UIAccessibility.isVoiceOverRunning {
                recentBasicStackView.isHidden = false
            } else {
                recentBasicStackView.isHidden = true
            }
        }
        recentBasicStackView.reloadInputViews()
    }
    
    // MARK: - 함수_objc
    @objc private func indexChanged() {
        switch seguementedControl.selectedSegmentIndex {
        case 0:
            requestTopData("like")
        case 1:
            requestTopData("reg")
        default:
            return
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            searchBar.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    @objc func tapAllDeleteKeyRecentSearch() {
        recentSearchStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        recentSearchKeywordArr.removeAll()
        recentStackViewLayoutCheck()
        self.showToVoice(type: .announcement, text: "최근검색어를 모두 삭제하였습니다.")
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let userMemberIdx = app.userMemberIdx else { return }
        var request = URLRequest(url: URL(string: allDeleteSearchHistoryURL + "/\(userMemberIdx)" + "?searchCode=FEEL")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        AF.request(request).responseDecodable(of: Login.self) { _ in }
    }
    
    @objc private func recentStackViewCheck(_ notification: Notification) {
        guard let historyIdx = notification.object as? Int else { return }
        let index = recentSearchIdxArr.firstIndex(of: historyIdx)!
        recentSearchIdxArr.remove(at: index)
        recentSearchKeywordArr.remove(at: index)
        recentStackViewLayoutCheck()
    }
    
    @objc private func reloadSearchData() {
        requestSearchData(searchKeyword: searchBar.text ?? "")
    }
}

// MARK: - SearchBar Delegate
extension FeelStoreSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            if !UIAccessibility.isVoiceOverRunning {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (timer) in
                    self.filterContentForSearchText(searchBar.text!)
                })
            }
        } else {
            noSearchStackView.isHidden = false
            noResultView.isHidden = true
            tableShadowView.isHidden = true
            searchTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        postSearchKeyword(keyword: searchBar.text ?? "")
        if UIAccessibility.isVoiceOverRunning {
            self.filterContentForSearchText(searchBar.text!)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        requestSearchData(searchKeyword: searchText)
    }
}

// MARK: - TableView Delegate
extension FeelStoreSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            if indexPath.row == 0 {
                myFeelBoolList[indexPath.section] = !myFeelBoolList[indexPath.section]
                tableView.reloadSections([indexPath.section], with: .automatic)
            }
        }
    }
}

// MARK: - TableView DataSource
extension FeelStoreSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            if myFeelBoolList.count != 0 {
                if myFeelBoolList[section] {
                    return searchFeelList[section].list.count + 1
                } else {
                    return 1
                }
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchTableView {
            return myFeelBoolList.count
        } else {
            return topFeelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return UITableViewCell() }
        if tableView == searchTableView {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewSectionCell") as? MyFeelSectionTableViewCell else { return UITableViewCell() }
                cell.titleLabel.text = "# \(searchFeelList[indexPath.section].place) ( \(searchFeelList[indexPath.section].list.count) )"
                if myFeelBoolList[indexPath.section] {
                    cell.openButton.setImage(systemName: "chevron.up", pointSize: buttonSize)
                    cell.contentView.backgroundColor = moreLightGrayColor
                } else {
                    cell.openButton.setImage(systemName: "chevron.down", pointSize: buttonSize)
                    cell.contentView.backgroundColor = .white
                }
                
                cell.titleLabel.accessibilityElementsHidden = true
                cell.openButton.accessibilityElementsHidden = true
                cell.accessibilityTraits = .button
                if app.languageCode == "ko" {
                    if myFeelBoolList[indexPath.section] {
                        cell.accessibilityLabel = "\(searchFeelList[indexPath.section].place)의 이야기 느낌 \(searchFeelList[indexPath.section].list.count)개 접기 버튼"
                    } else {
                        cell.accessibilityLabel = "\(searchFeelList[indexPath.section].place)의 이야기 느낌 \(searchFeelList[indexPath.section].list.count)개 펼치기 버튼"
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFeelLikeTableViewCell") as? MyFeelLikeTableViewCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.cellDelegate = self
                cell.feelList = searchFeelList[indexPath.section].list[indexPath.row-1]
                cell.titleLabel.text = searchFeelList[indexPath.section].list[indexPath.row-1].title
                if app.languageCode == "ko" {
                    cell.titleLabel.accessibilityLabel = "\(intToString(indexPath.row))번" + searchFeelList[indexPath.section].list[indexPath.row-1].title
                    cell.listenButton.accessibilityLabel = "\(intToString(indexPath.row))번" + searchFeelList[indexPath.section].list[indexPath.row-1].title + "듣기"
                    cell.reportButton.accessibilityLabel = "\(intToString(indexPath.row))번" + searchFeelList[indexPath.section].list[indexPath.row-1].title + "신고하기"
                }
                cell.indexPath = IndexPath(item: indexPath.row-1, section: indexPath.section)
                cell.tableIndex = 1
                if (searchFeelList[indexPath.section].list[indexPath.row-1].memberLike ?? false) {
                    cell.likeButton.setImage(systemName: "heart.fill", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "\(intToString(indexPath.row))번" + searchFeelList[indexPath.section].list[indexPath.row-1].title + "의 좋아요를 취소하는"
                    }
                } else {
                    cell.likeButton.setImage(systemName: "heart", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "\(intToString(indexPath.row))번" + searchFeelList[indexPath.section].list[indexPath.row-1].title + "의 좋아요를 누르는"
                    }
                }
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyFeelLikeTableViewCell") as? MyFeelLikeTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.cellDelegate = self
            cell.feelList = topFeelList[indexPath.section]
            cell.titleLabel.text = topFeelList[indexPath.section].title
            if seguementedControl.selectedSegmentIndex == 0 {
                if app.languageCode == "ko" {
                    cell.titleLabel.accessibilityLabel = "인기느낌 \(intToString(indexPath.section + 1))위 제목" + topFeelList[indexPath.section].title
                    cell.listenButton.accessibilityLabel = "인기느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "듣기"
                    cell.reportButton.accessibilityLabel = "인기느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "신고하기"
                }
                
                if (topFeelList[indexPath.section].memberLike ?? false) {
                    cell.likeButton.setImage(systemName: "heart.fill", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "인기느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "의 좋아요를 취소하는"
                    }
                } else {
                    cell.likeButton.setImage(systemName: "heart", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "인기느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "의 좋아요를 누르는"
                    }
                }
            } else {
                if app.languageCode == "ko" {
                    cell.titleLabel.accessibilityLabel = "최신느낌 \(intToString(indexPath.section + 1))위 제목" + topFeelList[indexPath.section].title
                    cell.listenButton.accessibilityLabel = "최신느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "듣기"
                    cell.reportButton.accessibilityLabel = "최신느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "신고하기"
                }
                if (topFeelList[indexPath.section].memberLike ?? false) {
                    cell.likeButton.setImage(systemName: "heart.fill", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "최신느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "의 좋아요를 취소하는"
                    }
                } else {
                    cell.likeButton.setImage(systemName: "heart", pointSize: buttonSize)
                    if app.languageCode == "ko" {
                        cell.likeButton.accessibilityLabel = "최신느낌 \(intToString(indexPath.section + 1))위" + topFeelList[indexPath.section].title + "의 좋아요를 누르는"
                    }
                }
            }
            
            cell.indexPath = IndexPath(item: indexPath.row, section: indexPath.section)
            cell.tableIndex = 0
            return cell
        }
    }
}

// MARK: - TableView_Cell Deleagte
extension FeelStoreSearchViewController: MyFeelLikeTableViewDelegate {
    
    
    // MARK: - 듣기_버튼
    func feelListenButtonTapped(_ feel: FeelListData) {
        LoadingIndicator.showLoading(className: self.className, function: "feelListenButtonTapped")
        let playViewController = FeelPlayViewController()
        playViewController.selectFeel = feel
        playViewController.feelTitleView.text = "제목".localized() + " - \(feel.title)"
        playViewController.writer.text = "\(feel.regMemberNickname ?? "")" + "님의 느낌".localized()
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
    
    // MARK: - 좋아요_버튼
    func feelLikeButtonTapped(_ indexPath: IndexPath, _ tableIndex: Int?) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            topViewController.showTwoActionAlert("로그인이 필요합니다.\n로그인페이지로 이동하시겠습니까?", "로그인", loginAction)
        } else {
            guard let memberIdx = app.userMemberIdx else { return }
            let feel = tableIndex != 0 ? searchFeelList[indexPath.section].list[indexPath.row] : topFeelList[indexPath.section]
            var request = URLRequest(url: URL(string: feelLikeURL)!)
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
                        if tableIndex == 0 {
                            self.topFeelList[indexPath.section].memberLike = !(self.topFeelList[indexPath.section].memberLike ?? false)
                            self.topTenTableView.reloadData()
                        } else {
                            self.searchFeelList[indexPath.section].list[indexPath.row].memberLike = !(self.searchFeelList[indexPath.section].list[indexPath.row].memberLike ?? false)
                            self.searchTableView.reloadData()
                        }
                        self.showToast(message: "'좋아요'를 눌렀습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "좋아요를 눌렀습니다.")
                    } else if data.status == 204{
                        if tableIndex == 0 {
                            self.topFeelList[indexPath.section].memberLike = !(self.topFeelList[indexPath.section].memberLike ?? false)
                            self.topTenTableView.reloadData()
                        } else {
                            self.searchFeelList[indexPath.section].list[indexPath.row].memberLike = !(self.searchFeelList[indexPath.section].list[indexPath.row].memberLike ?? false)
                            self.searchTableView.reloadData()
                        }
                        self.showToast(message: "'좋아요'를 취소하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "좋아요를 취소하였습니다.")
                    } else {
#if DEBUG
                        print(data.status, data.message)
#endif
                    }
                case .failure(let error):
#if DEBUG
                    print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
#endif
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
            topViewController.showTwoActionAlert("로그인이 필요합니다.\n로그인페이지로 이동하시겠습니까?", "로그인", loginAction)
        } else {
            let feelReportViewController = FeelReportViewController(selectFeel: feel)
            searchBar.endEditing(true)
            feelReportViewController.hero.isEnabled = true
            feelReportViewController.hero.modalAnimationType = .fade
            feelReportViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
            present(feelReportViewController, animated: true)
        }
    }
}

// MARK: - SendDataDelegate 삭제
extension FeelStoreSearchViewController: SendDataDelegate {
    func recieveData(response: String) {
        searchBar.text = response
        self.filterContentForSearchText(response)
    }
}
