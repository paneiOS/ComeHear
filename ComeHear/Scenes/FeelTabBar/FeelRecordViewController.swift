//
//  FeelRecordViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/03.
//

import UIKit
import AVFoundation
import Lottie
import Alamofire
import Speech

class FeelRecordViewController: UIViewController {
    // MARK: - 변수, 상수
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var timer: DispatchSourceTimer?
    private var currentSeconds = 30000
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var tempText = ""
    private var selectBgmIndex = UserDefaults.standard.integer(forKey: "selectBgmIndex") {
        didSet {
            bgmLabel.text = "배경음악".localized() + " : \(bgmList[selectBgmIndex])"
        }
    }
    var stid: String = ""
    var stlid: String = ""
    var storyDetail: StoryDetail?
    
    private var isRecord: RecordState = .noneRecord {
        didSet {
            switch isRecord {
            case .recording:
                animationView.play()
                sendButton.isEnabled = false
                startTime()
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.playButton.isEnabled = true
                    self.removeButton.isEnabled = true
                    let keypath = AnimationKeypath(keys: ["**", "Ellipse 1", "**", "Fill 1", "**", "Color"])
                    let colorProvider = ColorValueProvider(UIColor(rgb: 0xFF1030).lottieColorValue)
                    self.animationView.setValueProvider(colorProvider, keypath: keypath)
                    self.gradientLayer.colors = [
                        UIColor(rgb: 0xE6A6A6).cgColor,
                        UIColor.white.cgColor
                    ]
                }
            case .stopRecord:
                self.showToVoice(type: .announcement, text: "\(30 - (Int(self.secondLabel.text ?? "0")!))" + "초 녹음이 완료 되었습니다.".localized())
                stopTime()
                animationView.stop()
                sendButton.isEnabled = true
                sendButton.addTarget(self, action: #selector(uploadButton), for: .touchUpInside)
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self = self else { return }
                    let keypath = AnimationKeypath(keys: ["**", "Ellipse 1", "**", "Fill 1", "**", "Color"])
                    if Int(self.secondLabel.text ?? "30")! < 20 {
                        let colorProvider = ColorValueProvider(UIColor(rgb: 0x52CC99).lottieColorValue)
                        self.animationView.setValueProvider(colorProvider, keypath: keypath)
                        self.gradientLayer.colors = [
                            UIColor(rgb: 0xA6E6C3).cgColor,
                            UIColor.white.cgColor
                        ]
                    } else {
                        let colorProvider = ColorValueProvider(UIColor(rgb: 0xFFD564).lottieColorValue)
                        self.animationView.setValueProvider(colorProvider, keypath: keypath)
                        self.gradientLayer.colors = [
                            UIColor(rgb: 0xFFD564).cgColor,
                            UIColor.white.cgColor
                        ]
                    }
                }
            case .noneRecord:
                isPlay = .stop
                recordFileLabel.text = "녹음파일".localized()
                playButton.setImage(systemName: "play.circle.fill", pointSize: 30)
                playButton.accessibilityLabel = "들어보기".localized()
                secondLabel.text = "30"
                milliSecondLabel.text = "00"
                stopTime()
                sendButton.isEnabled = false
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.playButton.isEnabled = false
                    self.removeButton.isEnabled = false
                    let keypath = AnimationKeypath(keys: ["**", "Ellipse 1", "**", "Fill 1", "**", "Color"])
                    let colorProvider = ColorValueProvider(UIColor(rgb: 0xFFD564).lottieColorValue)
                    self.animationView.setValueProvider(colorProvider, keypath: keypath)
                    self.gradientLayer.colors = [
                        UIColor(rgb: 0xFFD564).cgColor,
                        UIColor.white.cgColor
                    ]
                }
                sendButton.removeTarget(self, action: #selector(uploadButton), for: .touchUpInside)
            }
        }
    }
    private var isPlay: PlayState = .stop {
        didSet {
            switch isPlay {
            case .play:
                if !UIAccessibility.isVoiceOverRunning {
                    playButton.setImage(systemName: "stop.circle.fill", pointSize: 30)
                    playButton.accessibilityLabel = "녹음한 파일 정지하기".localized()
                }
            case .pause:
                playButton.setImage(systemName: "play.circle.fill", pointSize: 30)
                playButton.accessibilityLabel = "녹음한 파일 재생하기".localized()
            case .stop:
                playButton.setImage(systemName: "play.circle.fill", pointSize: 30)
                playButton.accessibilityLabel = "녹음한 파일 재생하기".localized()
            case .resume:
                return
            }
        }
    }
    
    // MARK: - 녹음 UI
    private lazy var gradientLayer: CAGradientLayer! = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [
            UIColor(rgb: 0xFFECBA).cgColor,
            UIColor.white.cgColor
        ]
        return gradientLayer
    }()
    
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.layer.addSublayer(gradientLayer)
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "JSArirangHON-Regular", size: 32)
        label.textColor = .white
        label.text = "녹음하기네비타이틀".localized()
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark.circle", pointSize: 30)
        button.tintColor = .white
        button.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        button.accessibilityLabel = "닫기".localized()
        button.isHidden = true
        return button
    }()
    
    private lazy var lottieView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var animationView: AnimationView = {
        let lottiView = AnimationView(name: "recordButton")
        lottiView.frame = lottieView.bounds
        lottiView.contentMode = .scaleAspectFill
        lottiView.loopMode = .loop
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapShareButton))
        lottiView.addGestureRecognizer(tapGestureRecognizer)
        lottiView.isAccessibilityElement = true
        lottiView.accessibilityTraits = .button
        lottiView.accessibilityLabel = "녹음버튼입니다. 누르시면 바로 녹음이 시작됩니다.".localized()
        return lottiView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .red
        label.textAlignment = .center
        label.text = "녹음은 10초이상부터 등록가능합니다.".localized()
        label.accessibilityLabel = "녹음완료시간".localized(with: "0")
        return label
    }()
    
    private let recorderSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey: 320000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100.0
    ]
    
    lazy var shareTitle: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "mic.fill", pointSize: 30)
        button.semanticContentAttribute = .forceRightToLeft
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.isAccessibilityElement = false
        return button
    }()
    
    private lazy var secondLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "30"
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var separateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "."
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var milliSecondLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "00"
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var recordPlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.hero.id = "BGMSelectTableViewController_MainContentView"
        return view
    }()
    
    lazy var sendView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var recordFileLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.text = "녹음파일".localized()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "play.circle.fill", pointSize: 30)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .regular)
        button.titleLabel?.textAlignment = .left
        button.tintColor = .black
        button.addTarget(self, action: #selector(tapPlay), for: .touchUpInside)
        button.isEnabled = false
        button.accessibilityLabel = "녹음한 파일 재생하기".localized()
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "trash.circle.fill", pointSize: 30)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .regular)
        button.titleLabel?.textAlignment = .left
        button.tintColor = .black
        button.addTarget(self, action: #selector(recordRemove), for: .touchUpInside)
        button.isEnabled = false
        button.accessibilityLabel = "녹음한 파일 삭제하기".localized()
        return button
    }()
    
    private lazy var separateView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        return view
    }()
    
    lazy var bgmLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "배경음악".localized() + " - \(bgmList[selectBgmIndex])"
        label.isAccessibilityElement = true
        return label
    }()
    
    private lazy var bgmSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle("변경하기".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .semibold)
        button.layer.cornerRadius = 12
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .darkGray
        button.addTarget(self, action: #selector(tapSelectButton), for: .touchUpInside)
        return button
    }()
    
    lazy var titleTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = moreLightGrayColor
        view.layer.cornerRadius = 25
        view.hero.id = "FeelRecordViewController_Button"
        return view
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력해주세요.".localized()
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "paperplane.circle.fill", pointSize: 40)
        button.titleLabel?.font = .systemFont(ofSize: 24.0, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .black
        button.addTarget(self, action: #selector(uploadButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    //MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.hideLoading()
        setupLayout()
        setKeyboardObserver()
        setNotifications()
        speechRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeButton.isHidden = false
        showToVoice(type: .screenChanged, text: "현재화면은 녹음하기 화면입니다. 녹음은 최소 10초부터 최대 30초까지 등록가능합니다.")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        removeNotifications()
        disableAVSession()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupLayout() {
        view.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [
            titleView,
            shareTitle, lottieView, animationView, placeholderLabel,
            secondLabel, separateLabel, milliSecondLabel,
            recordPlayView, sendView
        ].forEach {
            mainContentView.addSubview($0)
        }
        
        [titleLabel, closeButton].forEach {
            titleView.addSubview($0)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.centerY.equalToSuperview()
        }
        
        shareTitle.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(intervalSize * 2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
        }
        
        lottieView.snp.makeConstraints {
            $0.top.equalTo(shareTitle.snp.bottom).offset(intervalSize)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(frameSizeWidth * 2 / 3)
        }
        
        animationView.snp.makeConstraints {
            $0.edges.equalTo(lottieView)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(lottieView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        separateLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderLabel.snp.bottom).offset(intervalSize)
            $0.centerX.equalToSuperview()
        }
        
        secondLabel.snp.makeConstraints {
            $0.centerY.equalTo(separateLabel.snp.centerY).offset(7)
            $0.trailing.equalTo(separateLabel.snp.leading).inset(-20)
        }
        
        milliSecondLabel.snp.makeConstraints {
            $0.centerY.equalTo(separateLabel.snp.centerY).offset(7)
            $0.leading.equalTo(separateLabel.snp.trailing).offset(20)
        }
        
        recordPlayView.snp.makeConstraints {
            $0.top.equalTo(secondLabel.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(100)
        }
        
        [
            recordFileLabel, playButton, removeButton,
            separateView,
            bgmLabel, bgmSelectButton
        ].forEach {
            recordPlayView.addSubview($0)
        }
        
        recordFileLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalTo(playButton.snp.leading).inset(intervalSize)
            $0.height.equalTo(50)
        }
        
        playButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(removeButton.snp.leading)
            $0.height.width.equalTo(50)
        }
        
        removeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.width.equalTo(50)
        }
        
        bgmLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        
        separateView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.height.equalTo(1)
        }
        
        bgmSelectButton.snp.makeConstraints {
            $0.centerY.equalTo(bgmLabel.snp.centerY)
            $0.leading.equalTo(playButton.snp.leading).offset(intervalSize/2)
            $0.trailing.equalTo(removeButton.snp.trailing).inset(intervalSize/2)
            $0.height.equalTo(25)
        }
        
        sendView.snp.makeConstraints {
            $0.top.equalTo(recordPlayView.snp.bottom).offset(intervalSize)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        sendView.addSubview(titleTextFieldView)
        
        titleTextFieldView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize + 18)
        }
        
        [
            titleTextField, sendButton
        ].forEach {
            titleTextFieldView.addSubview($0)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalTo(sendButton.snp.leading).inset(5)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        sendButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(sendButton.snp.height)
        }
    }
    
    private func recording() {
        tempText = ""
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myRecoding.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record)
        } catch {
#if DEBUG
            print("audioSession error: \(error.localizedDescription)")
#endif
        }
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            self.audioRecorder!.delegate = self
            self.audioRecorder!.record()
            isRecord = .recording
        } catch {
            isRecord = .stopRecord
        }
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            guard let self = self else { return }
            var isFinal = false
            
            if result != nil {
                self.tempText = result?.bestTranscription.formattedString ?? ""
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
#if DEBUG
            print("audioEngine couldn't start because of an error.")
#endif
        }
        DispatchQueue.main.async {
            LoadingIndicator.hideLoading()
        }
    }
    
    @objc private func stopRecord() {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            self.audioRecorder!.stop()
            isRecord = .stopRecord
            
            if !audioRecorder!.isRecording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setCategory(.playback)
                } catch {
#if DEBUG
                    print("audioSession error: \(error.localizedDescription)")
#endif
                }
            }
        }
    }
    
    private func play() {
        if !audioRecorder!.isRecording {
            let audioSession = AVAudioSession.sharedInstance()

            if isPlay == .play {
                return
            } else {
                isPlay = .play
            }
            
            do {
                try audioSession.setCategory(.playback)
            } catch {
#if DEBUG
                print("audioSession error: \(error.localizedDescription)")
#endif
            }
            
            audioPlayer = try? AVAudioPlayer(contentsOf: audioRecorder!.url)
            audioPlayer?.volume = audioSession.outputVolume
            audioPlayer?.delegate = self
            audioPlayer?.play()
        }
    }
    
    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
    
    private func stop() {
        if isPlay == .stop {
            return
        } else {
            isPlay = .stop
        }
        audioPlayer?.pause()
    }
    
    private func startTime() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: .milliseconds(1))
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let seconds = self.currentSeconds / 1000
                let milliSeconds = (self.currentSeconds % 1000) / 10
                self.secondLabel.text = String(format: "%02d", seconds)
                self.milliSecondLabel.text = String(format: "%02d", milliSeconds)
                self.recordFileLabel.text = "녹음시간 - ".localized() + String(format: "%02d", 29 - seconds) + "." + String(format: "%02d", (100 - milliSeconds) == 100 ? 00 : 100 - (milliSeconds)) + " 초".localized()
                self.placeholderLabel.accessibilityLabel = "녹음완료시간".localized(with: String(30 - (self.currentSeconds / 1000)))
                if self.currentSeconds <= 0 {
                    self.stopRecord()
                }
            })
            self.timer?.resume()
        }
    }
    
    private func stopTime() {
        self.timer?.cancel()
        self.timer = nil
        currentSeconds = 30000
    }
    
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addbackGroundTime(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecord), name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
    }
    
    func recordMerge(audio1: URL, audio2:  URL, completion: @escaping (Bool) -> Void) {
        let composition = AVMutableComposition()
        let compositionAudioTrack1:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let compositionAudioTrack2:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("resultmerge.m4a")

        let filemanager = FileManager.default
        if (!filemanager.fileExists(atPath: fileURL.path)) {
            do {
                try filemanager.removeItem(at: fileURL)
            } catch let error as NSError {
                NSLog("Error: \(error)")
            }
        } else {
            do {
                try filemanager.removeItem(at: fileURL)
            } catch let error as NSError {
                NSLog("Error: \(error)")
            }
        }

        let avAsset1 = AVURLAsset(url: audio1, options: nil)
        let avAsset2 = AVURLAsset(url: audio2, options: nil)

        let tracks1 = avAsset1.tracks(withMediaType: AVMediaType.audio)
        let tracks2 = avAsset2.tracks(withMediaType: AVMediaType.audio)

        let assetTrack1:AVAssetTrack = tracks1[0]
        let assetTrack2:AVAssetTrack = tracks2[0]

        let duration: CMTime = assetTrack1.timeRange.duration

        let timeRange1 = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        let timeRange2 = CMTimeRangeMake(start: CMTime.zero, duration: duration + CMTime(value: 2, timescale: 1))
        
        do {
            try compositionAudioTrack1.insertTimeRange(timeRange1, of: assetTrack1, at: CMTime(value: 1, timescale: 1))
            try compositionAudioTrack2.insertTimeRange(timeRange2, of: assetTrack2, at: CMTime.zero)
        }
        catch {
            #if DEBUG
            print(error)
            #endif
        }

        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.outputURL = fileURL
        assetExport?.exportAsynchronously(completionHandler:
                                            {
            switch assetExport!.status {
            case AVAssetExportSession.Status.failed:
                completion(false)
            case AVAssetExportSession.Status.cancelled:
                completion(false)
            case AVAssetExportSession.Status.unknown:
                completion(false)
            case AVAssetExportSession.Status.waiting:
                completion(false)
            case AVAssetExportSession.Status.exporting:
                completion(false)
            default:
                completion(true)
            }
        })
    }
    
    @objc func tapShareButton() {
        if isRecord == .recording {
            stopRecord()
        } else {
            LoadingIndicator.showLoading(className: self.className, function: "tapShareButton")
            recording()
        }
    }
    
    @objc func recordRemove() {
        guard let recoder = audioRecorder else { return }
        if isPlay == .play {
            stop()
        }
        
        if !recoder.isRecording {
            isRecord = .noneRecord
        } else {
            return
        }
    }
    
    @objc private func tapPlay() {
        guard let recoder = audioRecorder else { return }
        if !recoder.isRecording {
            if isPlay == .play {
                stop()
            } else {
                if !UIAccessibility.isVoiceOverRunning {
                    play()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.play()
                    }
                }
            }
        } else {
            return
        }
    }
    
    @objc private func uploadButton() {
        titleTextField.resignFirstResponder()
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let second = secondLabel.text, Int(second)! <= 20 else {
            return showConfirmAlert("10초이상 녹음해주세요.", "알림")
        }
        
        guard titleTextField.text != "" else {
            return showConfirmAlert("제목을 입력해주세요.", "알림")
        }
        guard titleTextField.text?.first != " " && titleTextField.text?.last != " " else {
            return showConfirmAlert("제목의 앞과 뒤에 공백을 제거해주세요.", "알림")
        }
        
        if app.languageCode == "ko" {
            guard titleTextField.text?.count ?? 0 <= 10 else {
                return showConfirmAlert("제목은 글자수 10자까지 가능합니다.", "알림")
            }
        }
        
        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        guard let title = titleTextField.text else { return }
        guard let storyDetail = storyDetail else { return }
        guard let userMemberIdx = app.userMemberIdx else { return }
        
        let parameters: [String : Any] = [
            "place": storyDetail.title,
            "regMemberIdx": String(userMemberIdx),
            "stid" : stid,
            "stlid" :stlid,
            "title" : title,
            "strScript" : tempText
        ]
        
        LoadingIndicator.showLoading(className: self.className, function: "uploadButton")
        
        let url1 = self.audioRecorder!.url
        let url2 = Bundle.main.url(forResource: bgmList[selectBgmIndex], withExtension: "mp3")!
        
        recordMerge(audio1: url1, audio2: url2) { bool in
            guard bool else { return }
            AF.upload(multipartFormData: { multipartFormData in
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("resultmerge.m4a")
                if let recordingData: Data = try? Data(contentsOf: fileURL) {
                    multipartFormData.append(recordingData, withName: "file", fileName: "myRecoding.m4a", mimeType: "audio/m4a")
                }
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: feelUploadURL, usingThreshold: UInt64.init(), method: .post, headers: header).responseDecodable(of: BasicResponseModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    if data.status == 201 {
                        self.dismiss(animated: true) {
                            guard let topViewController = keyWindow?.visibleViewController else { return }
                            self.isPlay = .stop
                            topViewController.showToast(message: "나의 느낌을 공유하였습니다.", font: .systemFont(ofSize: 16), vcBool: true)
                            NotificationCenter.default.post(name: Notification.Name("reportAfterReload"), object: nil)
                            DispatchQueue.main.async {
                                topViewController.showToVoice(type: .screenChanged, text: "나의 느낌을 공유하였습니다. 현재화면을 닫겠습니다.")
                            }
                        }
                    } else if data.status == 406 {
                        self.showConfirmAlert("음성에 부적절한 단어가 포함된것으로 판단됩니다. 다시녹음해주세요.","알림")
                    } else if data.status == 409 {
                        self.showConfirmAlert("중복된 제목입니다.", "알림")
                    } else {
                        self.showConfirmAlert("죄송합니다. \n서둘러 복구하겠습니다.", "서버점검")
                    }
                    
                case .failure(let msg):
    #if DEBUG
                    print("requestERR", msg)
    #endif
                    self.showConfirmAlert("죄송합니다. \n서둘러 복구하겠습니다.", "서버점검")
                }
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                }
            }
        }
    }
    
    @objc func addbackGroundTime(_ notification:Notification) {
        showToast(message: "녹음중 백그라운드로 이동시 녹음은 중지됩니다.", font: .systemFont(ofSize: 16), vcBool: true)
        showToVoice(type: .announcement, text: "녹음중 백그라운드로 이동시 녹음은 중지됩니다.")
    }
    
    @objc func tapClose() {
        closeButton.isHidden = true
        self.hero.modalAnimationType = .zoomOut
        dismiss(animated: true)
    }
    
    @objc func tapSelectButton() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if !app.preventTap {
            app.preventTap = true
        } else {
            return
        }
        
        if isRecord == .recording {
            stopRecord()
        }
        
        if isPlay == .play {
            stop()
        }
        
        let bgmSelectViewController = BGMSelectTableViewController()
        bgmSelectViewController.delegate = self
        bgmSelectViewController.hero.isEnabled = true
        bgmSelectViewController.modalPresentationStyle = UIAccessibility.isVoiceOverRunning ? .fullScreen : .overFullScreen
        guard let topViewController = keyWindow?.visibleViewController else { return }
        topViewController.present(bgmSelectViewController, animated: true, completion: nil)
    }
}

extension FeelRecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecord = .stopRecord
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        isRecord = .stopRecord
    }
}

extension FeelRecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlay = .stop
    }
}

extension FeelRecordViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
#if DEBUG
            print("이용가능합니다.")
#endif
        } else {
#if DEBUG
            print("이용불가능합니다.")
#endif
        }
    }
}

extension FeelRecordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            titleTextField.resignFirstResponder()
        }
        return true
    }
}

extension FeelRecordViewController: SendDataDelegate {
    func recieveData(response: String) {
        selectBgmIndex = Int(response)!
    }
}
