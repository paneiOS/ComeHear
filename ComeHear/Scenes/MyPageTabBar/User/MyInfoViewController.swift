//
//  MyInfoViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/17.
//

import UIKit
import Alamofire

class MyInfoViewController: UIViewController {
    // MARK: - 스크롤 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = personalColor
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = personalColor
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.backgroundColor = personalColor
        return view
    }()
    
    // MARK: - 나의정보 UI
    private lazy var myInfoView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var myInfoLabelView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: firstCellColor)
        return view
    }()
    
    private lazy var myInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.text = "나의 정보".localized()
        return label
    }()
    
    private lazy var userNicknameView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var userNicknameTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .lightGray
        label.text = "별명".localized()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var userNicknameLabel: UILabel = {
        let label = UILabel()
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return label }
        guard let nickname = app.userNickName else { return label }
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.text = nickname
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var userLoginTypeView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var myLoginTypeTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .lightGray
        label.text = "로그인 타입".localized()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var myLoginTypeLabel: UILabel = {
        let label = UILabel()
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return label }
        guard let type = app.loginType else { return label }
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.text = type
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    // MARK: - 추가정보변경 UI
    private lazy var myInfoChangeView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var myInfoChangeLabelView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: firstCellColor)
        return view
    }()
    
    private lazy var myInfoChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.text = "추가정보 변경".localized()
        return label
    }()
    
    private lazy var myNicknamePlaceHold: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.text = "별명".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var myNicknameChangeTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var myNicknameChangeTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "변경할 별명을 입력해주세요.".localized()
        textField.delegate = self
        return textField
    }()
    
    private lazy var myInfoChangeButton: UIButton = {
        let button = UIButton()
        button.setupHalfButton(title: "별명 변경하기".localized())
        button.addTarget(self, action: #selector(changeMyInfo), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 비밀번호변경 UI
    private lazy var passwordView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var passwordSubView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var passwordChangeLabelView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: firstCellColor)
        return view
    }()
    
    private lazy var passwordChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.text = "비밀번호 변경".localized()
        return label
    }()
    
    private lazy var passwordChangeSecondLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .lightGray
        label.text = "(영문 + 숫자 + 특수문자, 8자리이상)".localized()
        return label
    }()
    
    private lazy var currentPasswordTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var currentPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "현재 비밀번호".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "변경할 비밀번호".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordConfirmTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.placeholder = "변경할 비밀번호 확인".localized()
        textField.keyboardType = .alphabet
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var passwordChangeButton: UIButton = {
        let button = UIButton()
        button.setupHalfButton(title: "암호 변경하기".localized())
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 탈퇴/연동해제 UI
    private lazy var secessionView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var secessionLabelView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: firstCellColor)
        return view
    }()
    
    private lazy var secessionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, app.loginType == "EMAIL" {
            label.text = "탈퇴".localized()
        } else {
            label.text = "탈퇴 / 연동해제".localized()
        }
        return label
    }()
    
    private lazy var secessionButton: UIButton = {
        let button = UIButton()
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login, app.loginType == "EMAIL" {
            button.setupHalfButton(title: "탈퇴".localized())
        } else {
            button.setupHalfButton(title: "탈퇴 / 연동해제".localized())
        }
        button.addTarget(self, action: #selector(tapSecession), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
        checkUserSocialLogin()
        setKeyboardHalfObserver()
        keyboardHide()
        scrollView.delegate = self
    }
}

//MARK: - Extension
extension MyInfoViewController {
    
    
    //MARK: - 네비게이션 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "내 정보 관리".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    //MARK: - 기본 UI_SETUP
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
        
        [
            myInfoView, myInfoChangeView, passwordView, secessionView
        ].forEach {
            subContentView.addSubview($0)
        }
        
