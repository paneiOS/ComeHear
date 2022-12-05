//
//  LaunchScreenManager.swift
//  ComeHear
//
//  Created by Pane on 2022/08/02.
//

import UIKit

class LaunchScreenManager {
    
    // MARK: - Properties
    private let constantSize = ConstantSize()
    static let instance = LaunchScreenManager(animationDurationBase: 1)
    
    var view: UIView?
    var parentView: UIView?
    
    let animationDurationBase: Double
    
    let yellowTopView = 101
    let yellowBottomView = 102
    
    // MARK: - Lifecycle
    
    init(animationDurationBase: Double) {
        self.animationDurationBase = animationDurationBase
    }
    
    // MARK: - Animate
    func animateAfterLaunch(_ parentViewPassedIn: UIView) {
        parentView = parentViewPassedIn
        view = loadView()
        fillParentViewWithView()
        hideLogo()
    }
    
    func loadView() -> UIView {
        return UINib(nibName: "LaunchScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func fillParentViewWithView() {
        parentView!.addSubview(view!)
        
        view!.frame = parentView!.bounds
        view!.center = parentView!.center
    }
    
    func hideLogo() {
        let coverTopView = view!.viewWithTag(yellowTopView)!
        let coverBottomView = view!.viewWithTag(yellowBottomView)!
        UIView.animate(
            withDuration: animationDurationBase,
            delay: 0,
            options: .curveEaseIn,
            animations: { [weak self] in
                guard let self = self else { return }
                coverTopView.transform = CGAffineTransform(translationX: 0, y: -self.constantSize.frameSizeHeight/2 - 200)
                coverBottomView.transform = CGAffineTransform(translationX: 0, y: self.constantSize.frameSizeHeight/2 + 200)
            }
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.view?.isHidden = true
                if !UIAccessibility.isVoiceOverRunning {
                    guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
                    if app.isMainLoading {
                        LoadingIndicator.showLoading(className: "LaunchScreenManager", function: "로딩화면")
                    }
                }
            }
        }
    }
}
