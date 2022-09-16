//
//  PageModel.swift
//  ComeHear
//
//  Created by Pane on 2022/06/28.
//

import Foundation

struct Pageable: Decodable {
    let pageNumber: Int
    let totalPages: Int
}
