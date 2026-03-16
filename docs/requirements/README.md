# Somlimee 요구사항 문서

성격 유형 기반 커뮤니티 앱 **Somlimee(솜라임)**의 기능별 요구사항 명세서입니다.

## 문서 목록

| 문서 | 범위 |
|---|---|
| [01-AUTH.md](./01-AUTH.md) | 인증 (로그인, 회원가입, 이메일 인증, 비밀번호) |
| [02-HOME.md](./02-HOME.md) | 홈 화면 (트렌드, MY라임방, 오늘의 라임, 라임 테스트) |
| [03-LIMEROOM.md](./03-LIMEROOM.md) | 라임룸 (게시판 목록, 게시글 페이지네이션) |
| [04-POST.md](./04-POST.md) | 게시글 (조회, 작성, 추천, 댓글, 신고) |
| [05-PERSONALITY-TEST.md](./05-PERSONALITY-TEST.md) | 성격 테스트 (질문, 결과, 리포트) |
| [06-SEARCH.md](./06-SEARCH.md) | 검색 (전체 검색, 트렌드 검색) |
| [07-PROFILE.md](./07-PROFILE.md) | 프로필 (내 정보, 내 게시글/댓글, 설정) |
| [08-NAVIGATION.md](./08-NAVIGATION.md) | 네비게이션 (사이드 메뉴, 프로필 패널, 알림) |
| [09-SETTINGS.md](./09-SETTINGS.md) | 앱 설정 (알림, 다크모드) |

## 기술 스택

- **플랫폼**: iOS 17+
- **UI 프레임워크**: SwiftUI
- **아키텍처**: Clean Architecture (View → ViewModel → UseCase → Repository → DataSource)
- **DI**: Swinject
- **백엔드**: Firebase (Auth, Firestore, Storage)
- **로컬 DB**: SQLite.swift
- **상태 관리**: @Observable (iOS 17)

## 공통 규칙

- 모든 문자열은 한국어 기본
- 에러 메시지는 사용자 친화적 한국어로 표시
- 로딩 상태 표시 필수 (ProgressView)
- 인증 필요 기능은 미로그인 시 로그인 화면으로 유도
