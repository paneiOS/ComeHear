//
//  NoticeViewController.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import UIKit

class NoticeViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    // MARK: - 변수, 상수
    private var noticeList: [NoticeData]
    private var noticeBoolList: [Bool]
    
    //MARK: - 공지사항 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ContentColor.personalColor.getColor()
        return view
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 12
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(NoticeSectionTableViewCell.self, forCellReuseIdentifier: "NoticeSectionTableViewCell")
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewCell")
        
        return tableView
    }()
    
    init(noticeList: [NoticeData]) {
        self.noticeList = noticeList
        self.noticeBoolList = Array(repeating: false, count: noticeList.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        showToVoice(type: .screenChanged, text: "현재화면은 공지사항화면입니다.")
    }
}

//MARK: - Extension
extension NoticeViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupNavigation() {
        navigationItem.title = "공지사항".localized()
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
        
        view.backgroundColor = .white
        mainContentView.addSubview(subContentView)
        
        subContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        subContentView.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//MARK: - TableView Delegate
extension NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return noticeList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let bool = noticeBoolList[section]
        if bool {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeSectionTableViewCell", for: indexPath) as? NoticeSectionTableViewCell else { return UITableViewCell() }
            let notice = noticeList[indexPath.section]
            let bool = noticeBoolList[indexPath.section]
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.titleLabel.text = notice.title
            
            cell.subTitleLabel.text = String(notice.regDt.components(separatedBy: "T")[0])
            if bool {
                cell.openButton.tintColor = UIColor(rgb: 0xFEDD84)
                cell.openButton.setImage(systemName: "minus.circle", pointSize: constantSize.buttonSize)
                cell.accessibilityLabel = "제목 \(noticeList[indexPath.section].title), 등록일 \(cell.subTitleLabel.text ?? "") 펼치기 버튼"
            } else {
                cell.openButton.tintColor = UIColor(rgb: 0x888888)
                cell.openButton.setImage(systemName: "plus.circle", pointSize: constantSize.buttonSize)
                cell.accessibilityLabel = "제목 \(noticeList[indexPath.section].title) 접기 버튼"
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as? NoticeTableViewCell else { return UITableViewCell() }
            let notice = noticeList[indexPath.section]
            let bool = noticeBoolList[indexPath.section]
            cell.selectionStyle = .none
            cell.setupLayout()
            cell.contentLabel.text = notice.content
            if bool {
                cell.contentLabel.isHidden = false
            } else {
                cell.contentLabel.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if noticeBoolList[indexPath.section] {
                showToVoice2(type: .announcement, text: "공지사항접기".localized(with: noticeList[indexPath.section].title))
            } else {
                showToVoice2(type: .announcement, text: "공지사항펴기".localized(with: noticeList[indexPath.section].title))
            }
            noticeBoolList[indexPath.section] = !noticeBoolList[indexPath.section]
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
}
