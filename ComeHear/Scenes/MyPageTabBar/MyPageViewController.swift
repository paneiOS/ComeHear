//
//  MyPageViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/17.
//

import UIKit
import Alamofire
import WebKit

class MyPageViewController: UIViewController {
    
    //MARK: - 변수, 상수
    private let constantSize = ConstantSize()
    private var webView: WKWebView!
    
    //MARK: - 마이페이지 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    //MARK: - 마이페이지_프로필 UI
    private lazy var myProfileView: UIView = {
        let view = UIView()
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setupShadow()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSignUp))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = constantSize.intervalSize
        
        [
            myInfoView,
            myShareFeelView,
            myFavoriteView,
            myLikeView,
            noticeView,
            languageView,
            termsView,
            privacyView,
            copyrightView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var profileLabelView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var profileLoginTopLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var profileLoginBottomLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var profileLogoutTopLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var profileLogoutBottomButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입하러가기".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.setUnderline()
        button.addTarget(self, action: #selector(tapSignUp), for: .touchUpInside)
        return button
    }()
    
    //MARK: - 마이페이지_로그인 UI
    lazy var loginView: UIView = {
        let view = UIView()
        view.setupSubViewFooter(color: ContentColor.firstCellColor.getColor())
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLogin))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "로그인하기".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var loginLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "로그인".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "lock.open", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - 마이페이지_로그아웃 UI
    lazy var logoutView: UIView = {
        let view = UIView()
        view.setupSubViewFooter()
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLogout))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "로그아웃하기".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var logoutLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "로그아웃".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "lock", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)
        return button
    }()
    
    //MARK: - 마이페이지_회원 UI
    private lazy var myInfoContentView: UIView = {
        let view = UIView()
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setupShadow()
        return view
    }()
    
    private lazy var myInfoView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapMyInfo))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "내 정보 관리".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var myInfoLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "내 정보 관리".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "person.text.rectangle", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapMyInfo), for: .touchUpInside)
        return button
    }()
    
    private lazy var myInfoRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapMyInfo), for: .touchUpInside)
        return button
    }()
    
    private lazy var myShareFeelView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapShareFeel))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "내가 공유한 느낌".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var myShareFeelLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "내가 공유한 느낌".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "headphones", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapShareFeel), for: .touchUpInside)
        return button
    }()
    
    private lazy var myShareFeelRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapShareFeel), for: .touchUpInside)
        return button
    }()
    
    private lazy var myFavoriteView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapFavorite))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "나의 즐겨찾기".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var myFavoriteLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "나의 즐겨찾기".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "star", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
        return button
    }()
    
    private lazy var myFavoriteRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
        return button
    }()
    
    private lazy var myLikeView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLike))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "내가 좋아요 한 느낌".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var myLikeLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "내가 좋아요 한 느낌".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "heart", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var myLikeRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var noticeView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapNotice))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "공지사항".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var noticeLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "공지사항".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "info.circle", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapNotice), for: .touchUpInside)
        return button
    }()
    
    private lazy var noticeRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapNotice), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTerms))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "이용약관".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var termsLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "이용약관".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "list.bullet.rectangle.portrait", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapTerms), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapTerms), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "개인정보 처리방침".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var privacyLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "개인정보 처리방침".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "lock.doc", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapPrivacy), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapPrivacy), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyrightView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCopyright))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "저작물표시 안내".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var copyrightLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "저작물표시 안내".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "lock.icloud", pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tapCopyright), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyrightRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(showChangeLanguageAlert), for: .touchUpInside)
        return button
    }()
    
    private lazy var languageView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showChangeLanguageAlert))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "현재 언어는 한국어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var languageLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + "다른 언어 설정".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "globe.asia.australia".localized(), pointSize: 20)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(showChangeLanguageAlert), for: .touchUpInside)
        return button
    }()
    
    private lazy var languageRightButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "chevron.right", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapCopyright), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "ko" {
            button.setTitle("🇰🇷", for: .normal)
            button.accessibilityLabel = "현재 언어는 한국어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
        } else if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "en" {
            button.setTitle("🇺🇸", for: .normal)
            button.accessibilityLabel = "현재 언어는 영어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
        } else {
            button.setTitle("🇯🇵", for: .normal)
            button.accessibilityLabel = "현재 언어는 일본어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
        }
        
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        button.addTarget(self, action: #selector(showChangeLanguageAlert), for: .touchUpInside)
        return button
    }()
    
