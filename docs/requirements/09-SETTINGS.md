# 09. 앱 설정 (Settings)

## 개요

앱 수준 환경 설정. 알림 토글, 다크모드 토글, 앱 버전 표시를 제공한다.

---

## F-SET-01: 앱 설정 화면

**화면**: `AppSettingsScreen`
**Route**: `.appSettings`
**ViewModel**: `AppSettingsViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| SET-01-01 | 댓글 알림 토글 (on/off) | P2 | 구현됨 (로컬 저장) |
| SET-01-02 | 다크모드 토글 (on/off) | P2 | 구현됨 (로컬 저장) |
| SET-01-03 | 앱 버전 정보 표시 | P2 | 구현됨 |
| SET-01-04 | 뒤로가기 버튼 | P0 | 구현됨 |
| SET-01-05 | 설정값 `UserDefaults`에 저장 | P2 | 구현됨 |

### 저장 방식

```swift
// UserDefaults 키
"commentNotificationsEnabled" → Bool
"darkModeEnabled" → Bool
```

### 데이터 흐름

```
AppSettingsViewModel.loadSettings()
  → UserDefaults.standard 읽기

AppSettingsViewModel.saveSettings()
  → UserDefaults.standard 쓰기
```

---

## AppSettingsViewModel 인터페이스

```swift
protocol AppSettingsViewModel {
    var commentNotificationsEnabled: Bool { get set }
    var darkModeEnabled: Bool { get set }
    func loadSettings()
    func saveSettings()
}
```

---

## 미구현 참고 사항

| 기능 | 상태 | 설명 |
|---|---|---|
| 댓글 알림 토글 | UI만 구현 | 실제 FCM 푸시 알림 시스템과 연동되지 않음 |
| 다크모드 토글 | UI만 구현 | 시스템 ColorScheme override 미적용 |
| 언어 설정 | 미구현 | 현재 한국어 고정 |
| 캐시 삭제 | 미구현 | — |
| 로그 전송 | 미구현 | — |
