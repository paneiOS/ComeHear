//
//  MainModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/02.
//

import Foundation

struct MainModel: Decodable {
    let data: MainDataModel
}

struct MainDataModel: Decodable {
    let banner: BannerDataModel
    let recentFeel: FeelStoreDataModel
    let placeList: RegionDetailDataModel
}
