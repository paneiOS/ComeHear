//
//  Content_URL.swift
//  ComeHear
//
//  Created by Pane on 2022/06/23.
//

// MARK: API URL
let apiURL = "http://comehear-env.eba-8p38k7xm.ap-northeast-2.elasticbeanstalk.com"
let mainAll = apiURL + "/api/v1/main/all"

//검색
let destinationSearchURL = apiURL + "/api/v1/tour/place"

//최근검색어
let searchHistoryURL = apiURL + "/api/v1/history/search"
let deleteSearchHistoryURL = apiURL + "/api/v1/history"
let allDeleteSearchHistoryURL = apiURL + "/api/v1/history/member"

//마이페이지
let signUpURL = apiURL + "/api/v1/login/signup"
let loginURL = apiURL + "/api/v1/login"
let socialSignupURL = apiURL + "/api/v1/login/social/signup"
let socialLoginURL = apiURL + "/api/v1/login/social"
let sendAppleTokenURL = apiURL + "/api/v1/login/social/token"

//회원정보수정
let secessionURL = apiURL + "/api/v1/member/withdraw"
let appleSecessionURL = apiURL + "/api/v1/login/social/withdraw"
let nicknameChangeURL = apiURL + "/api/v1/member/nickname"
let passwordChangeURL = apiURL + "/api/v1/member/password"

//공지사항
let noticeURL = apiURL + "/api/v1/notice?pageNo=1&pageSize=20000"

//이야기조회
let storyDetail = apiURL + "/api/v1/tour/story/detail"
let storySearchURL = apiURL + "/api/v1/tour/story"
let storyLocationSearch = apiURL + "/api/v1/tour/story/location"

//즐겨찾기
let favoritePlace = apiURL + "/api/v1/member/place"
let favoriteValidate = apiURL + "/api/v1/member/place/detail"

//느낌조회
let feelSearchURL = apiURL + "/api/v1/feel/storage"
let feelUploadURL = apiURL + "/api/v1/feel/storage/audio"
let feelListURL = apiURL + "/api/v1/feel/storage/detail"
let feelListTopURL = apiURL + "/api/v1/feel/top10"
let feelLikeURL = apiURL + "/api/v1/member/feel"
let feelReportURL = apiURL + "/api/v1/feel/storage/report"
let feelLikeStorage = apiURL + "/api/v1/member/feelstorage"
let feelDeleteURL = apiURL + "/api/v1/feel/storage/post"
let emailValidateURL = apiURL + "/api/v1/email/post"
let codeValidateURL = apiURL + "/api/v1/email/cert"
