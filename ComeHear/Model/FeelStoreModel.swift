//
//  FeelStoreModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/02.
//

import Foundation

struct FeelStoreModel: Decodable {
    var feelStore: [FeelStoreData] { feelStoreInfo.content }
    var pages: Pageable { feelStoreInfo.pageable }

    private let feelStoreInfo: FeelStoreDataModel

    enum CodingKeys: String, CodingKey {
        case feelStoreInfo = "data"
    }
}

struct FeelStoreDataModel: Decodable {
    var content: [FeelStoreData] = []
    var pageable: Pageable
}

struct FeelStoreData: Decodable {
    var title: String
    var imageUrl: String?
    var stid: String
    var stlid: String
    var langCode: String
    var memberLike: Bool?
}


