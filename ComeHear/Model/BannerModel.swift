//
//  BannerModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/02.
//

import Foundation

struct BannerModel: Decodable {
    var banners: [BannerData] { bannerInfo.content }
    var pages: Pageable { bannerInfo.pageable }

    private let bannerInfo: BannerDataModel

    enum CodingKeys: String, CodingKey {
        case bannerInfo = "data"
    }
}

struct BannerDataModel: Decodable {
    var content: [BannerData] = []
    var pageable: Pageable
}

struct BannerData: Decodable {
    var title: String
    var imgUrl: String
    var tid: String
    var tlid: String
    var tags: String
    var sort: Int
    var bannerTitle: String
    var bannerImgUrl: String
}


