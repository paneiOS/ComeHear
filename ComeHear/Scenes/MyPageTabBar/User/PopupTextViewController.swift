//
//  PopupTextViewController.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/12.
//

import UIKit

protocol SendAgreeDataDelegate {
    func recieveTermsAgreeData()
    func recievePrivacyAgreeData()
}

final class PopupTextViewController: UIViewController {
    // MARK: - 변수, 상수
    var delegate : SendAgreeDataDelegate?
    var type: PopupType?
    private let constantSize = ConstantSize()
    
    // MARK: - 기본 UI
    private lazy var mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = ContentColor.moreLightGrayColor.getColor()
        return view
    }()
    
    private lazy var closeView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapClose))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .white
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        return button
    }()
    
    private lazy var subView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.setupSubViewHeader()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "ComeHear 서비스 약관".localized()
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        textView.textColor = .label
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.isEditable = false
        textView.contentInset = .init(top: constantSize.intervalSize, left: constantSize.intervalSize, bottom: constantSize.intervalSize, right: constantSize.intervalSize)
        return textView
    }()
    
    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        [contentFooterImageView, contentFooterView].forEach {
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()
    
    lazy var contentFooterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CopyRightImage")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var contentFooterView: UIView = {
        let view = UIView()
        view.setupSubViewFooter(color: ContentColor.personalColor.getColor())
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAgree))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        view.accessibilityLabel = "동의하고 계속하기".localized()
        return view
    }()
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "동의하고 계속하기".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    init(type: PopupType) {
        super.init(nibName: nil, bundle: nil)
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        switch type {
        case .comeHearTerms:
            self.titleLabel.text = "ComeHear 서비스 약관".localized()
            self.contentTextView.text = checkLanguage(app.languageCode, .comeHearTerms)
            self.contentFooterImageView.isHidden = true
            self.type = type
        case .comeHearPrivacy:
            self.titleLabel.text = "ComeHear 개인정보처리방침".localized()
            
            self.contentTextView.text = checkLanguage(app.languageCode, .comeHearPrivacy)
            self.contentFooterImageView.isHidden = true
            self.type = type
        case .tourApiTerms:
            self.titleLabel.text = "TourAPI 이용약관".localized()
            self.contentTextView.text = ""
            self.contentFooterView.isHidden = true
            self.type = type
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .comeHearTerms {
            showToVoice(type: .screenChanged, text: "이용약관 내용 화면입니다.")
        } else if type == .comeHearPrivacy {
            showToVoice(type: .screenChanged, text: "개인정보처리방침 내용 화면입니다.")
        }
        
    }
}

// MARK: - Extension
extension PopupTextViewController {
    
    // MARK: - 기본 UI_SETUP
    private func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        [
            mainView, closeView, subView,
            titleView, contentTextView,
            footerStackView
        ].forEach {
            view.addSubview($0)
        }

        mainView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(constantSize.intervalSize * 2)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(constantSize.frameSizeHeight * 2 / 3)
        }
        
        closeView.addSubview(closeButton)
        
        closeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.width.equalTo(50)
        }
        
        closeButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        subView.snp.makeConstraints {
            $0.top.equalTo(mainView.snp.top).offset(constantSize.intervalSize)
            $0.leading.equalTo(mainView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(mainView.snp.trailing).inset(constantSize.intervalSize)
            $0.bottom.equalTo(mainView.snp.bottom).inset(constantSize.intervalSize)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(subView.snp.top)
            $0.leading.equalTo(subView.snp.leading)
            $0.trailing.equalTo(subView.snp.trailing)
        }
        
        titleView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.centerX.equalToSuperview()
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalTo(mainView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(mainView.snp.trailing).inset(constantSize.intervalSize)
        }
        
        footerStackView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalTo(mainView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(mainView.snp.trailing).inset(constantSize.intervalSize)
            $0.bottom.equalTo(mainView.snp.bottom).inset(constantSize.intervalSize)
        }
        
        contentFooterImageView.snp.makeConstraints {
            $0.leading.equalTo(subView.snp.leading).offset(constantSize.intervalSize)
            $0.trailing.equalTo(subView.snp.trailing).inset(constantSize.intervalSize)
            $0.bottom.equalTo(subView.snp.bottom).inset(constantSize.intervalSize)
        }
        
        contentFooterView.snp.makeConstraints {
            $0.leading.equalTo(subView.snp.leading)
            $0.trailing.equalTo(subView.snp.trailing)
            $0.bottom.equalTo(subView.snp.bottom)
        }
        
        contentFooterView.addSubview(footerLabel)
        
        footerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func checkLanguage(_ languageCode: String, _ type: PopupType) -> String {
        if type == .comeHearTerms {
            switch languageCode {
            case "ko":
                return ContentString.terms.ko.rawValue
            default:
                return ContentString.terms.en.rawValue
            }
        } else if type == .comeHearPrivacy {
            switch languageCode {
            case "ko":
                return ContentString.privacy.ko.rawValue
            default:
                return ContentString.privacy.en.rawValue
            }
        } else {
            return ""
        }
    }
    
    // MARK: - 함수_objc
    @objc func tapClose() {
        dismiss(animated: true)
    }
    
    @objc func tapAgree() {
        switch type {
        case .comeHearTerms:
            delegate?.recieveTermsAgreeData()
            dismiss(animated: false) {
                self.showToVoice(type: .screenChanged, text: "이용약관에 동의하셨습니다. 이용약관 화면을 닫겠습니다.")
            }
        case .comeHearPrivacy:
            delegate?.recievePrivacyAgreeData()
            dismiss(animated: false) {
                self.showToVoice(type: .screenChanged, text: "개인정보처리방침에 동의하셨습니다. 개인정보처리방침 화면을 닫겠습니다.")
            }
        case .tourApiTerms:
            dismiss(animated: false)
        case .none:
            break
        }
    }
}

