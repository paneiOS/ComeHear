//
//  FeelReportViewController.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import UIKit
import Alamofire

final class FeelReportViewController: UIViewController {
    // MARK: - 변수, 상수
    private var reportText: String = ""
    private var etcViewBool = false
    private let selectFeel: FeelListData
    private var reportType: ReportType = .none {
        didSet{
            switch reportType {
            case .abuseType:
                reportText = "욕설, 명예훼손".localized()
                abuseButton.setImage(systemName: "checkmark.circle.fill", pointSize: 27)
                abuseButton.tintColor = checkButtonColor
                [pornoButton, unsuitableButton, etcButton].forEach {
                    $0.setImage(systemName: "checkmark.circle", pointSize: 25)
                    $0.tintColor = .black
                }
            case .pornoType:
                reportText = "음란물".localized()
                pornoButton.setImage(systemName: "checkmark.circle.fill", pointSize: 27)
                pornoButton.tintColor = checkButtonColor
                [abuseButton, unsuitableButton, etcButton].forEach {
                    $0.setImage(systemName: "checkmark.circle", pointSize: 25)
                    $0.tintColor = .black
                }
            case .unsuitableType:
                reportText = "내용 부적합".localized()
                unsuitableButton.setImage(systemName: "checkmark.circle.fill", pointSize: 27)
                unsuitableButton.tintColor = checkButtonColor
                [abuseButton, pornoButton, etcButton].forEach {
                    $0.setImage(systemName: "checkmark.circle", pointSize: 25)
                    $0.tintColor = .black
                }
            case .etcType:
                reportText = ""
                etcButton.setImage(systemName: "checkmark.circle.fill", pointSize: 27)
                etcButton.tintColor = checkButtonColor
                [abuseButton, unsuitableButton, pornoButton].forEach {
                    $0.setImage(systemName: "checkmark.circle", pointSize: 25)
                    $0.tintColor = .black
                }
            case .none:
                [abuseButton, pornoButton, unsuitableButton, etcButton].forEach {
                    $0.setImage(systemName: "checkmark.circle.fill", pointSize: 27)
                    $0.tintColor = checkButtonColor
                }
            }
        }
    }
    
    private var reportCode: String {
        get {
            switch reportType {
            case .abuseType:
                return "BAD"
            case .pornoType:
                return "ADULT"
            case .unsuitableType:
                return "CONFUSE"
            case .etcType:
                return "ETC"
            case .none:
                return ""
            }
        }
    }
    
    // MARK: - 신고 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.setupSubViewHeader(color: personalColor)
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "신고 사유를 선택해주세요.".localized()
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .white
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        return button
    }()
    
    private lazy var selectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .lightGray
        label.text = "신고할 느낌".localized() + " - " + selectFeel.title
        label.accessibilityLabel = "신고느낌제목".localized(with: selectFeel.title)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 1.0
        [
            abuseView,
            pornoView,
            unsuitableView,
            etcView,
            reportReasonView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var abuseView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabAbuseView))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "욕설, 명예훼손".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var abuseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.text = "욕설, 명예훼손".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var abuseButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "checkmark.circle", pointSize: 25)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tabAbuseView), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var pornoView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabPornoView))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "음란물".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var pornoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.text = "음란물".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var pornoButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "checkmark.circle", pointSize: 25)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tabPornoView), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var unsuitableView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabUnsuitableView))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "내용 부적합".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var unsuitableLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.text = "내용 부적합".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var unsuitableButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "checkmark.circle", pointSize: 25)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tabUnsuitableView), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var etcView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabEtcView))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isAccessibilityElement = true
        view.accessibilityLabel = "기타".localized()
        view.accessibilityTraits = .button
        return view
    }()
    
    private lazy var etcLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.text = "기타".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var etcButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "checkmark.circle", pointSize: 25)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tabEtcView), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var reportReasonView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.isAccessibilityElement = false
        return view
    }()
    
    private lazy var reportReasonSubView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 12.0
        view.isAccessibilityElement = false
        return view
    }()
    
    private lazy var reportReasonTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = moreLightGrayColor
        textView.delegate = self
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setupLongButton(title: "신고하기".localized(), fontSize: 16)
        button.addTarget(self, action: #selector(tapSendButton), for: .touchUpInside)
        return button
    }()
    
    init(selectFeel: FeelListData) {
        self.selectFeel = selectFeel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        setAddBorder()
        showToVoice(type: .screenChanged, text: "현재화면은 신고하기 화면입니다.")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
}

