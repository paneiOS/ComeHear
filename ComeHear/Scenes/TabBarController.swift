//
//  TabBarController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/22.
//

import UIKit

class TabBarController: UITabBarController {
    
    private lazy var homeViewController: UIViewController = {
        let layout = UICollectionViewFlowLayout()
        let viewController = UINavigationController(rootViewController: HomeCollectionViewController(collectionViewLayout: layout))
        let tabBarItem = UITabBarItem(
            title: "탭바1".localized(),
            image: UIImage(systemName: "house"),
            tag: 0
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    private lazy var feelStoreViewController: UIViewController = {
        let viewController = UINavigationController(rootViewController: FeelStoreSearchViewController())
        let tabBarItem = UITabBarItem(
            title: "탭바2".localized(),
            image: UIImage(systemName: "headphones"),
            tag: 1
        )
        viewController.tabBarItem = tabBarItem
        
        return viewController
    }()
    
    private lazy var searchViewController: UIViewController = {
        let viewController = UINavigationController(rootViewController: BasicSearchViewController())
        let tabBarItem = UITabBarItem(
            title: "탭바3".localized(),
            image: UIImage(systemName: "magnifyingglass"),
            tag: 2
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    private lazy var favoriteViewController: UIViewController = {
        let viewController = UINavigationController(rootViewController: MyFavoriteTabBarViewController())
        let tabBarItem = UITabBarItem(
            title: "탭바4".localized(),
            image: UIImage(systemName: "star"),
            tag: UIAccessibility.isVoiceOverRunning ? 2 : 4
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    private lazy var myPageViewController: UIViewController = {
        let viewController = UINavigationController(rootViewController: MyPageViewController())
        let tabBarItem = UITabBarItem(
            title: "탭바5".localized(),
            image: UIImage(systemName: "person"),
            tag: UIAccessibility.isVoiceOverRunning ? 3 : 4
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarUI()
        if UIAccessibility.isVoiceOverRunning {
            viewControllers = [homeViewController, feelStoreViewController, favoriteViewController, myPageViewController]
        } else {
            viewControllers = [homeViewController, feelStoreViewController, searchViewController, favoriteViewController, myPageViewController]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTabBarUI() {
        tabBar.tintColor = UIColor.black
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let viewController = self.viewControllers?[item.tag] as? UINavigationController else { return }
        viewController.popToRootViewController(animated: true)
//        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false) {
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
}
