////
////  UIScollView+.swift
////  ComeHear
////
////  Created by Pane on 2022/07/20.
////
//
//extension UIScrollView {
//    func scroll(direction: ScrollDirection) {
//        DispatchQueue.main.async {
//            switch direction {
//            case .top:
//                self.scrollToTop()
//            case .center:
//                self.scrollToCenter()
//            case .bottom:
//                self.scrollToBottom()
//            }
//        }
//    }
//
//    private func scrollToTop() {
//        setContentOffset(.zero, animated: true)
//    }
//
//    private func scrollToCenter() {
//        let centerOffset = CGPoint(x: 0, y: (contentSize.height - bounds.size.height) / 2)
//        setContentOffset(centerOffset, animated: true)
//    }
//
//    private func scrollToBottom() {
//        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
//        if(bottomOffset.y > 0) {
//            setContentOffset(bottomOffset, animated: true)
//        }
//    }
//}
