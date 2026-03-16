---
name: deployment-checklist
description: Deployment and App Store submission checklist for the Somlimee project. Covers Firebase rules deployment, build configuration, App Store metadata, TestFlight, and post-launch monitoring. Use when preparing releases, deploying Firebase rules, or submitting to the App Store.
---

# Deployment Checklist

Somlimee 프로젝트 배포 체크리스트. Firebase 배포, TestFlight, App Store 제출.

## Pre-Release Checklist

### 1. Code Freeze

```
[ ] 모든 feature 브랜치 main에 merge 완료
[ ] release/x.x.x 브랜치 생성
[ ] 버전 번호 업데이트 (Info.plist 또는 프로젝트 설정)
    - CFBundleShortVersionString: "1.2.0" (사용자 표시)
    - CFBundleVersion: "42" (빌드 번호, 매 제출마다 증가)
```

### 2. Firebase Deploy

```bash
# Firestore rules 검증
firebase deploy --only firestore:rules --project somlimee

# Storage rules 검증
firebase deploy --only storage --project somlimee

# 검증 후 배포
firebase deploy --only firestore:rules,storage --project somlimee
```

**Rules 배포 전 확인:**
```
[ ] firestore.rules 문법 오류 없음
[ ] storage.rules 문법 오류 없음
[ ] 인증 필수 규칙 유지 (allow read/write: if request.auth != null)
[ ] 테스트 환경에서 먼저 검증
```

### 3. Build Verification

```bash
# Release 빌드
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee \
  -configuration Release build \
  -destination 'generic/platform=iOS'

# Archive
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee \
  -configuration Release archive \
  -archivePath build/Somlimee.xcarchive
```

**빌드 확인:**
```
[ ] Release 빌드 성공
[ ] 경고(warning) 검토 (새 경고 없음)
[ ] Archive 생성 성공
[ ] 시뮬레이터 + 실기기 테스트
```

### 4. QA Testing

```
[ ] 모든 화면 네비게이션 동작 확인
[ ] 로그인/로그아웃 플로우
[ ] 회원가입 → 이메일 인증 → 성격 테스트 → 마이라임방
[ ] 게시글 작성/조회/추천
[ ] 댓글 작성
[ ] 검색 기능
[ ] 프로필 설정 변경
[ ] 신고 기능
[ ] 다크 모드 전체 화면
[ ] VoiceOver 네비게이션 (접근성)
[ ] 메모리 누수 확인 (Instruments)
[ ] 네트워크 오프라인 → 에러 메시지 표시
```

### 5. Crash-Free Verification

```
[ ] Firebase Crashlytics 연동 확인
[ ] TestFlight 내부 테스트 (최소 2일)
[ ] 크래시 리포트 0건
[ ] ANR(App Not Responding) 0건
```

## App Store 제출

### 메타데이터 (한국어)

| 항목 | 값 |
|---|---|
| 앱 이름 | SomLimee (썸라임) |
| 부제 | 성격 유형 기반 커뮤니티 |
| 카테고리 | 소셜 네트워킹 |
| 연령 등급 | 12+ |
| 개인정보 URL | (필수) |
| 지원 URL | (필수) |

### 필수 에셋

```
[ ] 앱 아이콘 (1024x1024, 투명 배경 없음)
[ ] 스크린샷
    - iPhone 6.7" (iPhone 15 Pro Max): 1290x2796
    - iPhone 6.5" (iPhone 11 Pro Max): 1242x2688
    - iPhone 5.5" (iPhone 8 Plus): 1242x2208
    - (선택) iPad Pro 12.9": 2048x2732
[ ] 앱 미리보기 동영상 (선택, 30초 이내)
```

### 심사 정보

```
[ ] 테스트 계정 (이메일/비밀번호) 제공
[ ] 심사 노트: 테스트 계정으로 성격 테스트 완료 상태
[ ] 로그인 필수 기능 설명
[ ] 수출 규정 준수 확인 (암호화 사용 여부)
```

### 제출 전 최종 확인

```
[ ] CFBundleVersion 이전 제출보다 높음
[ ] 모든 URL scheme 등록됨
[ ] GoogleService-Info.plist 프로덕션 환경
[ ] API 키 하드코딩 없음
[ ] #if DEBUG 코드 Release에서 제외 확인
[ ] 더미 데이터/목업 데이터 제거
[ ] console.log / print 디버그 출력 제거
```

## TestFlight

### 내부 테스터

```
1. Xcode → Product → Archive
2. Organizer → Distribute App → TestFlight Internal Only
3. 업로드 완료 후 App Store Connect에서 내부 테스터 그룹 설정
4. 테스터에게 자동 알림
```

### 외부 테스터

```
1. 내부 테스트 완료 후
2. App Store Connect → TestFlight → 외부 테스트 그룹 생성
3. 베타 앱 리뷰 제출 (24-48시간)
4. 승인 후 외부 테스터에게 배포
```

## Post-Launch

### 모니터링 (출시 후 72시간)

```
[ ] Firebase Crashlytics 대시보드 — 크래시 0건 유지
[ ] App Store Connect — 리뷰/평점 모니터링
[ ] Firebase Analytics — DAU/MAU 확인
[ ] 서버 에러율 모니터링
```

### 핫픽스 프로세스

```
1. 크래시 발견 → hotfix/xxx 브랜치 생성 (release에서)
2. 수정 + 테스트
3. release 브랜치에 merge
4. main에도 merge (cherry-pick)
5. 긴급 빌드 → TestFlight → App Store 긴급 심사 요청
```

### 버전 관리 타임라인

```
출시일        v1.0.0
+1주         v1.0.1 (초기 버그 수정)
+1개월       v1.1.0 (피드백 반영 기능 추가)
+3개월       v1.2.0 (주요 기능 업데이트)
```

## Firebase 환경 분리

| 환경 | 용도 | GoogleService-Info.plist |
|---|---|---|
| Development | 개발/테스트 | GoogleService-Info-Dev.plist |
| Production | App Store 배포 | GoogleService-Info.plist |

```bash
# 빌드 설정에서 환경별 plist 복사
# Debug: GoogleService-Info-Dev.plist → GoogleService-Info.plist
# Release: GoogleService-Info-Prod.plist → GoogleService-Info.plist
```

## Rules

**DO:**
- Release 브랜치에서 QA 완료 후 배포
- Firebase rules를 코드와 함께 버전 관리
- TestFlight 내부 테스트 필수
- 출시 후 72시간 Crashlytics 모니터링

**DON'T:**
- main에서 직접 Archive
- Firebase rules 검증 없이 배포
- 빌드 번호 증가 없이 제출
- 테스트 계정 정보 없이 심사 제출
- #if DEBUG 코드가 Release에 포함
