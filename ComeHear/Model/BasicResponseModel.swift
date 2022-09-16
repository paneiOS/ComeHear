//
//  BasicResponseModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/18.
//

import Foundation

struct BasicResponseModel: Decodable {
    var status: Int
    var message: String
//    var data: Int?
}

struct BasicResponseBoolModel: Decodable {
    var status: Int
    var message: String
    var data: Bool
}

struct BasicResponseMsgModel: Decodable {
    var status: Int
    var message: String
    var data: BasicResponseMsgDataModel?
}

struct BasicResponseMsgDataModel: Decodable {
    var message: String
}
