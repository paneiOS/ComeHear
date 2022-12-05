//
//  ContentInt.swift
//  ComeHear
//
//  Created by 이정환 on 2022/09/03.
//

import Foundation
struct CommonFunc {
    func intToString(_ tempNum: Int) -> String {
        if tempNum >= 100000 || tempNum == 0 {
            return String(tempNum)
        }
        
        let oneArr = ["", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
        let zeroArr = ["", "십 ", "백 ", "천 ", "만 "]
        var answer = ""
        var num = tempNum
        
        while num != 0 {
            switch num {
            case 10000..<100000:
                answer += num / 10000 == 1 ? "" : oneArr[num / 10000]
                answer += zeroArr[4]
                num %= 10000
            case 1000..<10000:
                answer += num / 1000 == 1 ? "" : oneArr[num / 1000]
                answer += zeroArr[3]
                num %= 1000
            case 100..<1000:
                answer += num / 100 == 1 ? "" : oneArr[num / 100]
                answer += zeroArr[2]
                num %= 100
            case 10..<100:
                answer += num / 10 == 1 ? "" : oneArr[num / 10]
                answer += zeroArr[1]
                num %= 10
            case 0..<10:
                answer += oneArr[num]
                answer += zeroArr[0]
                return answer
            default:
                return answer
            }
        }
        return answer
    }
}
