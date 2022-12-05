//
//  FeelPlayViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/03.
//

import UIKit
import AVFoundation
import Kingfisher
import SwiftUI

final class FeelPlayViewController: UIViewController {
    private let constantSize = ConstantSize()
    
    //MARK: - 변수, 상수
    var audioURL = ""
    var script = ""
    var defaultImageUrl = ""
    var selectFeel: FeelListData?
    var normalRate: Float = 0.4
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer!
    private let audioSession = AVAudioSession.sharedInstance()
    private let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    private var timer: DispatchSourceTimer?
    private var currentSeconds: Double = 0.0
    private var minFadeDuration: Double = 0.0
    
    private var isPlayRate: PlayRate = .normal {
        didSet {
            switch isPlayRate {
            case .slow :
                if audioURL == "" {
                    normalRate = 0.4 * 0.8
                    tapBasicReplay()
                } else {
                    audioPlayer.rate = 0.8
                    tapURLReplay()
                }
                slowSpeedButton.backgroundColor = ContentColor.checkButtonColor.getColor()
                normalSpeedButton.backgroundColor = .white
                fastSpeedButton.backgroundColor = .white
                moreFastSpeedButton.backgroundColor = .white
            case .normal :
                if audioURL == "" {
                    normalRate = 0.4
                    tapBasicReplay()
                } else {
                    audioPlayer.rate = 1.0
                    tapURLReplay()
                }
                slowSpeedButton.backgroundColor = .white
                normalSpeedButton.backgroundColor = ContentColor.checkButtonColor.getColor()
                fastSpeedButton.backgroundColor = .white
                moreFastSpeedButton.backgroundColor = .white
            case .fast :
                if audioURL == "" {
                    normalRate = 0.4 * 1.5
                    tapBasicReplay()
                } else {
                    audioPlayer.rate = 1.5
                    tapURLReplay()
                }
                slowSpeedButton.backgroundColor = .white
                normalSpeedButton.backgroundColor = .white
                fastSpeedButton.backgroundColor = ContentColor.checkButtonColor.getColor()
                moreFastSpeedButton.backgroundColor = .white
            case .moreFast :
                if audioURL == "" {
                    normalRate = 0.4 * 2.0
                    tapBasicReplay()
                } else {
                    audioPlayer.rate = 2.0
                    tapURLReplay()
                }
                slowSpeedButton.backgroundColor = .white
                normalSpeedButton.backgroundColor = .white
                fastSpeedButton.backgroundColor = .white
                moreFastSpeedButton.backgroundColor = ContentColor.checkButtonColor.getColor()
            }
        }
    }
    
    private var isPlay: PlayState = .stop {
        didSet {
            switch isPlay {
            case .play:
                playButton.setImage(systemName: "pause.fill", pointSize: 35)
                play()
            case .pause:
                playButton.setImage(systemName: "play.fill", pointSize: 35)
                pause()
            case .stop:
                playButton.setImage(systemName: "play.fill", pointSize: 35)
                stop()
            case .resume:
                playButton.setImage(systemName: "pause.fill", pointSize: 35)
                resume()
            }
        }
    }
    
    //MARK: - 재생 UI
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private lazy var subContentView: UIView = {
        let view = UIView()
        view.setupShadow(color: ContentColor.moreLightGrayColor.getColor())
        return view
    }()
    
