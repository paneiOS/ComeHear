//
//  StoryDetailMiddleView.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import SnapKit
import UIKit
import Alamofire

final class StoryDetailMiddleView: UIView {
    lazy var feelList: [FeelListData] = [] {
        didSet {
            if feelList.isEmpty {
                placeHolderLabel.isHidden = false
            } else {
                placeHolderLabel.isHidden = true
            }
        }
    }
    var feelListData: FeelListData?
    
    private lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: moreLightGrayColor)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    lazy var feelCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    lazy var tableView: DynamicTableView = {
        let tableView = DynamicTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(SearchFeelStoreTableViewCell.self, forCellReuseIdentifier: "SearchFeelStoreTableViewCell")
        return tableView
    }()
    
    lazy var placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "아름다운 당신의 목소리를 들려주세요.".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Woman_Logo_Record_Image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var feelShareButton: UIButton = {
        let button = UIButton()
        button.setTitle("느낌 공유하기".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(named: "ButtonColor")
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .bold)
        button.layer.cornerRadius = 20.0
        button.hero.id = "FeelRecordViewController_Button"
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadFeelList(_:)),
            name: NSNotification.Name("reloadFeelList"),
            object: nil
        )
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reloadFeelList"), object: nil)
    }
}

extension StoryDetailMiddleView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension StoryDetailMiddleView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFeelStoreTableViewCell", for: indexPath) as? SearchFeelStoreTableViewCell else { return UITableViewCell() }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.feelList = feelList[indexPath.row]
        self.feelListData = feelList[indexPath.row]
        cell.titleLabel.text = feelList[indexPath.row].title
        if app.languageCode == "ko" {
            cell.titleLabel.accessibilityLabel = "\(intToString(indexPath.row + 1))번 제목" + feelList[indexPath.row].title
            cell.listenButton.accessibilityLabel = "\(intToString(indexPath.row + 1))번" + feelList[indexPath.row].title + "의 듣기"
            cell.sendButton.accessibilityLabel = "\(intToString(indexPath.row + 1))번" + feelList[indexPath.row].title + "의 신고하기"
        }
        
        cell.listenButton.tag = indexPath.row
        cell.sendButton.tag = indexPath.row
        cell.likeButton.tag = indexPath.row
        if feelList[indexPath.row].memberLike ?? false {
            cell.likeButton.setImage(systemName: "heart.fill", pointSize: 25)
            if app.languageCode == "ko" {
                cell.likeButton.accessibilityLabel = "\(intToString(indexPath.row + 1))번" + feelList[indexPath.row].title + "의 좋아요를 취소하는"
            }
        } else {
            cell.likeButton.setImage(systemName: "heart", pointSize: 25)
            if app.languageCode == "ko" {
                cell.likeButton.accessibilityLabel = "\(intToString(indexPath.row + 1))번" + feelList[indexPath.row].title + "의 좋아요를 누르는"
            }
        }
        cell.sendButton.tag = indexPath.row
        cell.cellDelegate = self
        cell.setupLayout()
        return cell
    }
}

private extension StoryDetailMiddleView {
    func setupLayout() {
        setupShadow()
        
        [
            tableHeaderView,
            placeHolderView,
            feelShareButton
        ].forEach { addSubview($0) }
        
        tableHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        [titleLabel, feelCountLabel].forEach {
            tableHeaderView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        feelCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        placeHolderView.snp.makeConstraints {
            $0.top.equalTo(tableHeaderView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        [
            placeHolderLabel,
            imageView,
            tableView,
        ].forEach {
            placeHolderView.addSubview($0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        placeHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(placeHolderLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(imageView.snp.width)
        }
        
        feelShareButton.snp.makeConstraints {
            $0.top.equalTo(placeHolderView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(intervalSize)
            $0.height.equalTo(50)
        }
        
    }
    
    @objc private func reloadFeelList(_ notification: Notification) {
        guard let notiFeelList = notification.object as? [FeelListData] else { return }
        feelList = notiFeelList
        tableView.reloadData()
        var tempStr = titleLabel.text ?? ""
        if tempStr != "" {
            tempStr.removeFirst()
        }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.languageCode == "ko" {
            titleLabel.accessibilityLabel = tempStr + "의 이야기 느낌 \(feelList.count)개"
        }
        feelCountLabel.text = "[ \(feelList.count) ]"
        feelCountLabel.isAccessibilityElement = false
    }
}

extension StoryDetailMiddleView: FeelStoreTableViewDelegate {
    func feelListenButtonTapped(_ feel: FeelListData) {
        LoadingIndicator.showLoading(className: "StoryDetailMiddleView", function: "StoryDetailMiddleView")
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
    
    func feelLikeButtonTapped(_ tag: Int) {
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
            var request = URLRequest(url: URL(string: feelLikeURL)!)
            request.httpMethod = (feelList[tag].memberLike ?? false) ? "DELETE" : "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            let params = [
                "likeMemberIdx": memberIdx,
                "regMemberIdx": feelList[tag].regMemberIdx ?? 0,
                "stid" : feelList[tag].stid,
                "stlid" :feelList[tag].stlid,
                "title" : feelList[tag].title
            ] as [String : Any]
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                print("http Body Error")
                #endif
            }
            LoadingIndicator.showLoading(className: "StoryDetailMiddleView", function: "feelLikeButtonTapped")
            AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
                guard let self = self else { return }
                guard let topViewController = keyWindow?.visibleViewController else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 201 {
                        self.feelList[tag].memberLike = !(self.feelList[tag].memberLike ?? false)
                        topViewController.showToast(message: "'좋아요'를 눌렀습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        DispatchQueue.main.async {
                            topViewController.showToVoice(type: .announcement, text: "좋아요를 눌렀습니다.")
                        }
                        self.tableView.reloadData()
                    } else if data.status == 204{
                        self.feelList[tag].memberLike = !(self.feelList[tag].memberLike ?? false)
                        topViewController.showToast(message: "'좋아요'를 취소하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        DispatchQueue.main.async {
                            topViewController.showToVoice(type: .announcement, text: "좋아요를 취소하였습니다.")
                        }
                        self.tableView.reloadData()
                    } else {
                        print(data.status, data.message)
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
    
    func feelListReportTapped(_ feel: FeelListData) {
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
            feelReportViewController.hero.isEnabled = true
            feelReportViewController.hero.modalAnimationType = .fade
            feelReportViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
            topViewController.present(feelReportViewController, animated: true)
        }
    }
}