//    private lazy var rightButton: UIBarButtonItem = {
//        if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "ko" {
//            let button = UIBarButtonItem(title: "🇰🇷", style: .plain, target: self, action: #selector(showChangeLanguageAlert))
//            button.accessibilityLabel = "현재 언어는 한국어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
//            return button
//        } else if let app = UIApplication.shared.delegate as? AppDelegate, app.languageCode == "en" {
//            let button = UIBarButtonItem(title: "🇺🇸", style: .plain, target: self, action: #selector(showChangeLanguageAlert))
//            button.accessibilityLabel = "현재 언어는 영어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
//            return button
//        } else {
//            let button = UIBarButtonItem(title: "🇯🇵", style: .plain, target: self, action: #selector(showChangeLanguageAlert))
//            button.accessibilityLabel = "현재 언어는 일본어입니다. 다른 언어로 변경을 원하시면 눌러주세요.".localized()
//            return button
//        }
//    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkUserLogin()
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            showToVoice(type: .screenChanged, text: "현재화면은 마이페이지 화면입니다. 현재 로그인 상태입니다.")
        } else {
            showToVoice(type: .screenChanged, text: "현재화면은 마이페이지 화면입니다. 현재 비로그인 상태입니다.")
        }
    }
}

// MARK: - Extension
extension MyPageViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "탭바5".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
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
        
        //MARK: - 로그인 UI_SETUP
        [
            myProfileView,
            myInfoContentView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        //MARK: - 마이페이지_프로필 UI_SETUP
        myProfileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            profileLabelView, loginView, logoutView
        ].forEach {
            myProfileView.addSubview($0)
        }
        
        profileLabelView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            profileLoginTopLabel,
            profileLoginBottomLabel,
            profileLogoutTopLabel,
            profileLogoutBottomButton
        ].forEach {
            profileLabelView.addSubview($0)
        }
        
        profileLoginTopLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        profileLoginBottomLabel.snp.makeConstraints {
            $0.top.equalTo(profileLoginTopLabel.snp.bottom).offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        profileLogoutTopLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        profileLogoutBottomButton.snp.makeConstraints {
            $0.top.equalTo(profileLogoutTopLabel.snp.bottom).offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        //MARK: - 마이페이지_로그인 UI_SETUP
        loginView.snp.makeConstraints {
            $0.top.equalTo(profileLabelView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40 + constantSize.intervalSize/2)
        }
        
        [loginLeftButton, loginRightButton].forEach {
            loginView.addSubview($0)
        }
        
        loginLeftButton.snp.makeConstraints {
            $0.leading.equalTo(loginView.snp.leading).offset(constantSize.intervalSize)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        loginRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_로그아웃 UI_SETUP
        logoutView.snp.makeConstraints {
            $0.top.equalTo(profileLabelView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40 + constantSize.intervalSize/2)
        }
        
        [logoutLeftButton, logoutRightButton].forEach {
            logoutView.addSubview($0)
        }
        
        logoutLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        logoutRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지 UI_SETUP
        myInfoContentView.snp.makeConstraints {
            $0.top.equalTo(myProfileView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(constantSize.intervalSize)
        }
        
        myInfoContentView.addSubview(contentScrollView)
        
        contentScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
        }
        
        contentScrollView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        //MARK: - 마이페이지_내정보관리 UI_SETUP
        myInfoView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [myInfoLeftButton, myInfoRightButton].forEach {
            myInfoView.addSubview($0)
        }
        
        myInfoLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        myInfoRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        //MARK: - 마이페이지_내가공유한느낌 UI_SETUP
        myShareFeelView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [myShareFeelLeftButton, myShareFeelRightButton].forEach {
            myShareFeelView.addSubview($0)
        }
        
        myShareFeelLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        myShareFeelRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_나의즐겨찾기 UI_SETUP
        myFavoriteView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [myFavoriteLeftButton, myFavoriteRightButton].forEach {
            myFavoriteView.addSubview($0)
        }
        
        myFavoriteLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        myFavoriteRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_좋아요느낌 UI_SETUP
        myLikeView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [myLikeLeftButton, myLikeRightButton].forEach {
            myLikeView.addSubview($0)
        }
        
        myLikeLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        myLikeRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_공지사항 UI_SETUP
        noticeView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [noticeLeftButton, noticeRightButton].forEach {
            noticeView.addSubview($0)
        }
        
        noticeLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        noticeRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_다른언어설정 UI_SETUP
        languageView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [languageLeftButton, languageRightButton].forEach {
            languageView.addSubview($0)
        }
        
        languageLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        languageRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_이용약관 UI_SETUP
        termsView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [termsLeftButton, termsRightButton].forEach {
            termsView.addSubview($0)
        }
        
        termsLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        termsRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_개인정보처리방침 UI_SETUP
        privacyView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [privacyLeftButton, privacyRightButton].forEach {
            privacyView.addSubview($0)
        }
        
        privacyLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        privacyRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        //MARK: - 마이페이지_저작물표시안내 UI_SETUP
        copyrightView.snp.makeConstraints {
            $0.width.equalTo(constantSize.frameSizeWidth - constantSize.intervalSize * 2)
            $0.height.equalTo(40)
        }
        
        [copyrightLeftButton, copyrightRightButton].forEach {
            copyrightView.addSubview($0)
        }
        
        copyrightLeftButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
        }
        
        copyrightRightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
    }
    
    // MARK: - 함수
    private func checkUserLogin() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            loginView.isHidden = true
            logoutView.isHidden = false
            profileLoginTopLabel.isHidden = false
            profileLoginBottomLabel.isHidden = false
            profileLogoutTopLabel.isHidden = true
            profileLogoutBottomButton.isHidden = true
            myProfileView.setupShadow(color: ContentColor.firstCellColor.getColor())
            profileLoginTopLabel.backgroundColor = ContentColor.firstCellColor.getColor()
            profileLoginBottomLabel.backgroundColor = ContentColor.firstCellColor.getColor()
            if let nickname = app.userNickName {
                profileLoginTopLabel.text = "로그인알림".localized(with: nickname)
                profileLoginBottomLabel.text = "Come Hear와 함께 즐거운 여행 되세요.".localized()
                profileLoginTopLabel.accessibilityLabel = "현재 로그인 상태입니다.".localized()
            }
            
        } else {
            loginView.isHidden = false
            logoutView.isHidden = true
            profileLoginTopLabel.isHidden = true
            profileLoginBottomLabel.isHidden = true
            profileLogoutTopLabel.isHidden = false
            profileLogoutBottomButton.isHidden = false
            myProfileView.setupShadow(color: .white)
            profileLoginTopLabel.backgroundColor = .white
            profileLoginBottomLabel.backgroundColor = .white
            profileLogoutTopLabel.text = "아직 Come Hear 회원이 아니신가요?".localized()
            profileLogoutTopLabel.accessibilityLabel = "현재 비로그인 상태입니다.".localized()
        }
    }
    
    // MARK: - 함수_objc
    @objc func tapSignUp() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState != .login {
            let signUpViewController = SignUpViewController()
            self.navigationController?.pushViewController(signUpViewController, animated: true)
        }
    }
    
    @objc private func tapMyInfo() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let myInfoViewController = MyInfoViewController()
            self.navigationController?.pushViewController(myInfoViewController, animated: true)
        }
    }
    
    @objc private func tapShareFeel() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let myFeelRegViewController = MyFeelRegTableViewController()
            guard let topViewController = keyWindow?.visibleViewController else { return }
            topViewController.navigationController?.pushViewController(myFeelRegViewController, animated: true)
        }
    }
    
    @objc private func tapFavorite() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let myFavoriteViewController = MyFavoriteViewController()
            self.navigationController?.pushViewController(myFavoriteViewController, animated: true)
        }
    }
    
    @objc private func tapLike() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                let loginViewContrller = LoginViewController()
                guard let topViewController = keyWindow?.visibleViewController else { return }
                topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
            }
            showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            let myFeelLikeViewController = MyFeelLikeTableViewController()
            guard let topViewController = keyWindow?.visibleViewController else { return }
            topViewController.navigationController?.pushViewController(myFeelLikeViewController, animated: true)
        }
    }
    
    @objc private func tapNotice() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        let url = URLString.SubDomain.noticeURL.getURL() + "&langCode=\(languageCode)"
        AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: NoticeModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    let viewController = NoticeViewController(noticeList: data.noticeList)
                    self.navigationController?.pushViewController(viewController, animated: true)
                case .failure(_):
                    self.showCloseAlert(type: .unknownError)
                }
            }
    }
    
    @objc private func tapTerms() {
        let popupTextViewController = PopupTextViewController(type: .comeHearTerms)
        popupTextViewController.hero.isEnabled = true
        popupTextViewController.hero.modalAnimationType = .fade
        popupTextViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        popupTextViewController.contentFooterView.isHidden = true
        self.present(popupTextViewController, animated: true)
    }
    
    @objc private func tapPrivacy() {
        let popupTextViewController = PopupTextViewController(type: .comeHearPrivacy)
        popupTextViewController.hero.isEnabled = true
        popupTextViewController.hero.modalAnimationType = .fade
        popupTextViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        popupTextViewController.contentFooterView.isHidden = true
        self.present(popupTextViewController, animated: true)
    }
    
    @objc private func tapCopyright() {
        let webViewController = WebViewController()
        if let topViewController = keyWindow?.visibleViewController {
            topViewController.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    @objc private func tapLogin() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .logout {
            let loginViewContrller = LoginViewController()
            self.navigationController?.pushViewController(loginViewContrller, animated: true)
        }
    }
    
    @objc private func tapLogout() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            let logoutAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { [weak self] _ in
                guard let self = self else { return }
                app.userLogin = false
                self.checkUserLogin()
                self.showToast(message: "로그아웃 되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                self.showToVoice(type: .announcement, text: "로그아웃 되었습니다.")
            }
            showTwoButtonAlert(type: .requestLogout, logoutAction)
        }
    }
    
    @objc private func showChangeLanguageAlert() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let alert = UIAlertController(title: "다국어 설정".localized(), message: "다국어 설명".localized(), preferredStyle: .actionSheet)
        let korAction = UIAlertAction(title: "Korean", style: .default) { _ in
            let restart = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                UserDefaults.standard.set(["ko"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                app.languageCode = "ko"
                exit(0)
            }
            self.showTwoButtonAlert(type: .requestChangeLanguage, restart)
        }
        let engAction = UIAlertAction(title: "English", style: .default) { _ in
            let restart = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                app.languageCode = "en"
                exit(0)
            }
            self.showTwoButtonAlert(type: .requestChangeLanguage, restart)
        }
        
        let jpAction = UIAlertAction(title: "Japanese", style: .default) { _ in
            let restart = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                UserDefaults.standard.set(["ja"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                app.languageCode = "ja"
                exit(0)
            }
            self.showTwoButtonAlert(type: .requestChangeLanguage, restart)
        }
        let cancelAction = UIAlertAction(title: "취소".localized(), style: .cancel, handler: nil)
        alert.addAction(korAction)
        alert.addAction(engAction)
        alert.addAction(jpAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
