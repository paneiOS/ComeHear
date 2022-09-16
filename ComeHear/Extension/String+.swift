//
//  String+.swift
//  ComeHear
//
//  Created by Pane on 2022/09/05.
//

extension String {
    func localized(comment: String = "") -> String {
        let app = UIApplication.shared.delegate as? AppDelegate
        let path = Bundle.main.path(forResource: app?.languageCode, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return bundle?.localizedString(forKey: self, value: nil, table: nil) ?? self // NSLocalizedString(, comment: comment)
    }
    
    func localized(with argument: CVarArg = []) -> String {
        return String(format: self.localized(comment: ""), argument)
    }
}