//MARK: - Extension
extension FeelReportViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupLayout() {
        [mainContentView, subContentView].forEach {
            view.addSubview($0)
        }
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        subContentView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize * 2)
            $0.trailing.equalToSuperview().inset(intervalSize * 2)
        }
        
        [placeholderView, selectLabel, stackView, sendButton].forEach {
            subContentView.addSubview($0)
        }
        
        [abuseLabel, abuseButton].forEach {
            abuseView.addSubview($0)
        }
        
        [pornoLabel, pornoButton].forEach {
            pornoView.addSubview($0)
        }
        
        [unsuitableLabel, unsuitableButton].forEach {
            unsuitableView.addSubview($0)
        }
        
        [etcLabel, etcButton].forEach {
            etcView.addSubview($0)
        }
        
        reportReasonView.addSubview(reportReasonSubView)
        
        reportReasonSubView.addSubview(reportReasonTextView)
        
        [placeholderLabel, closeButton].forEach {
            placeholderView.addSubview($0)
        }
        
        placeholderView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(placeholderLabel.snp.trailing).offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize/2)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(closeButton.snp.height)
        }
        
        selectLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(selectLabel.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        abuseView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        abuseLabel.snp.makeConstraints {
            $0.top.equalTo(abuseView.snp.top)
            $0.bottom.equalTo(abuseView.snp.bottom)
            $0.leading.equalTo(abuseView.snp.leading)
        }
        
        abuseButton.snp.makeConstraints {
            $0.top.equalTo(abuseView.snp.top)
            $0.bottom.equalTo(abuseView.snp.bottom)
            $0.trailing.equalTo(abuseView.snp.trailing)
        }
        
        pornoView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        pornoLabel.snp.makeConstraints {
            $0.top.equalTo(pornoView.snp.top)
            $0.bottom.equalTo(pornoView.snp.bottom)
            $0.leading.equalTo(pornoView.snp.leading)
        }
        
        pornoButton.snp.makeConstraints {
            $0.top.equalTo(pornoView.snp.top)
            $0.bottom.equalTo(pornoView.snp.bottom)
            $0.trailing.equalTo(pornoView.snp.trailing)
        }
        
        unsuitableView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        unsuitableLabel.snp.makeConstraints {
            $0.top.equalTo(unsuitableView.snp.top)
            $0.bottom.equalTo(unsuitableView.snp.bottom)
            $0.leading.equalTo(unsuitableView.snp.leading)
        }
        
        unsuitableButton.snp.makeConstraints {
            $0.top.equalTo(unsuitableView.snp.top)
            $0.bottom.equalTo(unsuitableView.snp.bottom)
            $0.trailing.equalTo(unsuitableView.snp.trailing)
        }
        
        etcView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        etcLabel.snp.makeConstraints {
            $0.top.equalTo(etcView.snp.top)
            $0.bottom.equalTo(etcView.snp.bottom)
            $0.leading.equalTo(etcView.snp.leading)
        }
        
        etcButton.snp.makeConstraints {
            $0.top.equalTo(etcView.snp.top)
            $0.bottom.equalTo(etcView.snp.bottom)
            $0.trailing.equalTo(etcView.snp.trailing)
        }
        
        reportReasonView.snp.makeConstraints {
            $0.height.equalTo(frameSizeWidth * 3 / 5)
        }
        
        reportReasonSubView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        reportReasonTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
        }
        
        sendButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40)
        }
    }
    
    private func setAddBorder() {
        abuseView.layer.addBorder([.bottom], color: .lightGray, width: 0.5)
        pornoView.layer.addBorder([.bottom], color: .lightGray, width: 0.5)
        unsuitableView.layer.addBorder([.bottom], color: .lightGray, width: 0.5)
        etcView.layer.addBorder([.bottom], color: .lightGray, width: 0.5)
    }
    
    private func textViewSetupView() {
        if reportReasonTextView.text == "" {
            reportText = reportReasonTextView.text
            reportReasonTextView.text = "신고 사유를 입력해주세요.".localized()
            reportReasonTextView.textColor = .lightGray
        } else if reportReasonTextView.text == "신고 사유를 입력해주세요.".localized() {
            reportReasonTextView.text = ""
            reportText = reportReasonTextView.text
            reportReasonTextView.textColor = .black
        } else {
            reportText = reportReasonTextView.text
            reportReasonTextView.textColor = .black
        }
    }
    
    private func etcViewCheck(_ bool: Bool) {
        if bool {
            reportReasonView.isHidden = bool
            etcViewBool = !bool
        } else {
            reportReasonView.isHidden = bool
            etcViewBool = !bool
        }
    }
    
    // MARK: - objc 함수
    @objc private func tabAbuseView() {
        reportType = .abuseType
        etcViewCheck(true)
        self.view.endEditing(true)
    }
    
    @objc private func tabPornoView() {
        reportType = .pornoType
        etcViewCheck(true)
        self.view.endEditing(true)
    }
    
    @objc private func tabUnsuitableView() {
        reportType = .unsuitableType
        etcViewCheck(true)
        self.view.endEditing(true)
    }
    
    @objc private func tabEtcView() {
        reportType = .etcType
        etcViewCheck(false)
        reportReasonTextView.text = "신고 사유를 입력해주세요.".localized()
        reportReasonTextView.textColor = .lightGray
        self.view.endEditing(true)
    }
    
    @objc func tapClose() {
        dismiss(animated: true)
    }
    
    // MARK: - Request API
    @objc private func tapSendButton() {
        guard reportType != .none else { return showConfirmAlert("신고 사유를 선택해주세요.", "알림") }
        guard reportText != "", reportText != "신고 사유를 입력해주세요.".localized() else { return showConfirmAlert("신고 사유를 입력해주세요.", "알림") }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let memberIdx = app.userMemberIdx else { return }
        
        var request = URLRequest(url: URL(string: feelReportURL + "/\(memberIdx)")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params = [
            "regMemberIdx": selectFeel.regMemberIdx ?? 0,
            "reportReason": reportText,
            "stid": selectFeel.stid,
            "stlid": selectFeel.stlid,
            "title": selectFeel.title,
            "reportCode" : reportCode
        ] as [String : Any]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
#if DEBUG
            print("http Body Error")
#endif
        }
        LoadingIndicator.showLoading(className: self.className, function: "tapSendButton")
        AF.request(request).responseDecodable(of: BasicResponseModel.self) { [weak self] (response) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                if data.status == 200 {
                    self.dismiss(animated: true) {
                        guard let topViewController = keyWindow?.visibleViewController else { return }
                        topViewController.showToast(message: "신고가 접수되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        NotificationCenter.default.post(name: Notification.Name("reportAfterReload"), object: nil)
                        self.showToVoice(type: .announcement, text: "신고가 접수되었습니다. 현재화면을 닫겠습니다.")
                    }
                } else if data.status == 403 {
                    self.dismiss(animated: true) {
                        guard let topViewController = keyWindow?.visibleViewController else { return }
                        topViewController.showToast(message: "이미 신고하신 게시물입니다.\n관리자가 확인 후, 재개시 되었습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                        self.showToVoice(type: .announcement, text: "이미 신고하신 게시물입니다. 관리자가 확인 후, 재게시되었습니다. 현재화면을 닫겠습니다.")
                    }
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

extension FeelReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView()
        } else {
            reportText = textView.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView()
        } else {
            reportText = textView.text
        }
    }
}