    private lazy var subView: UIView = {
        let view = UIView()
        view.setupShadow(color: ContentColor.personalColor.getColor(), cornerRadius: 15)
        return view
    }()
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "재생화면".localized()
        return label
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
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.borderColor = ContentColor.personalColor.getColor().cgColor
        if defaultImageUrl == "" {
            imageView.image = ContentImage.landScapeImage.getImage()
        } else {
            imageView.setImage(with: defaultImageUrl, placeholder: ContentImage.landScapeImage.getImage(), cornerRadius: 15)
        }
        return imageView
    }()
    
    lazy var writer: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .darkGray
        label.text = "홍길동"
        return label
    }()
    
    lazy var feelTitleView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .darkGray
        label.text = "홍길동"
        return label
    }()
    
    private lazy var speedControllerStackView: UIStackView = {
        let stackView = UIStackView()
        if UIAccessibility.isVoiceOverRunning {
            stackView.isHidden = true
        }
        stackView.setupShadow(color: ContentColor.personalColor.getColor())
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        [
            speedPlaceHolderView,
            slowSpeedButtonView,
            normalSpeedButtonView,
            fastSpeedButtonView,
            moreFastSpeedButtonView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var speedPlaceHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var speedPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .darkGray
        label.text = "  " + "배속".localized()
        label.textAlignment = .center
        label.accessibilityElementsHidden = true
        return label
    }()
    
    private lazy var slowSpeedButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var slowSpeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("0.8", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10.0, weight: .bold)
        button.setupShadow(cornerRadius: 15)
        button.addTarget(self, action: #selector(tapSlowButton), for: .touchUpInside)
        button.accessibilityLabel = "0.8 " + "배속".localized()
        return button
    }()
    
    private lazy var normalSpeedButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var normalSpeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("1.0", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10.0, weight: .bold)
        button.setupShadow(color: ContentColor.checkButtonColor.getColor(), cornerRadius: 15)
        button.addTarget(self, action: #selector(tapNormalButton), for: .touchUpInside)
        button.accessibilityLabel = "1.0 " + "배속".localized()
        return button
    }()
    
    private lazy var fastSpeedButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var fastSpeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("1.5", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10.0, weight: .bold)
        button.setupShadow(cornerRadius: 15)
        button.addTarget(self, action: #selector(tapFastButton), for: .touchUpInside)
        button.accessibilityLabel = "1.5 " + "배속".localized()
        return button
    }()
    
    private lazy var moreFastSpeedButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var moreFastSpeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("2.0", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10.0, weight: .bold)
        button.setupShadow(cornerRadius: 15)
        button.addTarget(self, action: #selector(tapMoreFastButton), for: .touchUpInside)
        button.accessibilityLabel = "2.0 " + "배속".localized()
        return button
    }()
    
    private lazy var playControllerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.setupShadow(color: ContentColor.personalColor.getColor())
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.shouldGroupAccessibilityChildren = true
        [
            replayButtonView,
            playButtonView,
            stopButtonView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        return stackView
    }()
    
    private lazy var replayButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var replayButton: UIButton = {
        let button = UIButton()
        if UIAccessibility.isVoiceOverRunning {
            button.isHidden = true
        }
        button.setImage(systemName: "goforward", pointSize: 20, weight: .bold)
        button.tintColor = .black
        button.setupShadow(cornerRadius: 20)
        button.addTarget(self, action: audioURL == "" ? #selector(tapBasicReplay) : #selector(tapURLReplay), for: .touchUpInside)
        button.accessibilityLabel = "다시재생하기".localized()
        return button
    }()
    
    private lazy var playButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "play.fill", pointSize: 35)
        button.tintColor = .black
        button.setupShadow(cornerRadius: 30)
        button.addTarget(self, action: audioURL == "" ? #selector(tapBasicPlay) : #selector(tapPlay), for: .touchUpInside)
        button.accessibilityLabel = "재생하기".localized()
        return button
    }()
    
    private lazy var stopButtonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "stop.fill", pointSize: 20)
        button.tintColor = .black
        button.setupShadow(cornerRadius: 20)
        button.addTarget(self, action: audioURL == "" ? #selector(tapBasicStop) : #selector(tapStop), for: .touchUpInside)
        button.accessibilityLabel = "정지하기".localized()
        return button
    }()
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기".localized() + "  ", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(systemName: "info.circle", pointSize: 20)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.setupShadow(color: ContentColor.personalColor.getColor(), cornerRadius: 12)
        button.addTarget(self, action: #selector(feelListReportTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        synthesizer.delegate = self
        
        DispatchQueue.main.async {
            LoadingIndicator.hideLoading()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !UIAccessibility.isVoiceOverRunning {
            audioURL == "" ? tapBasicPlay() : tapPlay()
        }
        showToVoice(type: .screenChanged, text: "현재화면은 재생화면입니다.")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

//MARK: - Extension
extension FeelPlayViewController {
    
    
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
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
        }
        
        [
            titleView, closeView,
            feelTitleView, writer,
            subView,
            sendMessageButton, speedControllerStackView,
            playControllerStackView
        ].forEach {
            subContentView.addSubview($0)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        closeView.addSubview(closeButton)
        
        closeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(constantSize.intervalSize/2)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize/2)
            $0.height.width.equalTo(50)
        }
        
        feelTitleView.snp.makeConstraints {
            $0.leading.equalTo(subView.snp.leading).offset(3)
            $0.bottom.equalTo(subView.snp.top).offset(-3)
            $0.height.equalTo(40)
        }
        
        writer.snp.makeConstraints {
            $0.trailing.equalTo(subView.snp.trailing).offset(3)
            $0.bottom.equalTo(subView.snp.top).offset(-3)
            $0.height.equalTo(40)
        }
        
        closeButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        subView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(subView.snp.width)
        }
        
        subView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        sendMessageButton.snp.makeConstraints {
            $0.centerY.equalTo(speedControllerStackView.snp.centerY)
            $0.leading.equalTo(subView.snp.leading)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        
        speedControllerStackView.snp.makeConstraints {
            $0.top.equalTo(subView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalTo(sendMessageButton.snp.trailing).offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(40)
        }
        
        speedPlaceHolderView.addSubview(speedPlaceHolderLabel)
        
        speedPlaceHolderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
//            $0.width.height.equalTo(30)
        }

        slowSpeedButtonView.addSubview(slowSpeedButton)
        
        slowSpeedButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        normalSpeedButtonView.addSubview(normalSpeedButton)
        
        normalSpeedButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        fastSpeedButtonView.addSubview(fastSpeedButton)
        
        fastSpeedButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        moreFastSpeedButtonView.addSubview(moreFastSpeedButton)
        
        moreFastSpeedButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        playControllerStackView.snp.makeConstraints {
            $0.top.equalTo(speedControllerStackView.snp.bottom).offset(constantSize.intervalSize)
            $0.leading.equalToSuperview().offset(constantSize.intervalSize)
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize)
            $0.height.equalTo(80)
        }
        
        replayButtonView.addSubview(replayButton)
        
        replayButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        playButtonView.addSubview(playButton)
        
        playButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        stopButtonView.addSubview(stopButton)

        stopButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
    }
    
    private func getDataFrom(url: String) -> Data? {
        var data: Data?
        if let url = URL(string: url) {
            do {
                data = try Data(contentsOf: url)
            } catch {
#if DEBUG
                print("Failed to get data from url. error = \(error.localizedDescription)")
#endif
            }
            return data
        } else {
            return nil
        }
    }
    
    private func play() {
        audioPlayer?.play()
        startTime()
        audioPlayer.setVolume(1, fadeDuration: minFadeDuration)
    }

    private func pause() {
        audioPlayer?.pause()
        pauseTime()
    }
    
    private func resume() {
        audioPlayer?.play()
        resumeTime()
    }
    
    private func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.volume = 0
        stopTime()
    }
    
    func setupAVAudioPlayer() {
        
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
#if DEBUG
            print("audioSession error: \(error.localizedDescription)")
#endif
        }
        
        if audioURL != "" {
            let audioData = getDataFrom(url: audioURL)
            audioPlayer = try? AVAudioPlayer(data: audioData!)
            audioPlayer.enableRate = true
            audioPlayer.volume = 0
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            currentSeconds = audioPlayer.duration * 1000
            minFadeDuration = min(self.audioPlayer.duration/2, 3)
        }
    }
    
    private func startTime() {
        if audioPlayer.duration > 4 {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: .milliseconds(1))
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                if self.currentSeconds <= self.minFadeDuration * 1000 {
                    self.audioPlayer.setVolume(0, fadeDuration: self.minFadeDuration)
                    self.stopTime()
                }
            })
            self.timer?.resume()
        }
    }
    
    private func pauseTime() {
        timer?.suspend()
    }
    
    private func resumeTime() {
        timer?.resume()
    }
    
    private func stopTime() {
        self.timer?.cancel()
        currentSeconds = audioPlayer.duration * 1000
    }
    
    // MARK: - objc 함수
    @objc private func tapClose() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        if isPlay == .pause {
            timer?.resume()
        }
        
        if isPlay != .stop {
            stop()
        }
        
        dismiss(animated: true)
    }
    
    @objc private func tapBasicPlay() {
        if synthesizer.isSpeaking {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
            } else {
                synthesizer.pauseSpeaking(at: .immediate)
            }
        } else {
            let utterance = AVSpeechUtterance(string: script)
            guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
            let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
            utterance.voice = AVSpeechSynthesisVoice(language: "\(languageCode)-KR")
            utterance.rate = normalRate
            utterance.pitchMultiplier = 1.0
            synthesizer.speak(utterance)
        }
    }
    
    @objc private func tapBasicStop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    @objc private func tapBasicReplay() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: script)
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        utterance.voice = AVSpeechSynthesisVoice(language: "\(languageCode)-KR")
        utterance.rate = normalRate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
    
    @objc private func tapPlay() {
        if isPlay == .stop {
            isPlay = .play
        } else if isPlay == .pause {
            isPlay = .resume
        } else {
            isPlay = .pause
        }
    }
    
    @objc private func tapStop() {
        if isPlay != .stop {
            isPlay = .stop
        }
    }
    
    @objc private func tapURLReplay() {
        if isPlay != .stop {
            isPlay = .stop
        }
        isPlay = .play
    }
    
    @objc private func feelListReportTapped() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let feel = self.selectFeel else { return }
        if app.loginState == .logout {
            let loginAction = UIAlertAction(title: "네".localized(), style: UIAlertAction.Style.default) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true) {
                    let loginViewContrller = LoginViewController()
                    guard let topViewController = keyWindow?.visibleViewController else { return }
                    topViewController.navigationController?.pushViewController(loginViewContrller, animated: true)
                }
            }
            showTwoButtonAlert(type: .requestLogin, loginAction)
        } else {
            dismiss(animated: true) {
                guard let topViewController = keyWindow?.visibleViewController else { return }
                let feelReportViewController = FeelReportViewController(selectFeel: feel)
                feelReportViewController.hero.isEnabled = true
                feelReportViewController.hero.modalAnimationType = .fade
                feelReportViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
                topViewController.present(feelReportViewController, animated: true)
            }
        }
    }
    
    @objc func tapSlowButton() {
        if isPlayRate != .slow {
            isPlayRate = .slow
        }
    }
    
    @objc func tapNormalButton() {
        if isPlayRate != .normal {
            isPlayRate = .normal
        }
    }
    
    @objc func tapFastButton() {
        if isPlayRate != .fast {
            isPlayRate = .fast
        }
    }
    
    @objc func tapMoreFastButton() {
        if isPlayRate != .moreFast {
            isPlayRate = .moreFast
        }
    }
}

//MARK: - AVAudioPlayerDelegate
extension FeelPlayViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlay = .stop
      }
}

//MARK: - AVSpeechSynthesizerDelegate
extension FeelPlayViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playButton.setImage(systemName: "play.fill", pointSize: 35)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        playButton.setImage(systemName: "play.fill", pointSize: 35)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        playButton.setImage(systemName: "pause.fill", pointSize: 35)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        playButton.setImage(systemName: "pause.fill", pointSize: 35)
    }
}
