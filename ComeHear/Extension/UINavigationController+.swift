//
//  UINavigationController+.swift
//  ComeHear
//
//  Created by Pane on 2022/07/25.
//

extension UINavigationController {
    
    func pushToViewController(_ viewController: UIViewController, animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToViewController(_ viewController: UIViewController, animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    func setupBasicNavigation() {
        self.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        self.navigationBar.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 28)!, .foregroundColor: UIColor.black]
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.tintColor = .black
        self.navigationBar.shadowImage = UIImage()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 32)!,
                                          .foregroundColor: UIColor.black]
        appearance.backgroundColor = .white

        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance

        let appearance2 = UINavigationBarAppearance()
        appearance2.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 32)!,
                                           .foregroundColor: UIColor.black]
        self.navigationItem.standardAppearance = appearance2
    }
    
    func setupBasicNavigation(backgroundColor: UIColor) {
        self.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        self.navigationBar.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 28)!, .foregroundColor: UIColor.black]
        self.navigationBar.backgroundColor = backgroundColor
        self.navigationBar.tintColor = .black
        self.navigationBar.shadowImage = UIImage()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 32)!,
                                          .foregroundColor: UIColor.black]
        appearance.backgroundColor = .white

        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance

        let appearance2 = UINavigationBarAppearance()
        appearance2.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 32)!,
                                           .foregroundColor: UIColor.black]
        self.navigationItem.standardAppearance = appearance2
    }
}
