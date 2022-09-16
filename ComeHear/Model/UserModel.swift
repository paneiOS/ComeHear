//
//  UserModel.swift
//  ComeHear
//
//  Created by Pane on 2022/07/11.
//

import Foundation

struct EmailValidation: Decodable {
    var status: Int
    let data: EmailDataModel?
}

struct EmailDataModel: Decodable {
    var uuid: String
}

struct Login: Decodable {
    var status: Int
    let data: LoginDataModel?
}

struct LoginDataModel: Decodable {
    var memberIdx: Int
    var token: String
    var email: String
    var nickName: String
}

struct Signup: Decodable {
    var status: Int
}

struct UserResponseData: Decodable {
    var status: Int
}
