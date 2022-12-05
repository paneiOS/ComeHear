//
//  LocateSearchViewController.swift
//  ComeHear
//
//  Created by Pane on 2022/07/01.
//

import UIKit
import CoreLocation
import Alamofire

class LocateSearchViewController: UIViewController, MTMapViewDelegate {
    private let constantSize = ConstantSize()
    private var storyDetails: [StoryDetail] = []
    private var nowPage = 1
    private var totalPage = 0
    private var mapView: MTMapView!
    private var geoCoder: MTMapReverseGeoCoder!
    private var locationManager: CLLocationManager!
    private var currentPosition = (37.568491, 126.981614)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocate()
        setupNavigation()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.currentLocationTrackingMode = .onWithoutHeading
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToVoice(type: .screenChanged, text: "현재화면은 현재위치기반 검색화면입니다.")
    }
    
    private func setupNavigation() {
        navigationItem.title = "현재 위치 검색".localized()
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
        mapView.delegate = self
    }
    
    // poiItem 클릭 이벤트
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        let story = storyDetails[poiItem.tag]
        let viewController = StoryDetailViewController(storyDetail: story)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonRightSideOf poiItem: MTMapPOIItem!) {
        let story = storyDetails[poiItem.tag]
        let viewController = StoryDetailViewController(storyDetail: story)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 마커 추가
    func makeMarker(){
        var cnt = 0
        var poiItemArr = Array(repeating: MTMapPOIItem(), count: storyDetails.count)
        for item in storyDetails {
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
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentPosition.1, longitude: currentPosition.0)), zoomLevel: 3, animated: true)
        } else {
            showSettingAlert(type: .gps)
        }
    }
    
    private func requestSearch(_ longtitude: String, _ latitude: String) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        let languageCode = app.languageCode == "ja" ? "jp" : app.languageCode
        let urlString = URLString.SubDomain.storyLocationSearch.getURL() +  "/\(longtitude)/\(latitude)?langCode=\(languageCode)&pageNo=\(nowPage)&pageSize=100"

        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: StoryDetailModel.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.storyDetails = data.storyDetails
                    self.totalPage = data.pages.totalPages
                    self.makeMarker()
                    self.tableView.reloadData()
                case .failure(_):
                    self.showCloseAlert(type: .unknownError)
                }
            }
    }
    
}

extension LocateSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIAccessibility.isVoiceOverRunning {
            let story = storyDetails[indexPath.row]
            let viewController = StoryDetailViewController(storyDetail: story)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let itemMapY = Double(storyDetails[indexPath.row].mapY ?? "37.568491") ?? 0.0
            let itemMapX = Double(storyDetails[indexPath.row].mapX ?? "126.981614") ?? 0.0
            let point = mapView.findPOIItem(byTag: indexPath.row)
            mapView.select(point, animated: true)
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: itemMapY, longitude: itemMapX)), zoomLevel: 3, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
    }
}

extension LocateSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let story = storyDetails[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = story.title
        cell.detailTextLabel?.text = story.audioTitle ?? ""
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }
}


extension LocateSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        app.authorizationState = status
        
        switch status {
        case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
            break
        case .restricted, .denied:
            dismiss(animated: true) {
                self.showToast(message: "현재위치 정보를 얻기 위해 권한이 필요합니다." + " ", font: .systemFont(ofSize: 16), vcBool: true)
                self.showToVoice(type: .announcement, text: "현재위치 정보를 얻기 위해 권한이 필요합니다.")
            }
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
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longtitude)), zoomLevel: 3, animated: true)
            requestSearch(String(longtitude), String(latitude))
            currentPosition = (longtitude, latitude)
        }
    }
}

