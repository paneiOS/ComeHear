//
//  AlertType.swift
//  ComeHear
//
//  Created by 이정환 on 2022/12/05.
//

enum AlertCloseType {
    case nicknameChange
    case passwordChange
    case unknownError

    var alertTitle: String {
        switch self {
        case .unknownError:
            return "서버점검"
        default:
            return "알림"
        }
    }
    
    var alertDescription: String {
        switch self {
        case .nicknameChange:
            return "별명이 변경되었습니다."
        case .passwordChange:
            return "비밀번호가 변경되었습니다."
        case .unknownError:
            return "죄송합니다.\n서둘러 복구하겠습니다."
        }
    }
}

enum AlertTwoButtonType {
    case requestLogin
    case requestLogout
    case requestChangeLanguage
    case secession
    case deleteFeel
    
    var alertTitle: String {
        switch self {
        case.requestLogin:
            return "로그인"
        case .requestLogout:
            return "로그아웃"
        case .secession:
            return "탈퇴"
        case .deleteFeel:
            return "느낌삭제"
        default:
            return "알림"
        }
    }
    
    var alertDescription: String {
        switch self {
        case .requestLogin:
            return "로그인이 필요합니다.\n로그인페이지로 이동하시겠습니까?"
        case .requestLogout:
            return "로그아웃 하시겠습니까?"
        case .requestChangeLanguage:
            return "언어변경을 위해 앱을 종료하시겠습니까?\n(앱이 종료되면 앱을 다시 실행해주세요.)"
        case .secession:
            return "정말 탈퇴 하시겠습니까?"
        case .deleteFeel:
            return "정말 삭제 하시겠습니까?"
        }
    }
}

enum AlertConfirmType {
    case limitTime
    case insertTitle
    case deleteBlank
    case limitTitle
    case limitNickname
    case warningRecord
    case duplicateTitle
    case duplicateEmail
    case duplicateNickname
    case reasonReport
    case unknownError
    case selectCity
    case idToEmail
    case passwordNotBlank
    case nicknameNotBlank
    case emailAndPasswordCheck
    case emailInvalid
    case passwordInvalid
    case currentPasswordInvalid
    case agreeTerms
    case agreePrivacy
    case numberInValid
    case passwordNotCheck
    case insertNickname
    case nicknameError
    
    var alertTitle: String {
        switch self {
        case .unknownError:
            return "서버점검"
        default:
            return "알림"
        }
    }
    
    var alertDescription: String {
        switch self {
        case .limitTime:
            return "10초이상 녹음해주세요."
        case .insertTitle:
            return "제목을 입력해주세요."
        case .insertNickname:
            return "별명을 입력해주세요."
        case . deleteBlank:
            return "제목의 앞과 뒤에 공백을 제거해주세요."
        case .limitTitle:
            return "제목은 글자수 10자까지 가능합니다."
        case .limitNickname:
            return "별명은 글자수 10자까지 가능합니다."
        case .warningRecord:
            return "음성에 부적절한 단어가 포함된것으로 판단됩니다. 다시녹음해주세요."
        case .duplicateTitle:
            return "중복된 제목입니다."
        case .duplicateEmail:
            return "중복된 이메일입니다."
        case .duplicateNickname:
            return "중복된 별명입니다.\n다른 별명을 입력해주세요."
        case .unknownError:
            return "죄송합니다. \n서둘러 복구하겠습니다."
        case .reasonReport:
            return "신고 사유를 선택해주세요."
        case .selectCity:
            return "도시를 먼저 선택해주세요."
        case .idToEmail:
            return "아이디를 이메일형식으로 입력해주세요."
        case .passwordNotBlank:
            return "비밀번호는 띄어쓰기 및 빈칸이\n포함될 수 없습니다."
        case .nicknameNotBlank:
            return "별명은 띄어쓰기 및 빈칸이\n포함될 수 없습니다."
        case .emailAndPasswordCheck:
            return "이메일 또는 암호를 확인해주세요."
        case .emailInvalid:
            return "이메일이 유효하지 않습니다."
        case .agreeTerms:
            return "이용약관에 동의해주세요."
        case .agreePrivacy:
            return "개인정보처리방침에 동의해주세요."
        case .numberInValid:
            return "인증번호가 유효하지 않습니다."
        case .passwordInvalid:
            return "비밀번호가 유효하지 않습니다."
        case .currentPasswordInvalid:
            return "현재 비밀번호가 유효하지 않습니다."
        case .passwordNotCheck:
            return "비밀번호가 일치하지 않습니다."
        case .nicknameError:
            return "잘못된 별명입니다.\n다른 별명을 입력해주세요."
        }
        
    }
}

enum AlertSettingType {
    case gps
    case record
    
    var alertTitle: String {
        switch self {
        case .gps:
            return "GPS권한 요청"
        case .record:
            return "녹음권한 요청"
        }
    }
    
    var alertDescription: String {
        switch self {
        case .gps:
            return "현재위치 정보를 얻기 위해 권한을 허용해주세요."
        case .record:
            return "녹음을 위해 권한을 허용해주세요."
        }
    }
}
