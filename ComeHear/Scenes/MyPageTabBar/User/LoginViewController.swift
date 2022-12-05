//
//  LoginViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/07.
//

import UIKit
import KakaoSDKUser
import AuthenticationServices
import Alamofire

class LoginViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    // MARK: - 변수, 상수
    private var testUser = ""
    private var testAuthCode = ""

    // MARK: - 로그인 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    private lazy var loginView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var signInLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "Email 로그인".localized()
        return label
    }()
    
    // MARK: - 로그인_ID UI
    private lazy var persionView: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "person", pointSize: 20)
        button.tintColor = .gray
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var emailView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.moreLightGrayColor.getColor()
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "이메일 로그인".localized()
        textField.keyboardType = .emailAddress
        textField.delegate = self
        return textField
    }()
    
    // MARK: - 로그인_암호 UI
    private lazy var eyeView: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "eye.slash", pointSize: 20)
        button.tintColor = .gray
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var passwordView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.moreLightGrayColor.getColor()
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "비밀번호 입력".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "로그인".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "아직 Come Hear 회원이 아니신가요?".localized()
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "회원가입".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(tapSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var snsLoginView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var snsSignUpLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "SNS 로그인 / 회원가입".localized()
        return label
    }()
    
    private lazy var kakaoLoginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login_medium_wide_ko".localized())
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var kakaoLoginLeadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login_medium_wide_leading")
        return imageView
    }()
    
    private lazy var kakaoLoginTrailingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login_medium_wide_trailing")
        return imageView
    }()
    
    private lazy var kakaoLoginView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(kakaoLogin))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "카카오로그인 및 회원가입".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var appleLoginbBtton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        button.addTarget(self, action: #selector(appleLogin), for: .touchUpInside)
        button.accessibilityLabel = "애플로그인 및 회원가입".localized()
        return button
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 로그인 화면입니다.")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
}

