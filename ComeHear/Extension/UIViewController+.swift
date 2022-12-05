//
//  UIViewController+.swift
//  ComeHear
//
//  Created by Pane on 2022/06/13.
//

//import UIKit
//import Alamofire

extension UIViewController {
    func showCloseAlert(type: AlertCloseType) {
        let localMessage = NSLocalizedString(type.alertDescription, comment: "")
        let localTitle = NSLocalizedString(type.alertTitle, comment: "")
        var alertTitle = localTitle
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title: alertTitle, message: localMessage, preferredStyle: UIAlertController.Style.alert)
        let logOkAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            topViewController.navigationController?.popViewController(animated: true)
        }
        alter.addAction(logOkAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showTwoButtonAlert(type: AlertTwoButtonType, _ closeAction: UIAlertAction) {
        let localMessage = NSLocalizedString(type.alertDescription, comment: "")
        let localTitle = NSLocalizedString(type.alertTitle, comment: "")
        var alertTitle = localTitle
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title:  alertTitle, message: localMessage, preferredStyle: UIAlertController.Style.alert)
        let logNoAction = UIAlertAction(title: "아니오".localized(), style: UIAlertAction.Style.default, handler: nil)
        alter.addAction(logNoAction)
        alter.addAction(closeAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showLoginAlert(_ message: String, _ title: String) {
        var alertTitle = title
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        let logOkAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            topViewController.navigationController?.popViewController(animated: true)
        }
        alter.addAction(logOkAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showOneButtonAlert(_ message: String, _ title: String, _ closeAction: UIAlertAction) {
        var alertTitle = title
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alter.addAction(closeAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showConfirmAlert(type: AlertConfirmType) {
        let localMessage = NSLocalizedString(type.alertDescription, comment: "")
        let localTitle = NSLocalizedString(type.alertTitle, comment: "")
        var alertTitle = localTitle
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title: alertTitle, message: localMessage, preferredStyle: UIAlertController.Style.alert)
        let logOkAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default, handler: nil)
        alter.addAction(logOkAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showConfirmAlert(_ message: String, _ title: String?) {
        var alertTitle = title
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        guard let topViewController = keyWindow?.visibleViewController else { return }
        let alter = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        let logOkAction = UIAlertAction(title: "확인".localized(), style: UIAlertAction.Style.default, handler: nil)
        alter.addAction(logOkAction)
        topViewController.present(alter, animated: true, completion: nil)
    }
    
    func showSettingAlert(type: AlertSettingType) {
        let localTitle = NSLocalizedString(type.alertTitle, comment: "")
        let localMessage = NSLocalizedString(type.alertDescription, comment: "")
        var alertTitle = localTitle
        if UIAccessibility.isVoiceOverRunning {
            alertTitle = ""
        }
        let alertViewController: UIAlertController = UIAlertController(title: alertTitle,
                                                                       message: localMessage,
                                                                       preferredStyle: .alert)
        let settingAction: UIAlertAction = UIAlertAction(title: "설정".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL,
                                              options: [:],
                                              completionHandler: nil)
                }
            }
        })
        let cancleAction: UIAlertAction = UIAlertAction(title: "취소".localized(), style: .cancel)
        alertViewController.addAction(settingAction)
        alertViewController.addAction(cancleAction)
        self.present(alertViewController, animated: true)
    }
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setKeyboardOnlyHideObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillOnlyHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setKeyboardHalfObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShowHalf), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillOnlyHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.window?.frame.origin.y == 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y -= (keyboardHeight - 34)
                    if let topViewController = keyWindow?.visibleViewController as? FeelRecordViewController, topViewController.className == "FeelRecordViewController" {
                        topViewController.titleTextFieldView.backgroundColor = .white
                        topViewController.sendView.backgroundColor = .white
                        let scale = CGAffineTransform(translationX: ConstantSize().intervalSize, y:0)
                        topViewController.sendButton.transform = scale
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y = 0
                if let topViewController = keyWindow?.visibleViewController as? FeelRecordViewController, topViewController.className == "FeelRecordViewController" {
                    topViewController.titleTextFieldView.backgroundColor = ContentColor.moreLightGrayColor.getColor()
                    topViewController.sendView.backgroundColor = .clear
                    let scale = CGAffineTransform(translationX: -ConstantSize().intervalSize, y:0)
                    topViewController.sendButton.transform = scale
                }
            }
        }
    }
    
    @objc func keyboardWillShowHalf(notification: NSNotification) {
        if self.view.window?.frame.origin.y == 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y -= (keyboardHeight * 2 / 3)
                }
            }
        }
    }
    
    @objc func keyboardWillOnlyHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y = 0
            }
        }
    }
    
    var className: String {
        NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
    
    func showToast(message : String, font: UIFont, vcBool: Bool) {
        let localeMessage = NSLocalizedString(message, comment: "")
        if UIAccessibility.isVoiceOverRunning {
            return
        }
        let yPosition = self.view.frame.size.height * 8 / 10
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - CGFloat(localeMessage.count * 10),
                                               y: yPosition,
                                               width: CGFloat(localeMessage.count * 20),
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = localeMessage
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showToVoice(type: UIAccessibility.Notification, text: String) {
        let localMessage = NSLocalizedString(text, comment: "")
        if type == .screenChanged {
            UIAccessibility.post(notification: type, argument: localMessage)
        } else if type == .announcement {
            UIAccessibility.post(notification: type, argument: localMessage)
        } else if type == .layoutChanged {
            UIAccessibility.post(notification: type, argument: localMessage)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: type, argument: localMessage)
            }
        }
    }
    
    func showToVoice2(type: UIAccessibility.Notification, text: String) {
        if type == .screenChanged {
            UIAccessibility.post(notification: type, argument: text)
        } else if type == .announcement {
            UIAccessibility.post(notification: type, argument: text)
        } else if type == .layoutChanged {
            UIAccessibility.post(notification: type, argument: text)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: type, argument: text)
            }
        }
    }
}
