//
//  RecentSearchView.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/07.
//

import UIKit
import Alamofire

class RecentSearchView: UIView {
    var delegate: SendDataDelegate?
    var historyIdx: Int?
    
    private lazy var recentSearchKeywordView: UIView = {
        let view = UIView()
        view.layer.borderColor = personalColor?.cgColor
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 0.5
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSearchKeyword))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.shouldGroupAccessibilityChildren = true
        return view
    }()
    
    lazy var keywordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = personalColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "multiply", pointSize: 15)
        button.titleLabel?.textAlignment = .right
        button.tintColor = personalColor
        button.addTarget(self, action: #selector(deleteStackView(sender:)), for: .touchUpInside)
        button.accessibilityLabel = "최근검색어 \(keywordLabel.text ?? "") 키워드 삭제하기"
        return button
    }()
    
    init(frame: CGRect, text: String, historyIdx: Int) {
        super.init(frame: frame)
        keywordLabel.text = text
        keywordLabel.accessibilityLabel = "최근검색어 \(text) 검색하기"
        self.historyIdx = historyIdx
        tag = historyIdx
        addSubview(recentSearchKeywordView)
        
        recentSearchKeywordView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/2)
            $0.leading.equalToSuperview().offset(intervalSize/2)
            $0.trailing.equalToSuperview().inset(intervalSize/2)
            $0.bottom.equalToSuperview().inset(intervalSize/2)
        }
        
        [keywordLabel, deleteButton].forEach {
            recentSearchKeywordView.addSubview($0)
        }
        
        keywordLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/3)
            $0.leading.equalToSuperview().offset(intervalSize/2)
            $0.bottom.equalToSuperview().inset(intervalSize/3)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/3)
            $0.leading.equalTo(keywordLabel.snp.trailing).offset(intervalSize/2)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(intervalSize/3)
            $0.width.equalTo(deleteButton.snp.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapSearchKeyword() {
        delegate?.recieveData(response: keywordLabel.text ?? "")
    }
    
    @objc func deleteStackView(sender: UIButton) {
        // 클릭 했을 때 버튼의 슈퍼뷰, 즉 버튼이 속해있는 stack view를 가지고 온다
        guard let entryView = sender.superview else { return }
        guard let historyIdx = historyIdx else { return }
        LoadingIndicator.showLoading(className: "RecentSearchView", function: "deleteStackView")
        guard let topViewController = keyWindow?.visibleViewController else { return }
        topViewController.showToVoice(type: .announcement, text: "최근검색어삭제".localized(with: keywordLabel.text ?? ""))
        entryView.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name("recentCount"), object: historyIdx)
        var request = URLRequest(url: URL(string: deleteSearchHistoryURL + "/\(historyIdx)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        AF.request(request).responseDecodable(of: BasicResponseModel.self) { _ in
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
            }
        }
    }
}
