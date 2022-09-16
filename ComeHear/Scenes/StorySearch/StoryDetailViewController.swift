//
//  StoryDetailViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import UIKit
import Kingfisher
import AVFoundation
import Alamofire
import Hero

class StoryDetailViewController: UIViewController {
    // MARK: - 변수, 상수
    let storyDetail: StoryDetail
    var feelList: [FeelListData] = []
    
    // MARK: - 이야기상세 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = personalColor
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let storyDetailTopView = StoryDetailTopView(frame: .zero)
    private let storyDetailMiddleView = StoryDetailMiddleView(frame: .zero)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = intervalSize
        
        storyDetailTopView.scriptView.text = storyDetail.script
        if let url = storyDetail.audioUrl, url != "" {
            storyDetailTopView.actorSound.addTarget(self, action: #selector(listenActorSound), for: .touchUpInside)
        } else {
            storyDetailTopView.actorSound.isHidden = true
        }
        storyDetailTopView.defaultSound.addTarget(self, action: #selector(listenDefaultSound), for: .touchUpInside)
        
        if let url = storyDetail.imageUrl {
            if url == "" {
                storyDetailTopView.imageView.image = landScapeImage
            } else {
                storyDetailTopView.imageView.setImage(with: url, placeholder: landScapeImage, cornerRadius: 0)
            }
        } else {
            storyDetailTopView.imageView.image = landScapeImage
        }
        
        storyDetailMiddleView.titleLabel.text = "# " + (storyDetail.audioTitle ?? "이야기의".localized())
        storyDetailMiddleView.feelShareButton.addTarget(self, action: #selector(tapFeelShare), for: .touchUpInside)
        
        [
            storyDetailTopView,
            storyDetailMiddleView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    // MARK: - LifeCycle_생명주기
    init(storyDetail: StoryDetail) {
        self.storyDetail = storyDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(requestFeelList), name: NSNotification.Name("reportAfterReload"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestFeelList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice2(type: .screenChanged, text:"이야기상세화면".localized(with: storyDetail.title))
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        app.preventTap = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reportAfterReload"), object: nil)
    }
}

// MARK: - Extension
extension StoryDetailViewController {
    
    
    // MARK: - 함수_기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = storyDetail.title
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
        
        mainContentView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(subContentView)
        
        subContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        subContentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
    }
    
    @objc private func requestFeelList() {
        var urlString = feelListURL + "?langCode=ko&pageNo=1&pageSize=20000&stid=\(storyDetail.stid)&stlid=\(storyDetail.stlid)"
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, let memberIdx = app.userMemberIdx {
            urlString += "&likeMemberIdx=\(memberIdx)"
        }
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: FeelListModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.feelList = data.feelList
                    if UIAccessibility.isVoiceOverRunning {
                        self.scrollView.scroll(to: .bottom)
                        self.scrollView.isScrollEnabled = false
                    }
                    NotificationCenter.default.post(name: Notification.Name("reloadFeelList"), object: data.feelList)
                case .failure(let error):
                    self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
                    print(error)
#endif
                }
            }
    }
    
    private func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        let recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission {
        case .undetermined: // 아직 녹음 권한 요청이 되지 않음, 사용자에게 권한 요청
            recordingSession.requestRecordPermission({ allowed in
                completion(allowed)
            })
        case .denied: // 사용자가 녹음 권한 거부, 사용자가 직접 설정 화면에서 권한 허용을 하게끔 유도
            self.showSettingAlert(title: "녹음권한 요청", message: "녹음을 위해 권한을 허용해주세요.")
            completion(false)
        case .granted: // 사용자가 녹음 권한 허용
            completion(true)
        @unknown default:
            fatalError("[ERROR] Record Permission is Unknown Default.")
        }
    }
    
    @objc func listenActorSound() {
        guard let url = storyDetail.audioUrl else { return }
        LoadingIndicator.showLoading(className: self.className, function: "listenActorSound")
        let playViewController = FeelPlayViewController()
        playViewController.feelTitleView.text = "제목 - 기본이야기".localized()
        playViewController.writer.text = "출연 : 성우 님".localized()
        playViewController.defaultImageUrl = storyDetail.imageUrl ?? ""
        playViewController.audioURL = url
        DispatchQueue.background(
            background: {
                playViewController.setupAVAudioPlayer()
            },
            completion: {
                playViewController.accessibilityElementsHidden = true
                playViewController.sendMessageButton.isEnabled = false
                playViewController.sendMessageButton.isAccessibilityElement = false
                playViewController.sendMessageButton.alpha = 0.5
                playViewController.hero.isEnabled = true
                playViewController.hero.modalAnimationType = .fade
                playViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                self.present(playViewController, animated: true, completion: nil)
            }
        )
    }
    
    @objc func listenDefaultSound() {
        DispatchQueue.main.async {
            LoadingIndicator.showLoading(className: self.className, function: "listenDefaultSound")
        }
        let playViewController = FeelPlayViewController()
        playViewController.feelTitleView.text = "제목 - 기본이야기".localized()
        playViewController.writer.text = "출연 : 시리 님".localized()
        playViewController.script = storyDetail.script ?? ""
        playViewController.defaultImageUrl = storyDetail.imageUrl ?? ""
        DispatchQueue.background(
            background: {
                playViewController.setupAVAudioPlayer()
            },
            completion: {
                playViewController.accessibilityElementsHidden = true
                playViewController.sendMessageButton.isEnabled = false
                playViewController.sendMessageButton.isAccessibilityElement = false
                playViewController.sendMessageButton.alpha = 0.5
                playViewController.hero.isEnabled = true
                playViewController.hero.modalAnimationType = .fade
                playViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                self.present(playViewController, animated: true, completion: nil)
            }
        )
    }
    
    @objc private func tapFeelShare() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            showTwoActionAlert("로그인이 필요합니다.\n로그인페이지로 이동하시겠습니까?", "로그인", loginAction)
        } else {
            guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let userMemberIdx = app.userMemberIdx else { return }
            let urlString = feelUploadURL + "?regMemberIdx=\(userMemberIdx)&stid=\(storyDetail.stid)&stlid=\(storyDetail.stlid)"
            
            AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                .responseDecodable(of: BasicResponseMsgModel.self) { [weak self] response in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        if data.status == 200 {
                            self.moveFeelShare()
                        } else {
                            if let dataData = data.data {
                                let msg = dataData.message
                                self.showConfirmAlert2(msg, "알림")
                            }
                        }
                    case .failure(let error):
                        self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
                        print("error", error)
#endif
                    }
                }
        }
    }
    
    private func moveFeelShare() {
        LoadingIndicator.showLoading(className: self.className, function: "moveFeelShare")
        requestMicrophoneAccess { [weak self] allowed in
            if allowed {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let feelShareViewController = FeelRecordViewController()
                    feelShareViewController.stid = self.storyDetail.stid
                    feelShareViewController.stlid = self.storyDetail.stlid
                    feelShareViewController.storyDetail = self.storyDetail
                    feelShareViewController.shareTitle.setTitle("#\(self.storyDetail.title)  ", for: .normal)
                    feelShareViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                    feelShareViewController.hero.isEnabled = true
                    feelShareViewController.hero.modalAnimationType = .zoom
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.present(feelShareViewController, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
            }
        }
    }
}
