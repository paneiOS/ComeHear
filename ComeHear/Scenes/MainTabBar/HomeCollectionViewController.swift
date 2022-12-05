//
//  HomeCollectionViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/10.
//

import UIKit
import Alamofire
import CoreLocation
import Kingfisher
import MapKit

final class HomeCollectionViewController: UICollectionViewController {
    // MARK: - 변수, 상수
    private let constantSize = ConstantSize()
    private var locationManager: CLLocationManager!
    private var banner: [BannerData] = [] {
        didSet {
            if banner.count > 1 {
                for i in banner {
                    banner.append(i)
                }
                for i in 0..<(banner.count/2) {
                    banner.append(banner[i])
                }
            }
            
            if banner.count > 0 {
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(item: banner.count/3, section: 1), at: .left, animated: false)
            }
        }
    }
    private var recentFeel: [FeelStoreData] = []
    private var placeList: [RegionDetail] = []
    private let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    private lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(setupLocate) , for: .valueChanged)
        return refreshControl
    }()
    private var preventLocation = false
    
    // MARK: - LifeCycle_생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
        setupCollectionVeiw()
        collectionView.refreshControl = refresh
        setupLocate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.isScrollEnabled = !UIAccessibility.isVoiceOverRunning
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.accessibilityElementDidBecomeFocused()
        self.showToVoice(type: .screenChanged, text: "현재화면은 메인화면입니다. 검색기능 네가지와 안내지침서를 제공하고있습니다.")
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refresh.isRefreshing {
            return
        }
    }
    
    private func setupCollectionVeiw() {
        //CollectionView Header 설정
        collectionView.register(ContentCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentCollectionViewHeader")
        collectionView.register(ContentCollectionViewBasicHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentCollectionViewBasicHeader")
        collectionView.register(ContentCollectionViewFeelHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentCollectionViewFeelHeader")
        collectionView.register(ContentCollectionViewHotHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentCollectionViewHotHeader")
        
        //CollectionView Footer 설정
        collectionView.register(ContentCollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ContentCollectionViewFooter")
        
        //CollectionView 설정
        collectionView.register(ContentCollectionViewTagCell.self, forCellWithReuseIdentifier: "ContentCollectionViewTagCell")
        collectionView.register(ContentCollectionViewManualCell.self, forCellWithReuseIdentifier: "ContentCollectionViewManualCell")
        collectionView.register(ContentCollectionViewFeelCell.self, forCellWithReuseIdentifier: "ContentCollectionViewFeelCell")
        collectionView.register(ContentCollectionViewAroundCell.self, forCellWithReuseIdentifier: "ContentCollectionViewAroundCell")
        collectionView.register(ContentCollectionViewSearchCell.self, forCellWithReuseIdentifier: "ContentCollectionViewSearchCell")
        collectionView.register(AroundPlaceHolderCollectionViewCell.self, forCellWithReuseIdentifier: "AroundPlaceHolderCollectionViewCell")
        
        collectionView.collectionViewLayout = layout()
    }
    
    //각각의 섹션 타입에 대한 UICollectionViewLayout 생성
    private func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionNumber, environment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            switch sectionNumber {
            case 0:
                if UIAccessibility.isVoiceOverRunning {
                    return self.createLocateTypeSection()
                } else {
                    return self.createBlankTypeSection()
                }
            case 1:
                if UIAccessibility.isVoiceOverRunning {
                    return self.createBlankTypeSection()
                } else {
                    return self.createTagTypeSection()
                }
            case 2:
                return self.createManualTypeSection()
            case 3:
                if UIAccessibility.isVoiceOverRunning {
                    return self.createBlankTypeSection()
                } else {
                    return self.createFeelTypeSection()
                }
            case 4:
                if UIAccessibility.isVoiceOverRunning {
                    return self.createBlankTypeSection()
                } else {
                    if self.placeList.isEmpty {
                        return self.placeHolderTypeSection()
                    } else {
                        return self.createHotPlaceTypeSection()
                    }
                }
            default:
                return self.createBlankTypeSection()
            }
        }
        layout.register(MyBgDecorationView.self, forDecorationViewOfKind: "MyBgDecorationView")
        return layout
    }
    
    private func createBlankTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = .init(top: -1, leading: -0.25, bottom: 0, trailing: -0.25)
        return section
    }
    
    private func createTagTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 20, leading: 10, bottom: 0, trailing: 10)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        let sectionHeader = self.createTagSectionHeader()
        let sectionFooter = self.createSectionFooter()
        section.boundarySupplementaryItems  = [sectionHeader, sectionFooter]
        section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -0.25, bottom: 0, trailing: -0.25)
        section.decorationItems = [decorationView]
        
        return section
    }
    
    private func createLocateTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.decorationItems = [decorationView]
        
        return section
    }
    
    private func createManualTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.4))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -0.25, bottom: 0, trailing: -0.25)
        section.decorationItems = [decorationView]
        
        return section
    }
    
    private func placeHolderTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: constantSize.intervalSize, trailing: 0)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        let sectionHeader = self.createBasicSectionHeader()
        section.boundarySupplementaryItems  = [sectionHeader]
        section.contentInsets = .init(top: 0, leading: constantSize.intervalSize-5, bottom: constantSize.intervalSize, trailing: constantSize.intervalSize-5)
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.decorationItems = [decorationView]
        return section
    }
    
    private func createFeelTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        //group
        if constantSize.frameSizeHeight/3 >= 350 {
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(constantSize.frameSizeHeight/3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
            group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            //secion
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            let sectionHeader = self.createBasicSectionHeader()
            section.boundarySupplementaryItems  = [sectionHeader]
            section.contentInsets = .init(top: 0, leading: constantSize.intervalSize-5, bottom: 10, trailing: constantSize.intervalSize-5)
            return section
        } else {
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
            group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            //secion
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            let sectionHeader = self.createBasicSectionHeader()
            section.boundarySupplementaryItems  = [sectionHeader]
            section.contentInsets = .init(top: 0, leading: constantSize.intervalSize-5, bottom: 10, trailing: constantSize.intervalSize-5)
            return section
        }
    }
    
    private func createHotTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalWidth(0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.contentInsets = .init(top: 0, leading: 3, bottom: 0, trailing: 0)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let sectionHeader = self.createBasicSectionHeader()
        section.boundarySupplementaryItems  = [sectionHeader]
        section.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -0.25, bottom: 0, trailing: -0.25)
        section.decorationItems = [decorationView]
        return section
    }
    
    private func createHotPlaceTypeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        //group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        //secion
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let sectionHeader = self.createBasicSectionHeader()
        section.boundarySupplementaryItems  = [sectionHeader]
        section.contentInsets = .init(top: 0, leading: constantSize.intervalSize-5, bottom: constantSize.intervalSize, trailing: constantSize.intervalSize-5)
        
        let decorationView = NSCollectionLayoutDecorationItem.background(elementKind: "MyBgDecorationView")
        decorationView.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -0.25, bottom: 0, trailing: -0.25)
        section.decorationItems = [decorationView]
        return section
    }
    
    // SectionHeader layout 설정
    private func createTagSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        //Section Header 사이즈
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
        
        // Section Header Layout
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        return sectionHeader
    }
    
    // SectionFooter layout 설정
    private func createSectionFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        //Section Header 사이즈
        let layoutSectionFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10))
        // Section Header Layout
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionFooterSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomLeading)
        return sectionFooter
    }
    
    // SectionHeader layout 설정
    private func createBasicSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        //Section Header 사이즈
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        // Section Header Layout
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        return sectionHeader
    }
    
    private lazy var customView = UIView()
    
    private func setupLayout() {
        collectionView.backgroundColor = .white
        if UIAccessibility.isVoiceOverRunning {
            collectionView.bounces = false
            collectionView.alwaysBounceVertical = false
        }
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupNavigation() {
        navigationItem.title = "Come Hear"
        navigationController?.setupBasicNavigation()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
    }
    
    @objc private func setupLocate() {
        //위치 권한 설정 확인
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = 1500
    }
    
    private func requestMainBanner(_ mapX: String?, _ mapY: String?) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        var urlString = URLString.SubDomain.mainAll.getURL() + "?langCode=\(languageCode)"
        if let x = mapX, let y = mapY {
            urlString += "&mapX=\(x)&mapY=\(y)"
        }
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: MainModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    print("data", data)
                    if self.banner.isEmpty {
                        self.banner = data.data.banner.content
                    }
                    self.recentFeel = data.data.recentFeel.content
                    self.placeList = data.data.placeList.content
                    
                    let time: Double = app.isMainLoading ? 1 : 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                        app.isMainLoading = false
                        self.collectionView.reloadData()
                        self.preventLocation = false
                        self.refresh.endRefreshing()
                        LoadingIndicator.hideLoading()
                    }
                case .failure(_):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
                        app.isMainLoading = false
                        self.preventLocation = false
                        self.refresh.endRefreshing()
                        LoadingIndicator.hideLoading()
                    }
                    self.showCloseAlert(type: .unknownError)
                }
            }
    }
    
    @objc func locateSearch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        if app.authorizationState == .authorizedAlways || app.authorizationState == .authorizedWhenInUse {
            let viewController = LocateSearchViewController()
            guard let topViewController = keyWindow?.visibleViewController else { return }
            topViewController.navigationController?.pushViewController(viewController, animated: true)
        } else {
            showSettingAlert(type: .gps)
        }
    }
}

