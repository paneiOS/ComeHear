//
//  SearchBar.swift
//  ComeHear
//
//  Created by Pane on 2022/08/24.
//

import UIKit

class SearchBar: UISearchBar {

    init(frame: CGRect, placeHorder: String) {
        super.init(frame: frame)
        setupAttribute(placeHolder: placeHorder)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAttribute(placeHolder: String) {
        searchTextField.font = .systemFont(ofSize: 16, weight: .regular)
        searchTextField.textColor = .label
        searchTextField.layer.cornerRadius = 20
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.placeholder = " " + placeHolder
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .white
//        searchTextField.returnKeyType = .done
    }
    
    private func setupLayout() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        searchTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(intervalSize/2)
            $0.leading.equalToSuperview().offset(intervalSize)
            $0.trailing.equalToSuperview().inset(intervalSize)
            $0.bottom.equalToSuperview().inset(intervalSize/2)
        }
    }
}
