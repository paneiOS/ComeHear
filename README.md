# ComeHear

## 목차
- [프로젝트 소개](#프로젝트-소개)
    - [참여자](#참여자)
    - [프로젝트 기간](#프로젝트-기간)
- [📱 구현 화면](#-구현-화면)

- [🌐 Feature-1 Voice Over](#-Feature-1-Voice-Over)
    + [고민한 점](#1-1-고민한-점) 
    + [Trouble Shooting](#1-2-Trouble-Shooting)

- [🗺 Feature-2. 이미지 캐시](#-feature-2-이미지-캐시)
    + [고민한 점](#2-1-고민한-점)
    + [Trouble Shooting](#2-2-Trouble-Shooting)

- [📢 Feature-3. 음성 필터링](#-feature-2-음성-필터링)
    + [고민한 점](#2-1-고민한-점)


## 프로젝트 소개
'시각장애인분들은 여행을 어떻게즐길까?'에서 시작된 프로젝트입니다.
시각장애인분들의 여행을 더욱 즐겁게 만들어드리기 위해 여행지에서의 느낀점을 녹음하여 제공해드리는 서비스입니다.
추가적으로 카카오로그인, 카카오지도, 현재위치를 반영한 검색, 배경음합성, 보이스오버 기능 등을 제공하고있습니다.

### 사용기술 및 라이브러리
- Swift, Objective-C
- AVFoundation, Speech, CoreLocation
- Alamofire, Kingfisher, SnapKit, Hero, Lottie
- KakaoSDKUser, KakaoSDKCommon, KakaoSDKAuth, MapKit

### 참여자
- Pane @kazamajinz, Kedric @KedricKim

### 프로젝트 기간 
- 2022.06.10 - 2022.09.14 (총 3달)

## 📱 구현 화면
|1. 메인화면|2. 느낌저장소|3. 검색화면|4. GPS검색화면|5. 즐겨찾기|6. 마이페이지|
|-|-|-|-|-|-|
|<img width="200" src="https://user-images.githubusercontent.com/62927862/205610298-60553c0d-95b5-4ae4-814c-9710e33a27bd.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205610569-3d13ef21-792f-4f60-bba4-0eabe2e1133a.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205611113-bde50da1-93ec-4e6e-90e7-5f9a43ff4d4f.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205611341-cc53b1aa-9413-4911-878c-6bf943ad048f.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205611552-00039e8f-7286-4083-a773-ab0ffe4513b4.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205611757-c4d5c651-9e89-4e06-8082-b66fd0cc8fc4.gif">|
|||||||
|6. 설명서|7. 듣기화면|8. 녹음화면|9. 영어화면|10. 일본어화면|
|<img width="200" src="https://user-images.githubusercontent.com/62927862/205616612-7f0745cc-0e0b-42b1-baf4-c730c07c1b57.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205618163-9dc7371c-3e22-4c82-ac5d-9ff9eef8395b.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205618215-0444257c-4bf0-4ff4-8608-5931aa355a22.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205618171-d5cc88b2-71b4-47ad-808b-cee9375d9536.gif">|<img width="200" src="https://user-images.githubusercontent.com/62927862/205618223-b30fbc27-9827-4128-8e96-7ac7c156c1a3.gif">|



## 🌐 Feature-1. 누구를 위한 화면을 구현할 것인지?
### 1-1 고민한점
#### 1️⃣ 누구를 위한 화면을 구현할 것인지?
시각장애인을 위한 앱은 매우 단순한 화면으로 구성되어있습니다.
하지만 저희 서비스는 비장애인 이용자들의 데이터를 제공받을수록 장점이 두드러지는 서비스입니다.
그렇기 때문에 2가지의 화면을 준비해야했습니다.

#### 2️⃣ VoiceOver는 어디까지 제공하는지?
2종류의 이용자를 위한 화면을 만들기위해 VoiceOver는 어디까지 제공하는지 파악할 필요가 있었습니다.
그중에서도 특히 UIAccessibility의 isVoiceOverRunning로 VoiceOver 사용자를 판단했고 UIAccessibility의 isAccessibilityElement로 접근을 제어했습니다.
화면이 바뀔때마다 UIAccessibility의 Notification을 이용하여 화면의 변화를 적극적으로 알려줌으로써 최대한 편의성을 제공하였습니다.

### 1-2 Trouble Shooting
#### 1️⃣ VoiceOver의 국적문제(미해결)
영어(다국어)로 앱을 실행할 경우 VoiceOver의 목소리는 원어민의 목소리가 아니었습니다. 이유는 지역이 한국이었기 때문이었습니다.
반대로 캘리포니아 지역으로 설정하고 한국어로 앱을 실행할 경우 문제가 없었습니다.
해당 문제를 해결하기위해 찾아봤지만 지역에 대한 정보를 얻는방법은 있어도 수정이 가능한 방법은 찾을 수 없었습니다.


## 🗺 Feature-2. 이미지 캐시
### 2-1 고민한 점 
#### 1️⃣ 이미지 갱신 데이터 최소화
앱을 재실행할때마다 이미지를 재사용하기 위해 ImageCache에 Key, Value 타입으로 저장함으로써 이미지를 통신으로 가져오는 로직을 최소화하였습니다.

### 2-2 Trouble Shooting
#### 1️⃣ 한국관광공사에서 이미지를 갱신할 경우 문제발생
서버에서 제공하는 이미지가 변경이 되어도 앱에서는 캐시를 기억하고있기 때문에 반영되지 않는 문제가 발생될것으로 예상되었다.
실제로 다른앱과 비교해보니 네이버웹툰의 경우 앱을 실행할때마다 새로 불러왔습니다. 레진 코믹스의 경우에도 캐시를 저장하는것으로 확인되었습니다.
(네이버웹툰은 지원당시 시점이며 여러번 확인함, 지원서에 자사서비스의 장단점을 물어봐서 단점으로 제출하였더니 그 이후부터는 일정시간(?) 유지로 변경되었습니다, 우연일수있습니다.)
해결하기 위해 서버버전을 추가하여 관리하기로 했습니다.


## 📢 Feature-3. 음성 필터링
### 3-1 고민한 점 
#### 1️⃣ 음성 필터링에 대한 고민
녹음 데이터를 필터링하기 위해서 사람이 전부 듣고 판단해서 삭제하는것은 한계가 있습니다.
녹음된 데이터를 Text로 변경하였고 변경된 Text의 단어들을 판별하여 욕설이 포함되어있으면 등록이 불가능하도록 만들었습니다.

