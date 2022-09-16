//
//  StorySearchSubViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import UIKit
import Alamofire

class StorySearchSubViewController: UIViewController {
    private let frameSizeWidth = UIScreen.main.bounds.size.width * 0.7
    private var gradientLayer: CAGradientLayer!
    
    private var tid: String = ""
    private var tlid: String = ""
    private var stid: String = ""
    private var stlid: String = ""
    private var favorite: Bool {
        didSet {
            if favorite {
                favoriteButton.setImage(systemName: "star.fill", pointSize: 23)
                buttonView.backgroundColor = checkButtonColor
            } else {
                favoriteButton.setImage(systemName: "star.fill", pointSize: 23)
                buttonView.backgroundColor = moreLightGrayColor
            }
        }
    }
    private var storyTitle: String
    private var storyDetails: [StoryDetail] = []
    private var imageUrl: String
    private var nowPage = 1
    private var totalPage = 0
    
    private lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.borderColor = moreLightGrayColor?.cgColor
        tableView.layer.borderWidth = 0.5
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var imageHeaderView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private lazy var buttonView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 19
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.3
        view.backgroundColor = moreLightGrayColor
        if !UIAccessibility.isVoiceOverRunning {
            view.isHidden = true
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(requestFavorite))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(systemName: "star.fill", pointSize: 23)
        button.addTarget(self, action: #selector(requestFavorite), for: .touchUpInside)
        button.accessibilityLabel = favorite ? "즐겨찾기를 취소하는" : "즐겨찾기를 누르는"
        return button
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.accessibilityElementsHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupData()
        requestSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        requestFavoriteValidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIAccessibility.isVoiceOverRunning {
            buttonView.isHidden = false
        }
        showToVoice2(type: .screenChanged, text: "이야기화면".localized(with: storyTitle))
    }
    
    init(storyTitle: String, tid: String, tlid: String, image: String?, favorite: Bool?) {
        self.tid = tid
        self.tlid = tlid
        self.storyTitle = storyTitle
        self.imageUrl = image ?? ""
        self.favorite = favorite ?? false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        [imageHeaderView, headerView, buttonView, titleView, tableView].forEach {
            view.addSubview($0)
        }
        
        [titleLabel, subLabel].forEach {
            titleView.addSubview($0)
        }
        
        imageHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-intervalSize)
            if imageUrl == "" {
                $0.leading.equalToSuperview().offset(-intervalSize)
                $0.trailing.equalToSuperview().inset(-intervalSize)
            } else {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            $0.height.equalTo(imageHeaderView.snp.width)
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        buttonView.snp.makeConstraints {
            if imageUrl == "" {
                $0.trailing.equalTo(imageHeaderView.snp.trailing).inset(intervalSize * 2)
                $0.bottom.equalTo(imageHeaderView.snp.bottom).inset(intervalSize * 2)
            } else {
                $0.trailing.equalTo(imageHeaderView.snp.trailing).inset(intervalSize)
                $0.bottom.equalTo(imageHeaderView.snp.bottom).inset(intervalSize)
            }
            $0.height.width.equalTo(38)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(imageHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
        }
        
        subLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.leading.equalToSuperview().offset(0.5)
            $0.trailing.equalToSuperview().inset(0.5)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        buttonView.addSubview(favoriteButton)
        
        favoriteButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
    
    private func setupData() {
        titleLabel.text = storyTitle
        subLabel.text = "[\(storyDetails.count)]"
        titleLabel.accessibilityLabel = "관광지 " + titleLabel.text! + "의 이야기 \(subLabel.text!)개"
        if imageUrl == "" {
            imageHeaderView.image = landScapeImage
        } else {
            imageHeaderView.setImage(with: imageUrl, placeholder: loadingImage, cornerRadius: 0)
        }
    }
    
    private func setupNavigation() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        gradientLayer = CAGradientLayer()
        self.gradientLayer.frame = CGRect(x: 0, y: 0, width: frameSizeWidth*2, height: 100)
        self.gradientLayer.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
        headerView.layer.addSublayer(self.gradientLayer)
    }
    
    private func requestSearch() {
        var urlString = storySearchURL + "/\(tid)/\(tlid)?langCode=ko&pageNo=\(nowPage)&pageSize=20000"
        if let app = UIApplication.shared.delegate as? AppDelegate, app.userLogin, let memberIdx = app.userMemberIdx {
            urlString += "&memberIdx=\(memberIdx)"
        }
        
        AF
            .request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: StoryDetailModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.storyDetails = data.storyDetails
                    self.totalPage = data.pages.totalPages
                    self.subLabel.text = "[\(self.storyDetails.count)]"
                    self.titleLabel.accessibilityLabel = "관광지 " + self.titleLabel.text! + "의 이야기 \(self.storyDetails.count)개"
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
                    print(error)
#endif
                }
            }
    }
    
    @objc private func requestFavorite() {
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
            var request = URLRequest(url: URL(string: favoritePlace)!)
            request.httpMethod = favorite ? "DELETE" : "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let params = [
                "memberIdx": memberIdx,
                "place" : storyTitle,
                "tid" : tid,
                "tlid" : tlid
            ] as [String : Any]
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "requestFavorite")
            AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 201 || data.status == 204 {
                        self.favorite = !self.favorite
                        self.showToast(message: self.favorite ? "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: self.favorite ?  "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 삭제되었습니다.")
                    }
                case .failure(let error):
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
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
    
    private func requestFavoriteValidate() {
        guard let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, let memberIdx = app.userMemberIdx else { return }
        let urlString = favoriteValidate + "?memberIdx=\(memberIdx)&place=\(storyTitle)&tid=\(tid)&tlid=\(tlid)"
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: BasicResponseBoolModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.favorite = data.data
                case .failure(let error):
                    self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
                    print(error)
#endif
                }
            }
    }
    
}

extension StorySearchSubViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyDetail = self.storyDetails[indexPath.row]
        let viewController = StoryDetailViewController(storyDetail: storyDetail)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StorySearchSubViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let story = storyDetails[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView?.accessibilityElementsHidden = true
        cell.textLabel?.text = story.title
        cell.textLabel?.accessibilityLabel = "\(intToString(indexPath.row + 1))번 " + story.title
        cell.detailTextLabel?.text = story.audioTitle ?? ""
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.accessibilityElementsHidden = true
        return cell
    }
}

