//
//  MyFeelShareDataModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/29.
//

import Foundation

struct MyFeelShareDataModel: Decodable {
    var status: Int
    var message: String
    var myFeelShareList: [MyFeelShareDataList]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case myFeelShareList = "data"
    }
}

struct MyFeelShareDataList: Decodable {
    let place: String
    var list: [FeelListData]
}

//struct MyFeelShareData: Decodable {
//    let stid: String
//    let stlid: String
//    let place: String
//    let title: String
//    let likeCnt: Int
//    let regDt: String
//    let audioUrl: String
//}
