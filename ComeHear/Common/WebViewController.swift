//
//  WebViewController.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/13.
//

import WebKit

class WebViewController: UIViewController, WKNavigationDelegate,
    WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: self.view.frame)
        self.view = self.webView!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let sURL = app.languageCode == "ko" ?  "https://api.visitkorea.or.kr/#/agrAgreement" : "https://api.visitkorea.or.kr/#/agrAgreementEng"
        let uURL = URL(string: sURL)
        let request = URLRequest(url: uURL!)
        webView.load(request)
        
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 저작물표시 이용약관 안내화면입니다.")
    }
    
    private func setupNavigation() {
        navigationItem.title = "저작물표시 안내".localized()
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let scaledImage = UIImage(named: "CopyRightImage")?.resizeImage(size: CGSize(width: 44, height: 44))
        let imageView = UIImageView(image: scaledImage)
        imageView.frame = CGRect(origin: .zero, size: scaledImage?.size ?? .zero)
        imageView.clipsToBounds = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
    }
}
