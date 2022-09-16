//
//  StoryDetailModel.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import Foundation

struct StoryDetailModel: Decodable {
    var storyDetails: [StoryDetail] { storyDetailInfo.content }
    var pages: Pageable { storyDetailInfo.pageable }

    private let storyDetailInfo: StoryDetailDataModel

    enum CodingKeys: String, CodingKey {
        case storyDetailInfo = "data"
    }

    struct StoryDetailDataModel: Decodable {
        var content: [StoryDetail] = []
        var pageable: Pageable
    }
}

struct StoryDetail: Decodable {
    var title: String
    var audioTitle: String?
    var audioUrl: String?
    var imageUrl: String?
    var script: String?
    var langCode: String
    var mapX: String?
    var mapY: String?
    var tid: String
    var tlid: String
    var stid: String
    var stlid: String
}

