//
//  NoticeModel.swift
//  ComeHear
//
//  Created by 이정환 on 2022/07/24.
//

import Foundation

struct NoticeModel: Decodable {
    var noticeList: [NoticeData] { noticeInfo.content }
    var pages: Pageable { noticeInfo.pageable }

    private let noticeInfo: NoticeDataModel

    enum CodingKeys: String, CodingKey {
        case noticeInfo = "data"
    }
}

struct NoticeDataModel: Decodable {
    var content: [NoticeData] = []
    var pageable: Pageable
}

struct NoticeData: Decodable {
    var idx: Int
    var title: String
    var content: String
    var regDt: String
}


