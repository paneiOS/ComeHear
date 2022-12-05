//
//  ContentColor.swift
//  ComeHear
//
//  Created by Pane on 2022/08/11.
//

// MARK: - String to UIColor
enum ContentColor: String {
    case personalColor = "PersonalColor"
    case moreLightGrayColor = "MoreLightGrayColor"
    case firstCellColor = "FirstCellColor"
    case secondCellColor = "SecondCellColor"
    case thirdCellColor = "ThirdCellColor"
    case fourthCellColor = "FourthCellColor"
    case checkButtonColor = "CheckButtonColor"

    func getColor() -> UIColor {
        guard let color = UIColor(named: self.rawValue) else { return UIColor() }
        return color
    }
}

