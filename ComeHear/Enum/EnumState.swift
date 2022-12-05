//
//  EnumState.swift
//  ComeHear
//
//  Created by Pane on 2022/08/11.
//

enum ReportType {
    case abuseType
    case pornoType
    case unsuitableType
    case etcType
    case none
}

enum LoginState {
    case login
    case logout
}

enum PlayState {
    case play
    case pause
    case stop
    case resume
}

enum PlayRate {
    case slow
    case normal
    case fast
    case moreFast
}

enum RecordState {
    case recording
    case stopRecord
    case noneRecord
}

enum ScrollDirection {
    case top
    case center
    case bottom
}

enum PopupType {
    case comeHearTerms
    case comeHearPrivacy
    case tourApiTerms
}

