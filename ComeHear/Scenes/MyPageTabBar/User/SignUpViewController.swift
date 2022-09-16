//
//  SignUpViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/11.
//

import UIKit
import Alamofire

protocol SendDataDelegate {
    func recieveData(response : String)
}

final class SignUpViewController: UIViewController {
    // MARK: - 변수, 상수
    private var uuid: String?
    private var codeBool = false
    private var emailBool = false
    private var timer: DispatchSourceTimer?
    private var currentSeconds = 300
    
    var delegate: SendDataDelegate?
    
    private var allAgreeBool = false {
        didSet {
            if allAgreeBool {
                allAgreeButton.setImage(systemName: "checkmark.square", pointSize: 20)
                infoView.alpha = 1
                infoCoverView.isHidden = true
                allAgreeButton.accessibilityLabel = "이용약관, 개인정보처리방침 모두 동의취소하기".localized()
                infoView.accessibilityElementsHidden = false
            } else {
                allAgreeButton.setImage(systemName: "square", pointSize: 20)
                infoView.alpha = 0.3
                infoCoverView.isHidden = false
                allAgreeButton.accessibilityLabel = "이용약관, 개인정보처리방침 모두 동의하기".localized()
                infoView.accessibilityElementsHidden = true
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
    
    // MARK: - 회원가입 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        return view
    }()
    
    // MARK: - 회원가입_약관 UI
    private lazy var agreePlaceHolderView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var agreePlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "회원가입을 위해 약관에 동의해주세요.".localized()
        label.backgroundColor = .clear
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
        view.setupSubViewFooter(color: personalColor)
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
    
    // MARK: - 회원가입_정보기입 UI
    private lazy var infoView: UIView = {
        let view = UIView()
        view.alpha = 0.3
        view.accessibilityElementsHidden = true
        return view
    }()
    
    private lazy var infoPlaceHolderView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var infoPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "회원정보를 기입해주세요.".localized()
        label.backgroundColor = .clear
        if let app = UIApplication.shared.delegate as? AppDelegate , app.languageCode == "ko" {
            label.accessibilityLabel = "회원정보를 기입. 1.이메일 주소를 입력후 인증메일 전송버튼을 눌러주세요. 2.인증번호를 입력후 확인하기 버튼을 눌러주세요. 3.비밀번호를 입력후 확인을 위해 한번더 입력해주세요. 4.별명을 입력해주세요."
        }
        
        return label
    }()
    
    private lazy var infoCoverView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var emailView: UIView = {
        let view = UIView()
        view.setupSubViewTextFieldView()
        return view
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "이메일 주소".localized()
        textField.keyboardType = .emailAddress
        textField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var certificationButton: UIButton = {
        let button = UIButton()
        button.setupValidButton(title: "인증메일 전송".localized(), textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
        button.addTarget(self, action: #selector(emailValid), for: .touchUpInside)
        button.accessibilityLabel = "인증메일 전송".localized()
        return button
    }()
    
    private lazy var codeView: UIView = {
        let view = UIView()
        view.setupSubViewTextFieldView()
        view.alpha = 0.3
        return view
    }()
    
    private lazy var codeTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "인증번호 입력".localized()
        textField.isEnabled = false
        textField.keyboardType = .numberPad
        textField.alpha = 0.3
        textField.isEnabled = false
        textField.addTarget(self, action: #selector(codeTextFieldDidChange), for: .editingChanged)
        textField.delegate = self
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textField.accessibilityElementsHidden = true
        return textField
    }()
    
    private lazy var timeStampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .right
        label.text = "05:00"
        label.isHidden = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var codeConfirmButton: UIButton = {
        let button = UIButton()
        button.setupValidButton(title: "확인하기".localized(), textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
        button.addTarget(self, action: #selector(codeConfirm), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.accessibilityElementsHidden = true
        button.accessibilityLabel = "인증번호 확인하기".localized()
        return button
    }()
    
    private lazy var passwordView: UIView = {
        let view = UIView()
        view.setupSubViewTextFieldView()
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "비밀번호(영문+숫자+특수문자, 8자리이상)".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordConfirmView: UIView = {
        let view = UIView()
        view.setupSubViewTextFieldView()
        return view
    }()
    
    private lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "비밀번호 확인".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var nickNameView: UIView = {
        let view = UIView()
        view.setupSubViewTextFieldView()
        return view
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "별명".localized()
        textField.keyboardType = .emailAddress
        textField.delegate = self
        return textField
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "회원가입".localized(), fontSize: 16)
        button.alpha = 0.3
        button.isEnabled = false
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
        setKeyboardHalfObserver()
        setNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allAgreeView.layer.addBorder([.top], color: .label, width: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 회원가입화면입니다.")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stopTimer()
        removeNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}

// MARK: - Extension
extension SignUpViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "회원가입".localized()
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
            agreePlaceHolderView, infoPlaceHolderView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        termsView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        privacyView.snp.makeConstraints {
            $0.height.equalTo(30 + intervalSize)
        }
        
        allAgreeView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        // MARK: - 약관화면 UI_SETUP
        agreePlaceHolderView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        [
            agreePlaceHolderLabel, agreeStackView
        ].forEach {
            agreePlaceHolderView.addSubview($0)
        }
        
        agreePlaceHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        agreeStackView.snp.makeConstraints {
            $0.top.equalTo(agreePlaceHolderLabel.snp.bottom).offset(intervalSize/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [allAgreeLabel, allAgreeButton].forEach {
            allAgreeView.addSubview($0)
        }
        
        allAgreeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        allAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        [termsLabel, termsAgreeButton].forEach {
            termsView.addSubview($0)
        }
        
        termsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        termsAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize * 2)
            $0.bottom.equalToSuperview()
        }
        
        [privacyLabel, privacyAgreeButton].forEach {
            privacyView.addSubview($0)
        }
        
        privacyLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize/2)
        }
        
        privacyAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize * 2)
            $0.bottom.equalToSuperview().inset(intervalSize/2)
        }
        
        // MARK: - 회원가입정보 UI_SETUP
        infoPlaceHolderView.snp.makeConstraints {
            $0.top.equalTo(agreeStackView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(intervalSize)
        }
        
        [infoPlaceHolderLabel, infoView].forEach {
            infoPlaceHolderView.addSubview($0)
        }
        
        infoPlaceHolderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(infoPlaceHolderLabel.snp.bottom).offset(intervalSize/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        [
            emailView, emailTextField, certificationButton,
            codeView, codeTextField, timeStampLabel, codeConfirmButton,
            passwordView, passwordTextField,
            passwordConfirmView, passwordConfirmTextField,
            nickNameView, nickNameTextField,
            signUpButton, infoCoverView
        ].forEach {
            infoView.addSubview($0)
        }
        
        emailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(emailView)
            $0.leading.equalTo(emailView.snp.leading).offset(intervalSize / 2)
            $0.trailing.equalTo(certificationButton.snp.leading)
        }
        
        certificationButton.snp.makeConstraints {
            $0.trailing.equalTo(emailView.snp.trailing).inset(intervalSize / 2)
            $0.centerY.equalTo(emailView.snp.centerY)
            $0.height.equalTo(25)
            $0.width.equalTo(80)
        }
        
        codeView.snp.makeConstraints {
            $0.top.equalTo(emailView.snp.bottom).offset(intervalSize / 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(codeView)
            $0.leading.equalTo(codeView.snp.leading).offset(intervalSize / 2)
        }
        
        timeStampLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(codeView)
            $0.leading.equalTo(codeTextField.snp.trailing)
        }
        
        codeConfirmButton.snp.makeConstraints {
            $0.leading.equalTo(timeStampLabel.snp.trailing).offset(intervalSize / 2)
            $0.trailing.equalTo(codeView.snp.trailing).inset(intervalSize / 2)
            $0.centerY.equalTo(codeView.snp.centerY)
            $0.height.equalTo(25)
            $0.width.equalTo(80)
        }
        
        passwordView.snp.makeConstraints {
            $0.top.equalTo(codeView.snp.bottom).offset(intervalSize / 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(passwordView)
            $0.leading.equalTo(passwordView.snp.leading).offset(intervalSize / 2)
            $0.trailing.equalTo(passwordView.snp.trailing)
        }
        
        passwordConfirmView.snp.makeConstraints {
            $0.top.equalTo(passwordView.snp.bottom).offset(intervalSize / 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        passwordConfirmTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(passwordConfirmView)
            $0.leading.equalTo(passwordConfirmView.snp.leading).offset(intervalSize / 2)
            $0.trailing.equalTo(passwordConfirmView.snp.trailing)
        }
        
        nickNameView.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmView.snp.bottom).offset(intervalSize / 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(nickNameView)
            $0.leading.equalTo(nickNameView.snp.leading).offset(intervalSize / 2)
            $0.trailing.equalTo(nickNameView.snp.trailing)
        }
        
        signUpButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        infoCoverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - 함수
    func reset() {
        emailBool = false
        emailView.alpha = 0.3
        emailView.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.text = ""
        emailTextField.alpha = 1
        emailTextField.isEnabled = true

        stopTimer()
        
        codeBool = false
        codeView.alpha = 0.3
        codeView.layer.borderColor = UIColor.lightGray.cgColor
        codeTextField.text = ""
        codeTextField.alpha = 0.3
        codeTextField.isEnabled = false
        
        certificationButton.setupValidButton(title: "인증메일 전송".localized(), textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
        showToVoice(type: .announcement, text: "회원정보기입화면이 새로고침 되었습니다.")
        codeConfirmButton.setupValidButton(textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
    }
    
    func setNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(addbackGroundTime(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
        }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
    }
    
    // MARK: - 함수 시간체크
    private func startTime() {
        timeStampLabel.isHidden = false
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timeStampLabel.text = String(format: "%02d:%02d", minutes, seconds)
                
                if self.currentSeconds <= 0 {
                    self.reset()
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.showToast(message: "인증시간이 만료되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                    self.showToVoice(type: .announcement, text: "인증시간이 만료되었습니다.")
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        self.timer?.cancel()
        self.timer = nil
        currentSeconds = 300
        timeStampLabel.isHidden = true
        timeStampLabel.text = "00:00"
    }
    
    // MARK: - 함수 유효성체크
    func codeViewEnabel() {
        startTime()
        emailBool = true
        codeView.alpha = 1
        codeTextField.alpha = 1
        codeTextField.isEnabled = true
        emailView.layer.borderColor = personalColor?.cgColor
        emailTextField.alpha = 0.1
        emailTextField.accessibilityElementsHidden = true
        emailTextField.isEnabled = false
        certificationButton.setupValidButton(title: "취소하기".localized(), textColor: .white, backgroundColor: .darkGray, alpha: 1, enable: true)
        certificationButton.accessibilityLabel = "인증취소하기".localized()
        codeTextField.accessibilityElementsHidden = false
        codeConfirmButton.accessibilityElementsHidden = false
        timeStampLabel.isHidden = false
    }
    
    func codeViewDesable() {
        codeBool = true
        codeView.layer.borderColor = personalColor?.cgColor
        codeTextField.alpha = 0.1
        codeTextField.isEnabled = false
        certificationButton.setupValidButton(title: "인증완료".localized(), textColor: .black, backgroundColor: personalColor, alpha: 0.1, enable: false)
        certificationButton.accessibilityLabel = "인증메일 전송".localized()
        codeConfirmButton.setupValidButton(textColor: .black, backgroundColor: personalColor, alpha: 0.1, enable: false)
        signUpButton.alpha = 1
        signUpButton.isEnabled = true
        signUpButton.isAccessibilityElement = true
        stopTimer()
        timeStampLabel.isHidden = true
        certificationButton.accessibilityElementsHidden = true
        codeTextField.accessibilityElementsHidden = true
        codeConfirmButton.accessibilityElementsHidden = true
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailTextField.text)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,64}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: passwordTextField.text)
    }
    
    func isValidCode() -> Bool {
        if codeTextField.text == "" {
            return false
        }
        let codeRegex = "^[0-9]{6}$"
        let codeTest = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codeTest.evaluate(with: codeTextField.text)
    }
    
    func isSamePassword() -> Bool {
        return passwordTextField.text == passwordConfirmTextField.text
    }
    
    // MARK: - 함수_objc
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
        if let topViewController = keyWindow?.visibleViewController {
            topViewController.present(popupTextViewController, animated: false, completion: nil)
        }
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
    
    @objc func addbackGroundTime(_ notification:Notification) {
        if self.timer != nil {
            let time = notification.userInfo?["time"] as? Int ?? 0
            currentSeconds -= time
        }
      }
    
    // MARK: - 함수_objc 유효성체크
    @objc func emailValid() {
        if emailBool {
            reset()
        } else {
            if isValidEmail() {
                var request = URLRequest(url: URL(string: emailValidateURL)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 10
                
                let params = ["email":emailTextField.text!] as Dictionary
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
#if DEBUG
                    print("http Body Error")
#endif
                }
                
                LoadingIndicator.showLoading(className: self.className, function: "emailValid")
                AF.request(request).responseDecodable(of: EmailValidation.self) { [weak self] (response) in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        if data.status == 201 {
                            guard let validationData = data.data else { return }
                            self.uuid = validationData.uuid
                            self.codeViewEnabel()
                            self.view.endEditing(true)
                            self.showToast(message: "인증번호를 전송했습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                            self.showToVoice(type: .announcement, text: "인증번호를 전송했습니다. 만료시간은 5분입니다. 인증하기 버튼이 인증취소하기 버튼으로 변경되었습니다.")
                        } else {
                            self.showConfirmAlert("중복된 이메일입니다.", "알림")
                        }
                    case .failure(let error):
                        self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
#endif
                    }
                    DispatchQueue.main.async {
                        LoadingIndicator.hideLoading()
                    }
                }
            } else {
                showConfirmAlert("이메일이 유효하지 않습니다.", "알림")
            }
        }
    }
    
    @objc func emailTextFieldDidChange() {
        if isValidEmail() {
            certificationButton.setupValidButton(textColor: .black, backgroundColor: personalColor, alpha: 1, enable: true)
            showToVoice(type: .announcement, text: "인증메일 전송버튼이 활성화 되었습니다.")
        } else {
            certificationButton.setupValidButton(textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
        }
    }
    
    @objc func codeTextFieldDidChange() {
        if isValidCode() {
            codeConfirmButton.setupValidButton(textColor: .black, backgroundColor: personalColor, alpha: 1, enable: true)
            showToVoice(type: .announcement, text: "인증번호 확인버튼이 활성화 되었습니다.")
        } else {
            codeConfirmButton.setupValidButton(textColor: .white, backgroundColor: .lightGray, alpha: 0.5, enable: false)
        }
    }
    
    // MARK: - 함수_objc API_Request
    @objc func signUp() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard termsAgreeBool else { return showConfirmAlert("이용약관에 동의해주세요.", "알림") }
        guard privacyAgreeBool else { return showConfirmAlert("개인정보처리방침에 동의해주세요.", "알림") }
        guard codeBool else { return showConfirmAlert("인증번호가 유효하지 않습니다.", "알림") }
        guard isValidPassword() else { return showConfirmAlert("비밀번호가 유효하지 않습니다.", "알림") }
        guard let passwordCheck = passwordTextField.text, !passwordCheck.contains(" ") else { return showConfirmAlert("비밀번호는 띄어쓰기 및 빈칸이\n포함될 수 없습니다.", "알림") }
        guard isSamePassword() else { return showConfirmAlert("비밀번호가 일치하지 않습니다.", "알림") }
        guard let nickname = nickNameTextField.text, nickname != "", !nickname.contains(" ") else { return self.showConfirmAlert("별명은 띄어쓰기 및 빈칸이\n포함될 수 없습니다.", "알림") }
        if app.languageCode == "ko" {
            guard nickNameTextField.text?.count ?? 0 <= 10 else { return showConfirmAlert("별명은 글자수 10자까지 가능합니다.", "알림") }
        }
        
        var request = URLRequest(url: URL(string: signUpURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        let params = [
            "email": emailTextField.text!,
            "nickname": nickname,
            "password": passwordCheck
        ] as Dictionary

        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
                    print("http Body Error")
#endif
        }
        
        LoadingIndicator.showLoading(className: self.className, function: "signUp")
        AF.request(request).responseDecodable(of: Signup.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(_):
                guard let topViewController = keyWindow?.visibleViewController else { return }
                let logOkAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default){ (action: UIAlertAction) in
                    self.delegate?.recieveData(response: self.emailTextField.text!)
                    topViewController.navigationController?.popViewController(animated: true)
                }
                self.showOneActionAlert("가입인사".localized(with: nickname), "알림".localized(), logOkAction)
            case .failure(let error):
                self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
#endif
            }
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    @objc func codeConfirm() {
        if isValidCode() {
            var request = URLRequest(url: URL(string: codeValidateURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let params = ["code": Int(codeTextField.text!)!, "uuid": uuid ?? ""] as Dictionary
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                    print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "codeConfirm")
            AF.request(request).responseDecodable(of: UserResponseData.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 200 {
                        self.codeViewDesable()
                        self.showToast(message: "확인되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "확인되었습니다.")
                    } else {
                        self.showConfirmAlert("인증번호가 유효하지 않습니다.", "알림")
                    }
                case .failure(let error):
                    self.showCloseAlert("죄송합니다.\n서둘러 복구하겠습니다.", "서버점검")
#if DEBUG
print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
#endif
                }
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
            }
        } else {
            self.showConfirmAlert("인증번호가 유효하지 않습니다.", "알림")
        }
    }
}

// MARK: - Textfield Delegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if UIAccessibility.isVoiceOverRunning {
            textField.resignFirstResponder()
            return true
        } else {
            if textField == passwordTextField {
                passwordConfirmTextField.becomeFirstResponder()
            } else if textField == passwordConfirmTextField {
                nickNameTextField.becomeFirstResponder()
            } else {
                nickNameTextField.resignFirstResponder()
            }
            return true
        }
    }
}

// MARK: - AgreeData Delegate
extension SignUpViewController: SendAgreeDataDelegate {
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