        // MARK: - 나의정보 UI_SETUP
        myInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
        }
        
        [
            myInfoLabelView,
            userNicknameView, userLoginTypeView
        ].forEach {
            myInfoView.addSubview($0)
        }
        
        myInfoLabelView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        myInfoLabelView.addSubview(myInfoLabel)
        
        myInfoLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        userNicknameView.snp.makeConstraints {
            $0.top.equalTo(myInfoLabel.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
            $0.height.equalTo(40)
        }
        
        [userNicknameTitle, userNicknameLabel].forEach {
            userNicknameView.addSubview($0)
        }
        
        userNicknameTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        userNicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        userLoginTypeView.snp.makeConstraints {
            $0.top.equalTo(userNicknameView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
            $0.height.equalTo(40)
        }
        
        [myLoginTypeTitle, myLoginTypeLabel].forEach {
            userLoginTypeView.addSubview($0)
        }
        
        myLoginTypeTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        myLoginTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        // MARK: - 추가정보변경 UI_SETUP
        myInfoChangeView.snp.makeConstraints {
            $0.top.equalTo(myInfoView.snp.bottom).offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
        }
        
        [
            myInfoChangeLabelView, myNicknamePlaceHold,
            myNicknameChangeTextFieldView, myNicknameChangeTextField,
            myInfoChangeButton
        ].forEach {
            myInfoChangeView.addSubview($0)
        }
        
        myInfoChangeLabelView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        myInfoChangeLabelView.addSubview(myInfoChangeLabel)
        
        myInfoChangeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        myNicknamePlaceHold.snp.makeConstraints {
            $0.top.equalTo(myInfoChangeLabelView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        myNicknameChangeTextFieldView.snp.makeConstraints {
            $0.top.equalTo(myNicknamePlaceHold.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        myNicknameChangeTextField.snp.makeConstraints {
            $0.top.equalTo(myNicknameChangeTextFieldView.snp.top)
            $0.leading.equalTo(myNicknameChangeTextFieldView.snp.leading).offset(intervalSize)
            $0.trailing.equalTo(myNicknameChangeTextFieldView.snp.trailing).inset(intervalSize)
            $0.bottom.equalTo(myNicknameChangeTextFieldView.snp.bottom)
        }
        
        myInfoChangeButton.snp.makeConstraints {
            $0.top.equalTo(myNicknameChangeTextField.snp.bottom).offset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(frameSizeWidth / 2)
            $0.height.equalTo(40)
        }
        
        // MARK: - 암호변경 UI_SETUP
        passwordView.snp.makeConstraints {
            $0.top.equalTo(myInfoChangeView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            
        }
        
        passwordView.addSubview(passwordSubView)
        
        passwordSubView.snp.makeConstraints {
            $0.top.equalTo(myInfoChangeView.snp.bottom).offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
        }
        
        [
            passwordChangeLabelView, passwordChangeSecondLabel,
            currentPasswordTextFieldView, currentPasswordTextField,
            passwordTextFieldView, passwordTextField,
            passwordConfirmTextFieldView, passwordConfirmTextField,
            passwordChangeButton
        ].forEach {
            passwordSubView.addSubview($0)
        }
        
        passwordChangeLabelView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        passwordChangeLabelView.addSubview(passwordChangeLabel)
        
        passwordChangeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        passwordChangeSecondLabel.snp.makeConstraints {
            $0.top.equalTo(passwordChangeLabelView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        currentPasswordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(passwordChangeSecondLabel.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        currentPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(currentPasswordTextFieldView.snp.top)
            $0.leading.equalTo(currentPasswordTextFieldView.snp.leading).offset(intervalSize)
            $0.trailing.equalTo(currentPasswordTextFieldView.snp.trailing).inset(intervalSize)
            $0.bottom.equalTo(currentPasswordTextFieldView.snp.bottom)
        }
        
        passwordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(currentPasswordTextFieldView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextFieldView.snp.top)
            $0.leading.equalTo(passwordTextFieldView.snp.leading).offset(intervalSize)
            $0.trailing.equalTo(passwordTextFieldView.snp.trailing).inset(intervalSize)
            $0.bottom.equalTo(passwordTextFieldView.snp.bottom)
        }
        
        passwordConfirmTextFieldView.snp.makeConstraints {
            $0.top.equalTo(passwordTextFieldView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
        
        passwordConfirmTextField.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmTextFieldView.snp.top)
            $0.leading.equalTo(passwordConfirmTextFieldView.snp.leading).offset(intervalSize)
            $0.trailing.equalTo(passwordConfirmTextFieldView.snp.trailing).inset(intervalSize)
            $0.bottom.equalTo(passwordConfirmTextFieldView.snp.bottom)
        }
        
        passwordChangeButton.snp.makeConstraints {
            $0.top.equalTo(passwordConfirmTextFieldView.snp.bottom).offset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(frameSizeWidth / 2)
            $0.height.equalTo(40)
        }
        
        // MARK: - 탈퇴/연동 UI_SETUP
        secessionView.snp.makeConstraints {
            $0.top.equalTo(passwordView.snp.bottom).offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize * 2)
            $0.width.equalTo(frameSizeWidth-(intervalSize * 2))
        }
        
        [
            secessionLabelView, secessionButton
        ].forEach {
            secessionView.addSubview($0)
        }
        
        secessionLabelView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        secessionLabelView.addSubview(secessionLabel)
        
        secessionLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        secessionButton.snp.makeConstraints {
            $0.top.equalTo(secessionLabelView.snp.bottom).offset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(frameSizeWidth / 2)
            $0.height.equalTo(40)
        }
    }
    
    private func keyboardHide() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func checkUserSocialLogin() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginType != "EMAIL" {
            passwordView.snp.makeConstraints {
                $0.height.equalTo(0)
            }
            passwordView.isHidden = true
            scrollView.snp.makeConstraints {
                $0.height.equalTo(view.safeAreaLayoutGuide.snp.height)
            }
        }
    }
    
    private func isValidCurrentPassword() -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,64}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: currentPasswordTextField.text)
    }
    
    private func isValidPassword() -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,64}"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: passwordTextField.text)
    }
    
    private func isSamePassword() -> Bool {
        return passwordTextField.text == passwordConfirmTextField.text
    }
    
    @objc private func changeMyInfo() {
        guard let nickname = myNicknameChangeTextField.text, nickname != "", !nickname.contains(" ") else { return showConfirmAlert("별명은 띄어쓰기 및 빈칸이\n포함될 수 없습니다.", "알림") }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.languageCode == "ko" {
            guard myNicknameChangeTextField.text?.count ?? 0 <= 10 else { return showConfirmAlert("별명은 글자수 10자까지 가능합니다.", "알림") }
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            guard let memberIdx = app.userMemberIdx else { return }
            
            var request = URLRequest(url: URL(string: nicknameChangeURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            let params = [
                "memberIdx": memberIdx,
                "nickname" : nickname
            ] as [String : Any]
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
#if DEBUG
                print("http Body Error")
#endif
            }
            
            LoadingIndicator.showLoading(className: self.className, function: "changeMyInfo")
            AF.request(request).responseDecodable(of: UserResponseData.self) { [weak self] (response) in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 200 {
                        if app.loginState == .login {
                            app.userNickName = nickname
                            UserDefaults.standard.set(nickname, forKey: "user_nickName")
                        }
                        self.showCloseAlert("별명이 변경되었습니다.", "알림")
                    } else if data.status == 406 {
                        self.showConfirmAlert("잘못된 별명입니다.\n다른 별명을 입력해주세요.", "잘못된 별명")
                    } else if data.status == 409 {
                        self.showConfirmAlert("중복된 별명입니다.\n다른 별명을 입력해주세요.", "중복된 별명")
                    } else {
                        print(data.status)
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
        }
    }
    
    @objc private func changePassword() {
        guard isValidCurrentPassword() else { return showConfirmAlert("현재 비밀번호가 유효하지 않습니다.", "알림") }
        guard isValidPassword() else { return showConfirmAlert("비밀번호가 유효하지 않습니다.", "알림") }
        guard let passwordCheck = passwordTextField.text, !passwordCheck.contains(" ") else { return showConfirmAlert("비밀번호는 띄어쓰기 및 빈칸이\n포함될 수 없습니다.", "알림") }
        guard isSamePassword() else { return showConfirmAlert("비밀번호가 일치하지 않습니다.", "알림") }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let originPassword = currentPasswordTextField.text else { return }
        guard let newPassword = passwordTextField.text else { return }
        guard let memberIdx = app.userMemberIdx else { return }
        
        var request = URLRequest(url: URL(string: passwordChangeURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params = [
            "memberIdx": memberIdx,
            "originPassword" : originPassword,
            "newPassword" : newPassword
        ] as [String : Any]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
            print("http Body Error")
#endif
        }
        
        LoadingIndicator.showLoading(className: self.className, function: "changePassword")
        AF.request(request).responseDecodable(of: UserResponseData.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    self.showCloseAlert("비밀번호가 변경되었습니다.", "알림")
                } else if data.status == 400 {
                    self.showConfirmAlert("비밀번호가 일치하지 않습니다.", "알림")
                } else {
                    print(data.status)
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
    }
    
    @objc private func tapSecession() {
        if let app = UIApplication.shared.delegate as? AppDelegate, app.loginState == .login {
            let secessionAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { [weak self] _ in
                
                guard let self = self else { return }
                guard let memberIdx = app.userMemberIdx else { return }
                var request = URLRequest(url: URL(string: secessionURL)!)
                request.httpMethod = "DELETE"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 10
                let params = [
                    "memberIdx": memberIdx
                ] as [String : Any]
                print("params", params)
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
#if DEBUG
                    print("http Body Error")
#endif
                }
                
                LoadingIndicator.showLoading(className: self.className, function: "tapSecession")
                AF.request(request).responseDecodable(of: UserResponseData.self) { [weak self] (response) in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        if data.status == 200 {
                            app.userLogin = false
                            let goMainAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { _ in
                                guard let topViewController = keyWindow?.visibleViewController else { return }
                                topViewController.tabBarController?.selectedIndex = 0
                            }
                            self.showOneActionAlert("탈퇴처리 되었습니다.".localized(), "알림".localized(), goMainAction)
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
            }
            showTwoActionAlert("정말 탈퇴 하시겠습니까?", "탈퇴", secessionAction)
        }
    }
}

extension MyInfoViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
}

extension MyInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case myNicknameChangeTextField:
            scrollView.scroll(to: .top)
            myNicknameChangeTextField.resignFirstResponder()
        case passwordTextField:
            scrollView.scroll(to: .bottom)
            passwordConfirmTextField.becomeFirstResponder()
        case passwordConfirmTextField:
            scrollView.scroll(to: .bottom)
            passwordConfirmTextField.resignFirstResponder()
        default:
            return true
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case myNicknameChangeTextField:
            scrollView.scroll(to: .top)
        case currentPasswordTextField, passwordTextField, passwordConfirmTextField:
            scrollView.scroll(to: .bottom)
        default:
            break
        }
    }
}
