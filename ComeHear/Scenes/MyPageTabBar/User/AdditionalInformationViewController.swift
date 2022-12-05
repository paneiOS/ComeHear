//
//  AdditionalInformationViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/16.
//

import UIKit
import Alamofire

class AdditionalInformationViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    var token: String = ""
    var type: String = ""
    var fullName: String?
    
    private var allAgreeBool = false {
        didSet {
            if allAgreeBool {
                allAgreeButton.setImage(systemName: "checkmark.square", pointSize: 20)
                inputButton.alpha = 1
                inputButton.isEnabled = true
                allAgreeButton.accessibilityLabel = "이용약관, 개인정보처리방침 모두 동의취소하기".localized()
                inputButton.accessibilityElementsHidden = false
            } else {
                allAgreeButton.setImage(systemName: "square", pointSize: 20)
                inputButton.alpha = 0.3
                inputButton.isEnabled = false
                allAgreeButton.accessibilityLabel = "이용약관, 개인정보처리방침 모두 동의하기".localized()
                inputButton.accessibilityElementsHidden = true
            }
        }
    }
    private var termsAgreeBool = false {
        didSet {
            if termsAgreeBool {
                termsAgreeButton.setImage(systemName: "checkmark.square", pointSize: 20)
                termsAgreeButton.accessibilityLabel = "이용약관 동의취소하기".localized()
            } else {
                termsAgreeButton.setImage(systemName: "square", pointSize: 20)
                termsAgreeButton.accessibilityLabel = "이용약관 동의하기".localized()
            }
        }
    }
    private var privacyAgreeBool = false {
        didSet {
            if privacyAgreeBool {
                privacyAgreeButton.setImage(systemName: "checkmark.square", pointSize: 20)
                privacyAgreeButton.accessibilityLabel = "개인정보처리방침 동의취소하기".localized()
            } else {
                privacyAgreeButton.setImage(systemName: "square", pointSize: 20)
                privacyAgreeButton.accessibilityLabel = "개인정보처리방침 동의하기".localized()
            }
        }
    }
    
    // MARK: - 회원가입_약관 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private lazy var agreePlaceHolderView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var agreePlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.text = "회원가입을 위해 약관에 동의해주세요.".localized()
        return label
    }()
    
    private lazy var agreeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0.0
        
        [
            termsView,
            privacyView,
            allAgreeView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var termsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var termsLabel: UIButton = {
        let button = UIButton()
        button.setTitle("이용약관 동의".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.setUnderline()
        button.addTarget(self, action: #selector(tapTermsLabel), for: .touchUpInside)
        button.accessibilityLabel = "이용약관 내용읽기".localized()
        return button
    }()
    
    private lazy var termsAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "square", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapTermsAgree), for: .touchUpInside)
        button.accessibilityLabel = "이용약관 동의하기".localized()
        return button
    }()
    
    private lazy var privacyView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var privacyLabel: UIButton = {
        let button = UIButton()
        button.setTitle("개인정보처리방침 동의".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.setUnderline()
        button.addTarget(self, action: #selector(tapPrivacyLabel), for: .touchUpInside)
        button.accessibilityLabel = "개인정보처리방침 내용읽기".localized()
        return button
    }()
    
    private lazy var privacyAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "square", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapPrivacyAgree), for: .touchUpInside)
        button.accessibilityLabel = "개인정보처리방침 동의하기".localized()
        return button
    }()
    
    private lazy var allAgreeView: UIView = {
        let view = UIView()
        view.setupSubViewFooter(color: ContentColor.personalColor.getColor())
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAllAgree))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    private lazy var allAgreeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "전체 동의".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var allAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "square", pointSize: 20)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapAllAgree), for: .touchUpInside)
        button.accessibilityLabel = "이용약관, 개인정보처리방침 모두 동의하기".localized()
        return button
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.moreLightGrayColor.getColor()
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var popupTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "JSArirangHON-Regular", size: 24)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "추가정보 입력".localized()
        return label
    }()
    
    private lazy var nickNameView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var nickNamePlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.text = "회원가입을 위해 별명을 추가입력해주세요.".localized()
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var nickNameTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "별명을 입력해주세요.".localized()
        return textField
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = constantSize.intervalSize
        
        [
            inputButton,
            cancelButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var inputButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "확인".localized(), fontSize: 16)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(inputInfo), for: .touchUpInside)
        button.isEnabled = false
        button.isAccessibilityElement = false
        button.alpha = 0.3
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소".localized(), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setKeyboardHalfObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 추가정보 입력 화면입니다. 서비스 이용을 위해 이용약관 동의 및 별명을 추가입력해주세요.")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupLayout() {
        [mainContentView, popupView].forEach {
            view.addSubview($0)
        }
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        popupView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.centerY.equalToSuperview()
        }
        
        [
            popupTitleLabel,
            agreePlaceHolderView,
            nickNameView,
            buttonStackView
        ].forEach {
            popupView.addSubview($0)
        }
        
        termsView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        privacyView.snp.makeConstraints {
            $0.height.equalTo(30 + constantSize.intervalSize)
        }
        
        allAgreeView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        popupTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        agreePlaceHolderView.snp.makeConstraints {
            $0.top.equalTo(popupTitleLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            agreePlaceHolderLabel, agreeStackView
        ].forEach {
            agreePlaceHolderView.addSubview($0)
        }
        
        agreePlaceHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        agreeStackView.snp.makeConstraints {
            $0.top.equalTo(agreePlaceHolderLabel.snp.bottom).offset(constantSize.intervalSize/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [allAgreeLabel, allAgreeButton].forEach {
            allAgreeView.addSubview($0)
        }
        
        allAgreeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        allAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        [termsLabel, termsAgreeButton].forEach {
            termsView.addSubview($0)
        }
        
        termsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        termsAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        [privacyLabel, privacyAgreeButton].forEach {
            privacyView.addSubview($0)
        }
        
        privacyLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
        }
        
        privacyAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
        }
        
        nickNameView.snp.makeConstraints {
            $0.top.equalTo(agreePlaceHolderView.snp.bottom).offset(constantSize.intervalSize * 2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            nickNamePlaceHolderLabel,
            nickNameTextFieldView
        ].forEach {
            nickNameView.addSubview($0)
        }
        
        nickNamePlaceHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        nickNameTextFieldView.snp.makeConstraints {
            $0.top.equalTo(nickNamePlaceHolderLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        nickNameTextFieldView.addSubview(nickNameTextField)
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameView.snp.bottom).offset(constantSize.intervalSize * 2)
            $0.leading.equalTo(popupView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(popupView.snp.trailing).inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
    }
    
    // MARK: - 함수_objc
    @objc private func inputInfo() {
        guard let nickname = nickNameTextField.text, nickname != "" else { return self.showConfirmAlert(type: .insertNickname)}
        guard let nickname = nickNameTextField.text, !nickname.contains(" ") else { return self.showConfirmAlert(type: .nicknameNotBlank) }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.languageCode == "ko" {
            guard nickNameTextField.text?.count ?? 0 <= 10 else { return showConfirmAlert(type: .limitNickname) }
        }
        guard let url = URL(string: URLString.SubDomain.socialSignupURL.getURL()) else { return }
        var request = URLRequest(url: url)
        let params = ["nickname": nickname, "token": token, "type": type, "username": fullName] as Dictionary
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
                    print("http Body Error")
#endif
        }
        
        LoadingIndicator.showLoading(className: self.className, function: "inputInfo")
        AF.request(request).responseDecodable(of: Login.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    guard let userData = data.data else { return }
                    UserDefaults.standard.set(true, forKey: "user_login")
                    UserDefaults.standard.set(self.type, forKey: "user_loginType")
                    UserDefaults.standard.set(userData.memberIdx, forKey: "user_memberIdx")
                    UserDefaults.standard.set(userData.token, forKey: "user_token")
                    UserDefaults.standard.set(userData.nickName, forKey: "user_nickName")
                    UserDefaults.standard.set(userData.email, forKey: "user_emil")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        LoadingIndicator.hideLoading()
                        if let app = UIApplication.shared.delegate as? AppDelegate {
                            app.userLogin = true
                        }
                        let okAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default){ _ in
                            self.dismiss(animated: true)
                        }
                        self.showOneButtonAlert("로그인알림".localized(with: userData.nickName), "알림".localized(), okAction)
                    }
                } else if data.status == 406 {
                    self.showConfirmAlert(type: .nicknameError)
                } else if data.status == 409 {
                    self.showConfirmAlert(type: .duplicateNickname)
                }
            case .failure(_):
                self.showCloseAlert(type: .unknownError)
            }

            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    @objc private func tapCancel() {
        if type == "APPLE" {
            guard let url = URL(string: URLString.SubDomain.appleSecessionURL.getURL()) else { return }
            var request = URLRequest(url: url)
            let params = ["token": token] as Dictionary
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                    print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "tapCancel")
            AF.request(request).responseDecodable(of: Login.self) { [weak self] (response) in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    LoadingIndicator.hideLoading()
                    self.showToast(message: "회원가입을 취소하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                    self.showToVoice(type: .announcement, text: "회원가입을 취소하였습니다.")
                    self.dismiss(animated: true)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showToast(message: "회원가입을 취소하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                self.showToVoice(type: .announcement, text: "회원가입을 취소하였습니다.")
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func tapAllAgree() {
        allAgreeBool = !allAgreeBool
        termsAgreeBool = allAgreeBool
        privacyAgreeBool = allAgreeBool
        if allAgreeBool {
            showToVoice(type: .announcement, text: "이용약관, 개인정보처리방침 모두 동의하셨습니다.")
        } else {
            showToVoice(type: .announcement, text: "이용약관, 개인정보처리방침 모두 동의를 취소하셨습니다.")
        }
    }
    
    @objc private func tapTermsAgree() {
        termsAgreeBool = !termsAgreeBool
        if termsAgreeBool && privacyAgreeBool {
            allAgreeBool = true
            privacyAgreeBool = true
        } else if !termsAgreeBool || !privacyAgreeBool {
            allAgreeBool = false
        }
        if termsAgreeBool {
            showToVoice(type: .announcement, text: "이용약관에 동의하셨습니다.")
        } else {
            showToVoice(type: .announcement, text: "이용약관에 동의를 취소하셨습니다.")
        }
    }
    
    @objc private func tapPrivacyAgree() {
        privacyAgreeBool = !privacyAgreeBool
        if termsAgreeBool && privacyAgreeBool {
            allAgreeBool = true
            termsAgreeBool = true
        } else if !termsAgreeBool || !privacyAgreeBool {
            allAgreeBool = false
        }
        if privacyAgreeBool {
            showToVoice(type: .announcement, text: "개인정보처리방침에 동의하셨습니다.")
        } else {
            showToVoice(type: .announcement, text: "개인정보처리방침에 동의를 취소하셨습니다.")
        }
    }
    
    @objc private func tapTermsLabel() {
        let popupTextViewController = PopupTextViewController(type: .comeHearTerms)
        popupTextViewController.delegate = self
        popupTextViewController.hero.isEnabled = true
        popupTextViewController.hero.modalAnimationType = .fade
        popupTextViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        self.present(popupTextViewController, animated: true)
    }
    
    @objc private func tapPrivacyLabel() {
        let popupTextViewController = PopupTextViewController(type: .comeHearPrivacy)
        popupTextViewController.delegate = self
        popupTextViewController.hero.isEnabled = true
        popupTextViewController.hero.modalAnimationType = .fade
        popupTextViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        if let topViewController = keyWindow?.visibleViewController {
            topViewController.present(popupTextViewController, animated: false, completion: nil)
        }
    }
    
}

extension AdditionalInformationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nickNameTextField {
        nickNameTextField.resignFirstResponder()
        inputInfo()
    }
    return true
  }
}

// MARK: - AgreeData Delegate
extension AdditionalInformationViewController: SendAgreeDataDelegate {
    func recieveTermsAgreeData() {
        if !termsAgreeBool {
            tapTermsAgree()
        }
    }
    
    func recievePrivacyAgreeData() {
        if !privacyAgreeBool {
            tapPrivacyAgree()
        }
    }
}
