//
//  DestinationSearchViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/29.
//

import UIKit
import Alamofire

class DestinationSearchViewController: UIViewController {
    // MARK: - 변수, 상수
    private var nowPage = 1
    private var totalPage = 0
    private var timer: Timer?
    
    private var recentSearchKeywordArr = [String]()
    private var recentSearchIdxArr = [Int]()
    
    private var destinations: [DestinationDetailData] = []
    
    // MARK: - 검색화면 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = firstCellColor
        return view
    }()
    
    private let searchBar = SearchBar(frame: .zero, placeHorder: UIAccessibility.isVoiceOverRunning ? "관광지 검색창입니다. 검색후 키보드는 내려갑니다.".localized() : "어디로 갈까요?".localized())
    
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
    
    // MARK: - 검색화면_대기 UI
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
    
    private lazy var placeholdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "가고싶은 곳을 검색해보세요.\n다양한 목소리를 들으며 여행할 수 있습니다.".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Carrier_Logo_Image")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    // MARK: - 검색화면_결과 UI
    private lazy var tableShadowView: UIView = {
        let view = UIView()
        view.setupShadow()
        if !UIAccessibility.isVoiceOverRunning {
            view.isHidden = true
        }
        view.isAccessibilityElement = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        tableView.accessibilityLabel = "검색 결과 화면입니다. 현재 검색결과가 없습니다.".localized()
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
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        if !UIAccessibility.isVoiceOverRunning {
            requestRecentSearchKeyword()
            tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
            NotificationCenter.default.addObserver(self, selector: #selector(recentStackViewCheck(_:)), name: NSNotification.Name("recentCount"), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.showToVoice(type: .screenChanged, text: "현재화면은 관광지검색화면입니다.")
        }
        
        if !UIAccessibility.isVoiceOverRunning {
            recentStackViewLayoutCheck()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("recentCount"), object: nil)
    }
}

// MARK: - Extension
extension DestinationSearchViewController {
    
    
    // MARK: - 함수_기본 UI_SETUP
    func setupNavigation() {
        navigationItem.title = "관광지 검색".localized()
        
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
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        recentBasicStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        recentSearchScrollView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        recentSearchScrollView.addSubview(recentSearchStackView)
        
        recentSearchStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize/2)
            $0.trailing.equalToSuperview().inset(intervalSize/2)
            $0.bottom.equalToSuperview()
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
        
        // MARK: - 검색화면_대기 UI_SETUP
        noSearchStackView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        [placeholdLabel, placeImageView].forEach {
            noSearchView.addSubview($0)
        }
        
        placeholdLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize * 2)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(100)
        }
        
        placeImageView.snp.makeConstraints {
            $0.top.equalTo(placeholdLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        // MARK: - 검색화면_결과 UI_SETUP
        tableShadowView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        tableShadowView.addSubview(tableView)
        
        tableView.snp.makeConstraints {
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
    private func requestSearch(destinationsName: String) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard destinationsName != "" else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        var urlString = destinationSearchURL + "?keyword=\(destinationsName)&langCode=\(languageCode)&pageNo=\(nowPage)&pageSize=20000"
        if app.userLogin, let memberIdx = app.userMemberIdx {
            urlString += "&memberIdx=\(memberIdx)"
        }
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: DestinationModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.destinations = data.destinations
                    self.totalPage = data.pages.totalPages
                    if self.destinations.count == 0 {
                        if !UIAccessibility.isVoiceOverRunning {
                            self.noResultView.isHidden = false
                            self.noSearchStackView.isHidden = true
                            self.noResultLabel.text = "검색결과".localized(with: destinationsName)
                            self.tableShadowView.isHidden = true
                        }
                        self.tableView.accessibilityLabel = "검색 결과가 없습니다.".localized()
                        self.tableView.isAccessibilityElement = false
                        self.showToVoice2(type: .announcement, text: "검색결과".localized(with: destinationsName))
                        self.tableView.reloadData()
                    } else {
                        if !UIAccessibility.isVoiceOverRunning {
                            self.noSearchStackView.isHidden = true
                            self.noResultView.isHidden = true
                            self.tableShadowView.isHidden = false
                        }
                        self.tableView.accessibilityLabel = "검색결과수".localized(with: "\(self.destinations.count)")
                        self.tableView.reloadData()
                        if UIAccessibility.isVoiceOverRunning {
                            self.searchBar.resignFirstResponder()
                            self.tableView.accessibilityElementDidBecomeFocused()
                        }
                    }
                case .failure(let error):
#if DEBUG
                    print(error)
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
            "searchCode": "PLACE"
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
        let urlString = searchHistoryURL + "?memberIdx=\(memberIdx)&type=PLACE"
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
    
    private func recentStackViewLayoutCheck() {
        if !UIAccessibility.isVoiceOverRunning {
            if self.recentSearchKeywordArr.isEmpty {
                recentBasicStackView.isHidden = true
            } else {
                recentBasicStackView.isHidden = false
            }
            recentBasicStackView.reloadInputViews()
        }
    }
    
    // MARK: - 함수_objc
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
        var request = URLRequest(url: URL(string: allDeleteSearchHistoryURL + "/\(userMemberIdx)" + "?searchCode=PLACE")!)
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
}

// MARK: - SearchBar Delegate
extension DestinationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !UIAccessibility.isVoiceOverRunning {
            if searchText != "" {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (timer) in
                    self.filterContentForSearchText(searchText)
                })
            } else {
                noSearchStackView.isHidden = false
                noResultView.isHidden = true
                tableShadowView.isHidden = true
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !UIAccessibility.isVoiceOverRunning {
            postSearchKeyword(keyword: searchBar.text ?? "")
            self.filterContentForSearchText(searchBar.text!)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if UIAccessibility.isVoiceOverRunning {
            self.filterContentForSearchText(searchBar.text!)
        } else {
            searchBar.resignFirstResponder()
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        requestSearch(destinationsName: searchText)
    }
}

// MARK: - TableView Delegate
extension DestinationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = destinations[indexPath.row]
        let viewController = StorySearchSubViewController(storyTitle: destination.title, tid: destination.tid, tlid: destination.tlid, image: destination.imageUrl, favorite: destination.memberLike)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - TableView DataSource
extension DestinationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        
        let story = destinations[indexPath.row]
        cell.textLabel?.text = story.title
        cell.textLabel?.accessibilityLabel = "\(intToString(indexPath.row + 1))번 " + story.title
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - SendDataDelegate 삭제
extension DestinationSearchViewController: SendDataDelegate {
    func recieveData(response: String) {
        searchBar.text = response
        self.filterContentForSearchText(response)
    }
}