//MARK: UICollectionView Datasource, Delegate
extension HomeCollectionViewController {
    //섹션당 보여질 셀의 개수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return UIAccessibility.isVoiceOverRunning ? 1 : 0
        case 1:
            return banner.count // * 3
        case 2:
            return 1
        case 3:
            return recentFeel.count
        case 4:
            if placeList.isEmpty {
                return 1
            } else {
                return placeList.count
            }
        default:
            return 1
        }
    }
    
    //콜렉션뷰 셀 설정
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewSearchCell", for: indexPath) as? ContentCollectionViewSearchCell else { return UICollectionViewCell() }
            cell.locateSearchButton.addTarget(self, action: #selector(locateSearch), for: .touchUpInside)
            cell.setup()
            cell.shouldGroupAccessibilityChildren = true
            
            if UIAccessibility.isVoiceOverRunning {
                return cell
            } else {
                return UICollectionViewCell()
            }
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewTagCell", for: indexPath) as? ContentCollectionViewTagCell else { return UICollectionViewCell() }
            cell.setupShadow(color: .white, cornerRadius: 15)
            let tagArr = banner[indexPath.row].tags.components(separatedBy: ",")
            cell.firstTag.text = "   # " + tagArr[0] + "   "
            cell.secondTag.text = "   # " + tagArr[1] + "   "
            cell.thirdTag.text = "   # " + tagArr[2] + "   "
            cell.detailLabel.text = "   " + banner[indexPath.row].bannerTitle + "   "
            let url = banner[indexPath.row].bannerImgUrl
            cell.imageView.setImage(with: url, placeholder: ContentImage.loadingImage.getImage(), cornerRadius: 15)
            cell.accessibilityElementsHidden = true
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewManualCell", for: indexPath) as? ContentCollectionViewManualCell else { return UICollectionViewCell() }
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewFeelCell", for: indexPath) as? ContentCollectionViewFeelCell else { return UICollectionViewCell() }
            if let url = recentFeel[indexPath.row].imageUrl {
                if url == "" {
                    cell.imageView.image = UIImage(named: "LoadingImage_Circle_\(constantSize.randumNumber)")
                } else {
                    cell.imageView.setImage(
                        with: url,
                        placeholder: UIImage(named: "LoadingImage_Circle_\(constantSize.randumNumber)"),
                        cornerRadius: 0
                    )
                }
            } else {
                cell.imageView.image = UIImage(named: "LoadingImage_Circle_\(constantSize.randumNumber)")
            }
            cell.titleLabel.text = recentFeel[indexPath.row].title
            cell.backgroundColor = .white
            cell.tintColor = .white
            cell.accessibilityElementsHidden = true
            return cell
        case 4:
            if placeList.isEmpty {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AroundPlaceHolderCollectionViewCell", for: indexPath) as? AroundPlaceHolderCollectionViewCell else { return UICollectionViewCell() }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewAroundCell", for: indexPath) as? ContentCollectionViewAroundCell else { return UICollectionViewCell() }
                cell.setupAroundViewShadow()
                if let url = placeList[indexPath.row].imageUrl {
                    if url == "" {
                        cell.imageView.image = ContentImage.landScapeImage.getImage()
                    } else {
                        cell.imageView.setImage(
                            with: url,
                            placeholder: ContentImage.landScapeImage.getImage(),
                            cornerRadius: 0
                        )
                    }
                } else {
                    cell.imageView.image = ContentImage.landScapeImage.getImage()
                }
                cell.titleLabel.text = placeList[indexPath.row].title
                cell.descriptionLabel.text = placeList[indexPath.row].themeCategory ?? ""
                cell.accessibilityElementsHidden = true
                return cell
            }
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AroundPlaceHolderCollectionViewCell", for: indexPath) as? AroundPlaceHolderCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
    }
    
    //섹션 개수 설정
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    //헤더뷰, 푸터뷰 설정
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 1 {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ContentCollectionViewHeader", for: indexPath) as? ContentCollectionViewHeader else { fatalError("Could not dequeue Header") }
                headerView.accessibilityElementsHidden = true
                return headerView
            } else if indexPath.section == 3 || indexPath.section == 4 {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ContentCollectionViewHotHeader", for: indexPath) as? ContentCollectionViewHotHeader else { fatalError("Could not dequeue Header") }
                headerView.setup()
                if indexPath.section == 3 {
                    headerView.sectionNameRedLabel.text = "Hot"
                    headerView.sectionNameLabel.text = "느낌 관광지".localized()
                } else {
                    headerView.sectionNameRedLabel.text = "Hot"
                    headerView.sectionNameLabel.text = "주변 관광지".localized()
                }
                headerView.accessibilityElementsHidden = true
                return headerView
            } else {
                return UICollectionReusableView()
            }
        case UICollectionView.elementKindSectionFooter:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ContentCollectionViewFooter", for: indexPath) as? ContentCollectionViewFooter else { fatalError("Could not dequeue Footer") }
            footerView.accessibilityElementsHidden = true
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
    
    //셀 선택
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 5 {
                collectionView.scrollToItem(at: IndexPath(item: 2, section: 1), at: .left, animated: false)
            } else if indexPath.row == 3 {
                collectionView.scrollToItem(at: IndexPath(item: 6, section: 1), at: .left, animated: false)
            }
            let banner = banner[indexPath.row]
            let viewController = StorySearchSubViewController(storyTitle: banner.title, tid: banner.tid, tlid: banner.tlid, image: banner.imgUrl, favorite: false)
            navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController = ManualScrollViewController()
            viewController.hero.isEnabled = true
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        case 3:
            guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
            let recentFeel = recentFeel[indexPath.row]
            let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
            let urlString = URLString.SubDomain.storyDetail.getURL() + "?langCode=\(languageCode)&pageNo=1&pageSize=20000&stid=\(recentFeel.stid)&stlid=\(recentFeel.stlid)"
            if !app.preventTap {
                app.preventTap = true
            } else {
                return
            }
            
            AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
                .responseDecodable(of: StoryDetailModel.self) { [weak self] response in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        guard data.storyDetails.count != 0 else { return }
                        let storyDetail = data.storyDetails[0]
                        let viewController = StoryDetailViewController(storyDetail: storyDetail)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    case .failure(_):
                        self.showCloseAlert(type: .unknownError)
                    }
                }
        case 4:
            if placeList.isEmpty {
                showSettingAlert(type: .gps)
            } else {
                let placeList = self.placeList[indexPath.row]
                let viewController = StorySearchSubViewController(storyTitle: placeList.title, tid: placeList.tid, tlid: placeList.tlid, image: placeList.imageUrl, favorite: false)
                navigationController?.pushViewController(viewController, animated: true)
            }
        default:
#if DEBUG
            print(indexPath.section)
#endif
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row + 1 == banner.count {
            collectionView.scrollToItem(at: IndexPath(item: (banner.count / 3 + 1), section: 1), at: .left, animated: false)
        } else if indexPath.section == 1 && indexPath.row + 1 == 1 {
            collectionView.scrollToItem(at: IndexPath(item: (banner.count / 3 + 1), section: 1), at: .right, animated: false)
        }
    }
}

extension HomeCollectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        app.authorizationState = status
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            guard !UIAccessibility.isVoiceOverRunning else { return }
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            guard !UIAccessibility.isVoiceOverRunning else { return }
            requestMainBanner(nil, nil)
        @unknown default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let longtitude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
#if DEBUG
            print("현재위치", location, latitude)
#endif
            if preventLocation {
                return
            }
            preventLocation = true
            if !UIAccessibility.isVoiceOverRunning {
                requestMainBanner(String(longtitude), String(latitude))
            }
        }
    }
}
