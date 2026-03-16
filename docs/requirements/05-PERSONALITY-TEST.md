# 05. 성격 테스트 (Personality Test)

## 개요

SomeLiMe 고유 성격 유형 검사 시스템. 4가지 축(활력성/수용성/조화성/결집성)을 5점 리커트 척도로 측정하여 15가지 유형 중 하나를 도출한다. 결과는 Firestore에 저장되며, 유형 코드가 사용자의 라임방(게시판)을 결정한다.

---

## F-TEST-01: 테스트 목록

**화면**: `PsyTestListScreen`
**Route**: `.psyTestList`
**ViewModel**: `PsyTestListViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| TEST-01-01 | 이용 가능한 성격 테스트 카드 목록 표시 | P0 | 구현됨 |
| TEST-01-02 | 각 카드에 테스트명, 설명, 문항수, 예상 소요 시간 표시 | P0 | 구현됨 |
| TEST-01-03 | 카드에 대표 이미지 표시 | P1 | 구현됨 |
| TEST-01-04 | 카드 탭 시 성격 테스트 화면으로 이동 (`.personalityTest`) | P0 | 구현됨 |

### 데이터 모델

```swift
struct PsyTestItem {
    let id: String
    let name: String
    let description: String
    let questionCount: Int
    let estimatedMinutes: Int
    let imageName: String
}
```

---

## F-TEST-02: 성격 테스트 진행

**화면**: `PersonalityTestScreen`
**Route**: `.personalityTest`
**ViewModel**: `PersonalityTestViewModel`

### 전제조건

- 로그인 필수

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| TEST-02-01 | 질문 로드 (`SomLiMeTestBeta.data`에서 가져옴) | P0 | 구현됨 |
| TEST-02-02 | 진행률 바 표시 (현재 문항 / 전체 문항) | P0 | 구현됨 |
| TEST-02-03 | 현재 질문 번호 및 텍스트 표시 | P0 | 구현됨 |
| TEST-02-04 | 5점 리커트 척도 답변 버튼 5개 표시 | P0 | 구현됨 |
| TEST-02-05 | 답변 선택 시 다음 질문으로 자동 이동 | P0 | 구현됨 |
| TEST-02-06 | "이전" 버튼으로 이전 질문 복귀 가능 | P1 | 구현됨 |
| TEST-02-07 | 마지막 질문 답변 시 결과 계산 | P0 | 구현됨 |
| TEST-02-08 | 결과를 Firestore `Users/{uid}`에 저장 | P0 | 구현됨 |
| TEST-02-09 | 테스트 완료 시 완료 상태 표시 | P0 | 구현됨 |

### 리커트 척도

| 값 | 라벨 |
|---|---|
| 1 | 매우 아니다 |
| 2 | 아니다 |
| 3 | 보통이다 |
| 4 | 그렇다 |
| 5 | 매우 그렇다 |

### 결과 계산 로직

```
4가지 축: Strenuousness(활력성), Receptiveness(수용성),
         Harmonization(조화성), Coagulation(결집성)

각 질문은 하나의 축에 대응 → 답변 점수 합산

유형 결정:
  1. 가장 높은 축 선택 → S/R/H/C (동점이면 N=무결정)
  2. 전체 평균 대비 편차 → D(결핍)/R(표준)/E(과잉)
  → 3글자 코드 생성 (예: SDR, HDE, NDD)
```

### Firestore 저장

```swift
Users/{uid}:
  PersonalityTestResult: [Int, Int, Int, Int]  // [S, R, H, C 점수]
  PersonalityType: String                       // 유형 코드 (예: "SDR")
```

### 데이터 흐름

```
PersonalityTestViewModel.loadQuestions()
  → UCRunPsyTest.loadQuestions()
  → QuestionsRepository.getQuestions()
  → DataSource.getQuestions()  // SomLiMeTestBeta.data (로컬)

PersonalityTestViewModel.finishTest()
  → UCRunPsyTest.calculateResult(answers:, categories:)
  → UCRunPsyTest.saveResult(result:, uid:)
  → PersonalityTestRepository.updatePersonalityTest(test:, uid:)
  → DataSource.updateUser(userInfo:)  // Firestore Users/{uid}
```

---

## F-TEST-03: 성격 테스트 결과

**화면**: `PersonalityTestResultScreen`
**Route**: `.personalityTestResult`
**ViewModel**: `ProfileViewModel` (재사용)

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| TEST-03-01 | 유형 아이콘 이미지 표시 (Asset 이미지: SDR, HDE 등) | P1 | 구현됨 |
| TEST-03-02 | 유형 코드 및 한글 유형명 표시 | P0 | 구현됨 |
| TEST-03-03 | 4축 점수를 막대 그래프로 시각화 (PersonalityBarChart) | P0 | 구현됨 |
| TEST-03-04 | 유형 상세 설명 텍스트 표시 | P1 | 구현됨 |
| TEST-03-05 | 뒤로가기 버튼 | P0 | 구현됨 |

### 데이터 흐름

```
ProfileViewModel.loadTestResult()
  → PersonalityTestRepository.getPersonalityTestResult()
  → DataSource.getUserData()  // Firestore Users/{uid}
  → PersonalityTestResult 파싱

ProfileViewModel.loadTestReport()
  → PersonalityTestRepository.getPersonalityTestResult()
  → SomeLiMePTTypeDesc.typeDesc[type] 참조
```

### 데이터 모델

```swift
struct LimeTestResult {
    let str: Int    // Strenuousness (활력성)
    let rec: Int    // Receptiveness (수용성)
    let har: Int    // Harmonization (조화성)
    let coa: Int    // Coagulation (결집성)
    let typeName: String   // 유형 코드 (예: "SDR")
    let typeDesc: String   // 유형 한글 설명
}

struct LimeTestReport {
    let typeName: String
    let typeDetailedReport: String
    let typeImageName: String
}
```

---

## F-TEST-04: 성격 막대 그래프

**컴포넌트**: `PersonalityBarChart`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| TEST-04-01 | 4개 축을 수평 막대 그래프로 표시 | P0 | 구현됨 |
| TEST-04-02 | 각 축에 라벨(S/R/H/C), 수치, 색상 구분 | P0 | 구현됨 |
| TEST-04-03 | 최대값 기준 비율로 막대 길이 결정 | P1 | 구현됨 |
| TEST-04-04 | 색상: S=빨강, R=파랑, H=초록, C=주황 | P1 | 구현됨 |

---

## PersonalityTestViewModel 인터페이스

```swift
protocol PersonalityTestViewModel {
    var questions: [String] { get }
    var categories: [String] { get }
    var answers: [Int] { get }
    var currentIndex: Int { get }
    var isLoading: Bool { get }
    var isCompleted: Bool { get }
    var result: PersonalityTestResultData? { get }
    var errorMessage: String? { get }
    var progress: Double { get }
    var currentQuestion: String { get }
    func loadQuestions() async
    func selectAnswer(_ value: Int) async
    func goBack()
    func finishTest() async
}
```
