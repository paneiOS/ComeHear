//
//  BGMSelectTableViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/08/31.
//

import UIKit
import AVFoundation

final class BGMSelectTableViewController: UIViewController {
    // MARK: - 변수, 상수
    var delegate: SendDataDelegate?
        private var audioPlayer: AVAudioPlayer?
    
    private var isPlay: PlayState = .stop {
        didSet {
            switch isPlay {
            case .play:
#if DEBUG
                print("플레이중입니다.")
#endif
            case .pause:
#if DEBUG
                print("일시정지입니다.")
#endif
            case .stop:
#if DEBUG
                print("정지입니다.")
#endif
            case .resume:
                return
            }
        }
    }
    
    // MARK: - 브금선택 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.hero.id = "BGMSelectTableViewController_MainContentView"
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "배경음악을 선택해주세요.".localized()
        label.accessibilityLabel = "배경음악을 선택해주세요. 닫기버튼을 누르면 선택된 배경음악으로 적용됩니다.".localized()
        label.layer.cornerRadius = 20
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 20
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(BGMSelectTableViewCell.self, forCellReuseIdentifier: "BGMSelectTableViewCell")
        return tableView
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        app.preventTap = false
    }
}

//MARK: - Extension
extension BGMSelectTableViewController {
    
    
    // MARK: - 기본 UI_SETUP
    private func setupLayout() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        view.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        [titleLabel, closeButton, tableView].forEach {
            mainContentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalTo(closeButton.snp.leading)
            $0.height.equalTo(50)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize/2)
            $0.width.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(intervalSize)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(40 * 11)
        }
    }
    
    private func play(index: Int) {
        let audioSession = AVAudioSession.sharedInstance()

        if isPlay == .play {
            audioPlayer?.pause()
        }
        
        do {
            try audioSession.setCategory(.playback)
        } catch {
#if DEBUG
            print("audioSession error: \(error.localizedDescription)")
#endif
        }
        let index = UserDefaults.standard.integer(forKey: "selectBgmIndex")
        audioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: bgmList[index], withExtension: "mp3")!)
        audioPlayer?.volume = audioSession.outputVolume
        audioPlayer?.delegate = self
        audioPlayer?.play()
        isPlay = .play
    }
    
    @objc func tapClose() {
        if isPlay == .play {
            audioPlayer?.pause()
        }
        print("isPlay", isPlay)
        closeButton.isHidden = true
        dismiss(animated: true)
    }
}

// MARK: - TableView Delegate
extension BGMSelectTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "selectBgmIndex")
        if !UIAccessibility.isVoiceOverRunning {
            tableView.reloadData()
        }
        play(index: indexPath.row)
        delegate?.recieveData(response: String(indexPath.row))
    }
}

// MARK: - TableView DataSource
extension BGMSelectTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bgmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BGMSelectTableViewCell", for: indexPath) as? BGMSelectTableViewCell else { return UITableViewCell() }
        cell.cellDelegate = self
        cell.selectionStyle = .none
        cell.titleLabel.text = bgmList[indexPath.row]
        cell.selectButton.tag = indexPath.row
        cell.selectButton.accessibilityLabel = "\(intToString(indexPath.row + 1))번 " + bgmList[indexPath.row] + "들어보기 및 선택하기"
        let index = UserDefaults.standard.integer(forKey: "selectBgmIndex")
        if indexPath.row == index {
            cell.selectButton.setImage(systemName: "chevron.down.circle.fill", pointSize: buttonSize)
        } else {
            cell.selectButton.setImage(systemName: "circle", pointSize: buttonSize)
        }
        return cell
    }
}

extension BGMSelectTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlay = .stop
    }
}

extension BGMSelectTableViewController: BGMSelectDelegate {
    func bgmSelectButtonTapped(_ tag: Int) {
        UserDefaults.standard.set(tag, forKey: "selectBgmIndex")
        if !UIAccessibility.isVoiceOverRunning {
            tableView.reloadData()
        }
        play(index: tag)
        delegate?.recieveData(response: String(tag))
    }
}
