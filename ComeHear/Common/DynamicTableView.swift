//
//  DynamicTableView.swift
//  ComeHear
//
//  Created by 이정환 on 2022/08/10.
//

import UIKit

class DynamicTableView: UITableView {
    private var tableTopPadding: CGFloat {
        get {
            if contentSize.height == 0 {
                return 0
            } else {
                return contentSize.height + 12
            }
        }
    }
    private var maxHeight: CGFloat = 350
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = min(tableTopPadding, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}

