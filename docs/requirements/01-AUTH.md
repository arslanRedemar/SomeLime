# 01. 인증 (Authentication)

## 개요

Firebase Auth 기반 이메일/비밀번호 인증 시스템. 회원가입 → 이메일 인증 → 로그인 플로우를 제공한다.

---

## F-AUTH-01: 로그인

**화면**: `LoginScreen`
**Route**: `.login`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| AUTH-01-01 | 이메일 입력 필드 제공 (키보드 타입: email, 자동 대문자 비활성) | P0 | 구현됨 |
| AUTH-01-02 | 비밀번호 입력 필드 제공 (SecureField) | P0 | 구현됨 |
| AUTH-01-03 | "로그인" 버튼 클릭 시 Firebase Auth `signIn(email:password:)` 호출 | P0 | 구현됨 |
| AUTH-01-04 | 로그인 성공 시 이전 화면으로 dismiss | P0 | 구현됨 |
| AUTH-01-05 | 로그인 실패 시 에러 메시지 표시 ("로그인에 실패했습니다") | P0 | 구현됨 |
| AUTH-01-06 | "회원가입" 링크 → `SignUpScreen`으로 네비게이션 | P1 | 구현됨 |
| AUTH-01-07 | "비밀번호 찾기" 링크 → `ForgotPasswordScreen`으로 네비게이션 | P1 | 구현됨 |
| AUTH-01-08 | 로딩 중 버튼 비활성화 및 ProgressView 표시 | P1 | 구현됨 |

### 데이터 흐름

```
LoginScreen → AuthRepository.signIn(email:, password:) → Firebase Auth
```

### 의존성

- `AuthRepository` (DI container에서 resolve)

---

## F-AUTH-02: 회원가입

**화면**: `SignUpScreen`
**Route**: `.signUp`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| AUTH-02-01 | 이메일 입력 필드 제공 | P0 | 구현됨 |
| AUTH-02-02 | 비밀번호 입력 필드 제공 | P0 | 구현됨 |
| AUTH-02-03 | 비밀번호 확인 입력 필드 제공 | P0 | 구현됨 |
| AUTH-02-04 | 비밀번호 불일치 시 "비밀번호가 일치하지 않습니다" 에러 표시 | P0 | 구현됨 |
| AUTH-02-05 | 이메일 미입력 시 "이메일을 입력해주세요" 에러 표시 | P0 | 구현됨 |
| AUTH-02-06 | 비밀번호 6자 미만 시 "비밀번호는 6자 이상이어야 합니다" 에러 표시 | P0 | 구현됨 |
| AUTH-02-07 | 유효성 통과 시 Firebase Auth `createUser(email:password:)` 호출 | P0 | 구현됨 |
| AUTH-02-08 | Auth 생성 성공 후 Firestore `Users/{uid}` 초기 프로필 문서 생성 | P0 | 구현됨 |
| AUTH-02-09 | 초기 프로필: UserName(이메일 앞부분), SignUpDate, Points=0, NumOfPosts=0, ReceivedUps=0, DaysOfActive=0, PersonalityTestResult=[0,0,0,0], PersonalityType="" | P0 | 구현됨 |
| AUTH-02-10 | 프로필 생성 후 이메일 인증 메일 발송 | P0 | 구현됨 |
| AUTH-02-11 | 성공 시 `VerifyEmailScreen`으로 네비게이션 | P0 | 구현됨 |
| AUTH-02-12 | 실패 시 "회원가입에 실패했습니다" 에러 표시 | P0 | 구현됨 |
| AUTH-02-13 | 로딩 중 버튼 비활성화 및 ProgressView 표시 | P1 | 구현됨 |

### 데이터 흐름

```
SignUpScreen
  → AuthRepository.createUser(email:, password:)
  → UserRepository.createInitialProfile(email:)
    → DataSource.updateUser(userInfo:)  // Firestore Users/{uid} 생성
  → AuthRepository.sendEmailVerification()
  → VerifyEmailScreen
```

### 의존성

- `AuthRepository`, `UserRepository` (DI container에서 resolve)

---

## F-AUTH-03: 이메일 인증

**화면**: `VerifyEmailScreen`
**Route**: `.verifyEmail`
**ViewModel**: `VerifyEmailViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| AUTH-03-01 | 이메일 인증 안내 메시지 표시 | P0 | 구현됨 |
| AUTH-03-02 | "인증 확인" 버튼 → Firebase Auth `reloadCurrentUser()` 후 `isEmailVerified` 확인 | P0 | 구현됨 |
| AUTH-03-03 | 인증 완료 시 성격 테스트 화면으로 유도 | P1 | 구현됨 |
| AUTH-03-04 | "인증 메일 재발송" 버튼 제공 | P1 | 구현됨 |
| AUTH-03-05 | 에러/성공 메시지 표시 | P1 | 구현됨 |

### ViewModel 속성

```swift
protocol VerifyEmailViewModel {
    var isVerified: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var successMessage: String? { get }
    func checkVerificationStatus() async
    func resendVerification() async
}
```

---

## F-AUTH-04: 비밀번호 찾기

**화면**: `ForgotPasswordScreen`
**Route**: `.forgotPassword`
**ViewModel**: `ForgotPasswordViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| AUTH-04-01 | 이메일 입력 필드 제공 | P0 | 구현됨 |
| AUTH-04-02 | "비밀번호 재설정 링크 보내기" 버튼 → Firebase Auth `sendPasswordReset(email:)` | P0 | 구현됨 |
| AUTH-04-03 | 성공 시 안내 메시지 표시 | P0 | 구현됨 |
| AUTH-04-04 | 실패 시 에러 메시지 표시 | P0 | 구현됨 |

---

## F-AUTH-05: 비밀번호 변경

**화면**: `ChangePasswordScreen`
**Route**: `.changePassword`
**ViewModel**: `ChangePasswordViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| AUTH-05-01 | 이메일, 현재 비밀번호, 새 비밀번호, 새 비밀번호 확인 입력 필드 | P0 | 구현됨 |
| AUTH-05-02 | 재인증 후 비밀번호 변경 (`reauthenticate` → `updatePassword`) | P0 | 구현됨 |
| AUTH-05-03 | 성공 시 성공 메시지 표시 후 dismiss | P0 | 구현됨 |
| AUTH-05-04 | 실패 시 에러 메시지 표시 | P0 | 구현됨 |

---

## AuthRepository 인터페이스

```swift
protocol AuthRepository {
    var isLoggedIn: Bool { get }
    var currentUserID: String? { get }
    var currentUserEmail: String? { get }
    var isEmailVerified: Bool { get }
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func createUser(email: String, password: String) async throws
    func sendEmailVerification() async throws
    func reloadCurrentUser() async throws
    func sendPasswordReset(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func deleteAccount() async throws
    func reauthenticate(email: String, password: String) async throws
    func addAuthStateListener(_ handler: @escaping (String?) -> Void)
}
```
