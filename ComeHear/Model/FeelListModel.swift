//
//  FeelListModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/05.
//

import Foundation

struct FeelListModel: Decodable {
    var feelList: [FeelListData] { feelListInfo.content }
    var pages: Pageable { feelListInfo.pageable }

    private let feelListInfo: FeelListDataModel

    enum CodingKeys: String, CodingKey {
        case feelListInfo = "data"
    }
}

struct FeelListDataModel: Decodable {
    var content: [FeelListData] = []
    var pageable: Pageable
}


struct FeelListData: Decodable {
    var likeMemberIdx: Int?
    var stid: String
    var stlid: String
    var place: String
    var title: String
    var likeCnt: Int?
    var regDt: String
    var audioUrl: String
    var regMemberIdx: Int?
    var memberLike: Bool?
    var regMemberNickname: String?
    var imageUrl: String?
}
