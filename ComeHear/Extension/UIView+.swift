//
//  UIView+.swift
//  ComeHear
//
//  Created by Pane on 2022/07/04.
//

//import Foundation

class RoundView: UIView {
    @IBInspectable var cornerTopRadius: CGFloat {
        set(newValue) {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        get {
            return self.layer.cornerRadius
        }
    }
}

extension UIView {
    func setupMainShadow() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    func setupShadow(color: UIColor?, cornerRadius: CGFloat?) {
        self.backgroundColor = color ?? .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = cornerRadius ?? 12
    }
    
    func setupShadow(color: UIColor?) {
        self.backgroundColor = color ?? .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 12
    }
    
    func setupShadow(cornerRadius: CGFloat?) {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = cornerRadius ?? 12
    }
    
    func setupAroundViewShadow() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = 15
    }
    
    func setupShadow() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 12
    }
    
    func setupSubViewHeader() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    func setupSubViewHeader(color: UIColor?) {
        self.backgroundColor = color ?? .white
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    func setupSubViewFooter() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
    func setupSubViewFooter(color: UIColor?) {
        self.backgroundColor = color ?? .white
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
    func setupSubViewTextFieldView() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = ContentColor.moreLightGrayColor.getColor().cgColor
        self.layer.cornerRadius = 12
        self.backgroundColor = ContentColor.moreLightGrayColor.getColor()
    }
}
