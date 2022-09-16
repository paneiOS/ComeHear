//
//  DestinationModel.swift
//  ComeHear
//
//  Created by Pane on 2022/06/29.
//

import Foundation

struct DestinationModel: Decodable {
    var destinations: [DestinationDetailData] { destinationInfo.content }
    var pages: Pageable { destinationInfo.pageable }

    private let destinationInfo: DestinationDataModel

    enum CodingKeys: String, CodingKey {
        case destinationInfo = "data"
    }
}

struct DestinationDataModel: Decodable {
    var content: [DestinationDetailData] = []
    var pageable: Pageable
}

struct DestinationDetailData: Decodable {
    var title: String
    var langCode: String
    var tid: String
    var tlid: String
    var imageUrl: String?
    var memberLike: Bool?
}
