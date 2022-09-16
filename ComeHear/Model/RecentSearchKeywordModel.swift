//
//  RecentSearchKeywordModel.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/07.
//

import Foundation

struct RecentSearchKeywordModel: Decodable {
    var status: Int
    var message: String
    var recentSearchArr: [SearchKeyword]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case recentSearchArr = "data"
    }
}
    
struct SearchKeyword: Decodable {
    var keyword: String
    var historyIdx: Int
}