// MARK: - Extension
extension LoginViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "로그인".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        //MARK: - 로그인화면 UI_SETUP
        [
            loginView, snsLoginView, signUpView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        loginView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            signInLabel,
            emailView, passwordView,
            loginButton,
            signUpButton
        ].forEach {
            loginView.addSubview($0)
        }
        
        signInLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        emailView.snp.makeConstraints {
            $0.top.equalTo(signInLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [persionView ,emailTextField].forEach {
            emailView.addSubview($0)
        }
        
        
        persionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.width.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(persionView.snp.trailing).offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            eyeView ,passwordTextField
        ].forEach {
            passwordView.addSubview($0)
        }
        
        passwordView.snp.makeConstraints {
            $0.top.equalTo(emailView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        eyeView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.width.height.equalTo(50)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(eyeView.snp.trailing).offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(constantSize.intervalSize * 2)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        snsLoginView.snp.makeConstraints {
            $0.top.equalTo(loginView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            kakaoLoginImageView, kakaoLoginLeadingImageView, kakaoLoginTrailingImageView,
            kakaoLoginView,
            appleLoginbBtton,
            snsSignUpLabel
        ].forEach {
            snsLoginView.addSubview($0)
        }
        
        snsSignUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        kakaoLoginImageView.snp.makeConstraints {
            $0.top.equalTo(snsSignUpLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.centerX.equalToSuperview()
        }
        
        kakaoLoginLeadingImageView.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginImageView.snp.top)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalTo(kakaoLoginImageView.snp.bottom)
        }
        
        kakaoLoginTrailingImageView.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginImageView.snp.top)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalTo(kakaoLoginImageView.snp.bottom)
        }
        
        kakaoLoginView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalTo(kakaoLoginImageView.snp.bottom)
        }
        
        appleLoginbBtton.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginImageView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(kakaoLoginImageView.snp.height)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        signUpView.snp.makeConstraints {
            $0.top.equalTo(snsLoginView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
    }
    
    private func socialLogin(_ nickname: String?, _ token: String, _ type: String, _ fullName: String, _ authCode: String) {
        guard let url = URL(string: URLString.SubDomain.socialLoginURL.getURL()) else { return }
        var request = URLRequest(url: url)
        let params = ["token": token, "type": type, "authCode" : authCode] as Dictionary
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
        LoadingIndicator.showLoading(className: self.className, function: "socialLogin")
        AF.request(request).responseDecodable(of: Login.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    guard let userData = data.data else { return }
                    UserDefaults.standard.set(true, forKey: "user_login")
                    UserDefaults.standard.set(type, forKey: "user_loginType")
                    UserDefaults.standard.set(userData.memberIdx, forKey: "user_memberIdx")
                    UserDefaults.standard.set(userData.token, forKey: "user_token")
                    UserDefaults.standard.set(userData.nickName, forKey: "user_nickName")
                    UserDefaults.standard.set(userData.email, forKey: "user_emil")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showLoginAlert("로그인알림".localized(with: userData.nickName), "알림".localized())
                        if let app = UIApplication.shared.delegate as? AppDelegate {
                            app.userLogin = true
                        }
                    }
                } else {
                    if type == "APPLE" {
                        self.sendAppleToken(token, type, fullName, authCode)
                    } else {
                        //회원가입
                        let additionalInformationViewController = AdditionalInformationViewController()
                        additionalInformationViewController.token = token
                        additionalInformationViewController.type = type
                        additionalInformationViewController.fullName = fullName
                        additionalInformationViewController.hero.isEnabled = true
                        additionalInformationViewController.hero.modalAnimationType = .fade
                        additionalInformationViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                        self.present(additionalInformationViewController, animated: true)
                        DispatchQueue.main.async {
                            LoadingIndicator.hideLoading()
                        }
                    }
                }
            case .failure(_):
                self.showCloseAlert(type: .unknownError)
            }
            
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    private func sendAppleToken(_ token: String, _ type: String, _ fullName: String, _ authCode: String) {
        guard let url = URL(string: URLString.SubDomain.sendAppleTokenURL.getURL()) else { return }
        var request = URLRequest(url: url)
        let params = ["token": token, "authCode" : authCode] as Dictionary
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
        LoadingIndicator.showLoading(className: self.className, function: "sendAppleToken")
        AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    let additionalInformationViewController = AdditionalInformationViewController()
                    additionalInformationViewController.token = token
                    additionalInformationViewController.type = type
                    additionalInformationViewController.fullName = fullName
                    additionalInformationViewController.hero.isEnabled = true
                    additionalInformationViewController.hero.modalAnimationType = .fade
                    additionalInformationViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                    self.present(additionalInformationViewController, animated: true)
                }
            case .failure(_):
                self.showCloseAlert(type: .unknownError)
            }
            
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }

    @objc func login() {
        guard isValidEmail() else { return showConfirmAlert(type: .idToEmail) }
        guard let password = passwordTextField.text, password != "", !password.contains(" ") else { return showConfirmAlert(type: .passwordNotBlank) }
        guard let url = URL(string: URLString.SubDomain.loginURL.getURL()) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        let params = ["email": emailTextField.text!, "password": passwordTextField.text!] as Dictionary
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
            print("http Body Error")
            #endif
        }
        
        LoadingIndicator.showLoading(className: self.className, function: "login")
        AF.request(request).responseDecodable(of: Login.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    guard let userData = data.data else { return }
                    UserDefaults.standard.set(true, forKey: "user_login")
                    UserDefaults.standard.set("EMAIL", forKey: "user_loginType")
                    UserDefaults.standard.set(userData.memberIdx, forKey: "user_memberIdx")
                    UserDefaults.standard.set(userData.token, forKey: "user_token")
                    UserDefaults.standard.set(userData.nickName, forKey: "user_nickName")
                    UserDefaults.standard.set(userData.email, forKey: "user_emil")
                    self.view.endEditing(true)
                    self.showLoginAlert("로그인알림".localized(with: userData.nickName), "알림".localized())
                    if let app = UIApplication.shared.delegate as? AppDelegate {
                        app.userLogin = true
                    }
                } else {
                    self.showConfirmAlert(type: .emailAndPasswordCheck)
                }
            case .failure(_):
                self.showCloseAlert(type: .unknownError)
            }
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }
    
    @objc func kakaoLogin() {
        // 카카오톡 설치 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            loginWithApp()
        } else {
            // 만약, 카카오톡이 깔려있지 않을 경우에는 웹 브라우저로 카카오 로그인함.
            loginWithWeb()
        }
    }
    
    @objc func tapSignUp() {
        let signUpViewController = SignUpViewController()
        signUpViewController.delegate = self
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    @objc func appleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    /// JWTToken -> dictionary
    private func decode(jwtToken jwt: String) -> [String: Any] {
        
        func base64UrlDecode(_ value: String) -> Data? {
            var base64 = value
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")

            let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = requiredLength - length
            if paddingLength > 0 {
                let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
                base64 = base64 + padding
            }
            return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        }

        func decodeJWTPart(_ value: String) -> [String: Any]? {
            guard let bodyData = base64UrlDecode(value),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
            }

            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
}

// MARK: - Apple Login Extensions

extension LoginViewController: ASAuthorizationControllerDelegate {
    // 성공 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential, let data = credential.authorizationCode {
            let user = credential.user
            let authCode = String(data: data, encoding: .utf8) ?? ""
            let famillyName = credential.fullName?.familyName ?? ""
            let givenName = credential.fullName?.givenName ?? ""
            testUser = user
            testAuthCode = authCode
            socialLogin(nil, user, "APPLE", famillyName + givenName, authCode)
        }
    }

    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
#if DEBUG
        print("error")
        #endif
    }
}

// MARK: - Kakao Login Extensions

extension LoginViewController {
    // 카카오톡 앱으로 로그인
    func loginWithApp() {
        UserApi.shared.loginWithKakaoTalk {(what, error) in
            if let error = error {
#if DEBUG
                print(error)
                #endif
            } else {
                UserApi.shared.me { [weak self] (user, error) in
                    if let error = error {
#if DEBUG
                        print(error)
                        #endif
                    } else {
                        guard let self = self else { return }
                        self.socialLogin(user?.properties?["nickname"], String(user?.id ?? 0), "KAKAO", "", "")
                    }
                }
            }
        }
    }
    
    // 카카오톡 웹으로 로그인
    func loginWithWeb() {
        UserApi.shared.loginWithKakaoAccount {(_, error) in
            if let error = error {
#if DEBUG
                print(error)
                #endif
            } else {
                UserApi.shared.me { [weak self] (user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        guard let self = self else { return }
                        self.socialLogin(user?.properties?["nickname"], String(user?.id ?? 0), "KAKAO", "", "")
                    }
                }
            }
        }
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailTextField.text)
    }
}

extension LoginViewController: SendDataDelegate {
    func recieveData(response: String) {
        emailTextField.text = response
    }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      passwordTextField.resignFirstResponder()
    }
    return true
  }
}
