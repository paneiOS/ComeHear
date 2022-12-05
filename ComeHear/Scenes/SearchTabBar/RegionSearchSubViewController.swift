//
//  RegionSearchSubViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/06/30.
//

import UIKit
import Alamofire
import Kingfisher
import CoreLocation
import MapKit

class RegionSearchSubViewController: UIViewController, MTMapViewDelegate {
    private let constantSize = ConstantSize()
    
    // MARK: - 변수, 상수
    private var currentPosition = (37.568491, 126.981614)
    private var nowPage = 1
    private var totalPage = 0
    
    private var regions: [RegionDetail] = []
    private var mapView: MTMapView!
    private var geoCoder: MTMapReverseGeoCoder!
    private var locationManager: CLLocationManager!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var subView: UIView = {
        let subView = MTMapView(frame: view.frame)
        subView.baseMapType = .standard
        return subView
    }()
    
    private lazy var currentButtonView: UIView = {
        let view = UIView()
        view.setupShadow()
        return view
    }()
    
    private lazy var currentButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "figure.wave", pointSize: 25, weight: .regular)
        button.tintColor = .black
        button.addTarget(self, action: #selector(moveCurrentPosition), for: .touchUpInside)
        button.isAccessibilityElement = false
        return button
    }()
    
    init(regions: [RegionDetail], totalPage: Int) {
        self.regions = regions
        self.totalPage = totalPage

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupNavigation()
        setupLayout()
        setupLocate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let itemMapY = Double(regions.first?.mapY ?? "37.568491") ?? 0.0
        let itemMapX = Double(regions.first?.mapX ?? "126.981614") ?? 0.0
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: itemMapY, longitude: itemMapX)), zoomLevel: 7, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        showToVoice(type: .screenChanged, text: "현재화면은 지역별 검색 결과화면입니다.")
    }
    
    private func setupNavigation() {
        navigationItem.title = "지역 선택"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "JSArirangHON-Regular", size: 28)!, .foregroundColor: UIColor.black]
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .black
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func setupMap() {
        mapView = MTMapView(frame: subView.frame)
        mapView.currentLocationTrackingMode = .onWithoutHeading
        mapView.delegate = self
        mapView.fitAreaToShowAllPOIItems()
        makeMarker()
    }
    
    // poiItem 클릭 이벤트
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        let region = regions[poiItem.tag]
        let viewController = StorySearchSubViewController(storyTitle: region.title, tid: region.tid, tlid: region.tlid, image: region.imageUrl, favorite: false)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonRightSideOf poiItem: MTMapPOIItem!) {
        let region = regions[poiItem.tag]
        let viewController = StorySearchSubViewController(storyTitle: region.title, tid: region.tid, tlid: region.tlid, image: region.imageUrl, favorite: false)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 마커 추가
    func makeMarker(){
        var cnt = 0
        var poiItemArr = Array(repeating: MTMapPOIItem(), count: regions.count)
        for item in regions {
            let poiItem = MTMapPOIItem()
            poiItem.itemName = item.mapY == nil || item.mapX == nil ? "\(item.title)\n죄송합니다.\n서버에 문제가 생겼습니다." : item.title
            poiItem.markerSelectedType = .redPin
            poiItem.showAnimationType = .springFromGround
            let itemMapY = Double(item.mapY ?? "37.568491") ?? 0.0
            let itemMapX = Double(item.mapX ?? "126.981614") ?? 0.0
            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: itemMapY, longitude: itemMapX))
            poiItem.tag = cnt
            poiItemArr[cnt] = poiItem
            cnt += 1
        }
        
        mapView.addPOIItems(poiItemArr)
        mapView.fitAreaToShowAllPOIItems()
        
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .white
        
        [subView, tableView].forEach {
            view.addSubview($0)
        }
        
        subView.addSubview(currentButtonView)
        
        subView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(subView.snp.width)
        }
        
        currentButtonView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(constantSize.intervalSize)
            $0.bottom.equalToSuperview().inset(constantSize.intervalSize * 2)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        
        currentButtonView.addSubview(currentButton)
        
        currentButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(subView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupLocate() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @objc private func moveCurrentPosition() {
        if self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways {
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentPosition.1, longitude: currentPosition.0)), zoomLevel: 7, animated: true)
        } else {
            showSettingAlert(type: .gps)
        }
    }
}

extension RegionSearchSubViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIAccessibility.isVoiceOverRunning {
            let region = regions[indexPath.row]
            let viewController = StorySearchSubViewController(storyTitle: region.title, tid: region.tid, tlid: region.tlid, image: region.imageUrl, favorite: false)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let itemMapY = Double(regions[indexPath.row].mapY ?? "37.568491") ?? 0.0
            let itemMapX = Double(regions[indexPath.row].mapX ?? "126.981614") ?? 0.0
            let point = mapView.findPOIItem(byTag: indexPath.row)
            mapView.select(point, animated: true)
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: itemMapY, longitude: itemMapX)), zoomLevel: 3, animated: true)
        }
    }
}

extension RegionSearchSubViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        
        let story = regions[indexPath.row]
        cell.textLabel?.text = story.title
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension RegionSearchSubViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            getLocationUsagePermission()
        case .authorizedAlways, .authorizedWhenInUse:
#if DEBUG
            print("GPS 권한 설정됨")
            #endif
        case .restricted, .denied:
            showSettingAlert(type: .gps)
        default:
            #if DEBUG
            print("GPS: Default")
            #endif
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            let location: CLLocation = first
            let longtitude: CLLocationDegrees = location.coordinate.longitude
            let latitude:CLLocationDegrees = location.coordinate.latitude
            currentPosition = (longtitude, latitude)
            #if DEBUG
            print("현재위치", longtitude, latitude)
            #endif
        }
    }
}
