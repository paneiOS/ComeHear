//
//  RegionDetailModel.swift
//  ComeHear
//
//  Created by Pane on 2022/06/30.
//

import Foundation

struct RegionDetailModel: Decodable {
    var regionDetails: [RegionDetail] { regionDetailInfo.content }
    var pages: Pageable { regionDetailInfo.pageable }

    private let regionDetailInfo: RegionDetailDataModel

    enum CodingKeys: String, CodingKey {
        case regionDetailInfo = "data"
    }
}

struct RegionDetailDataModel: Decodable {
    var content: [RegionDetail] = []
    var pageable: Pageable
}


struct RegionDetail: Decodable {
    var title: String
    var tid: String
    var tlid: String
    var langCode: String
    var mapX: String?
    var mapY: String?
    var imageUrl: String?
    var memberLike: Bool
    var themeCategory: String?
}

