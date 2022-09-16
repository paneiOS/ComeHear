//
//  StoryModel.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import Foundation

struct StoryModel: Decodable {
    var storys: [StoryKeyword] { storyInfo.content }
    var pages: Pageable { storyInfo.pageable }

    private let storyInfo: StoryDataModel

    enum CodingKeys: String, CodingKey {
        case storyInfo = "data"
    }

    struct StoryDataModel: Decodable {
        var content: [StoryKeyword] = []
        var pageable: Pageable
    }
}

struct StoryKeyword: Decodable {
    var title: String
    var langCode: String
    var tid: String
    var tlid: String
    var stid: String
    var stlid: String
    var imageUrl: String?
}

