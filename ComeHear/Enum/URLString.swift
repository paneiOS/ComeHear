//
//  URLString.swift
//  ComeHear
//
//  Created by Pane on 2022/06/23.
//

enum URLString: String {
    case apiURL = "http://comehear-env.eba-8p38k7xm.ap-northeast-2.elasticbeanstalk.com"
    
    enum SubDomain: String {
        case mainAll =  "/api/v1/main/all"
        //검색
        case destinationSearchURL = "/api/v1/tour/place"
    
        //최근검색어
        case searchHistoryURL = "/api/v1/history/search"
        case deleteSearchHistoryURL = "/api/v1/history"
        case allDeleteSearchHistoryURL = "/api/v1/history/member"
    
        //마이페이지
        case signUpURL = "/api/v1/login/signup"
        case loginURL = "/api/v1/login"
        case socialSignupURL = "/api/v1/login/social/signup"
        case socialLoginURL = "/api/v1/login/social"
        case sendAppleTokenURL = "/api/v1/login/social/token"
    
        //회원정보수정
        case secessionURL = "/api/v1/member/withdraw"
        case appleSecessionURL = "/api/v1/login/social/withdraw"
        case nicknameChangeURL = "/api/v1/member/nickname"
        case passwordChangeURL = "/api/v1/member/password"
    
        //공지사항
        case noticeURL = "/api/v1/notice?pageNo=1&pageSize=20000"
    
        //이야기조회
        case storyDetail = "/api/v1/tour/story/detail"
        case storySearchURL = "/api/v1/tour/story"
        case storyLocationSearch = "/api/v1/tour/story/location"
    
        //즐겨찾기
        case favoritePlace = "/api/v1/member/place"
        case favoriteValidate = "/api/v1/member/place/detail"
    
        //느낌조회
        case feelSearchURL = "/api/v1/feel/storage"
        case feelUploadURL = "/api/v1/feel/storage/audio"
        case feelListURL = "/api/v1/feel/storage/detail"
        case feelListTopURL = "/api/v1/feel/top10"
        case feelLikeURL = "/api/v1/member/feel"
        case feelReportURL = "/api/v1/feel/storage/report"
        case feelLikeStorage = "/api/v1/member/feelstorage"
        case feelDeleteURL = "/api/v1/feel/storage/post"
        case emailValidateURL = "/api/v1/email/post"
        case codeValidateURL = "/api/v1/email/cert"
    
        func getURL() -> String {
            return URLString.apiURL.rawValue + self.rawValue
        }
    }
}
