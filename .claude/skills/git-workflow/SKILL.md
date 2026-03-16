---
name: git-workflow
description: Git branching strategy, commit conventions, PR templates, and merge rules for the Somlimee project. Adapted from the Krootl Three-Flow model for a small-team iOS workflow. Use when creating branches, writing commits, opening PRs, or merging code.
---

# Git Workflow

Somlimee 프로젝트 Git 워크플로우. Krootl Three-Flow 모델을 소규모 iOS 프로젝트에 맞게 적용.

## Branch Strategy

```
main (protected)
 ├── release/x.x.x    ← 릴리스 준비
 ├── feature/xxx       ← 기능 개발
 ├── fix/xxx           ← 버그 수정
 └── hotfix/xxx        ← 프로덕션 긴급 수정
```

### Branch Rules

| Branch | Purpose | Merge Target | Protection |
|---|---|---|---|
| `main` | 안정 개발 브랜치 | — | PR 필수, 직접 push 금지 |
| `release/x.x.x` | 릴리스 준비 & QA | `main` (merge back) | PR 필수 |
| `feature/xxx` | 새 기능 개발 | `main` | PR 필수 |
| `fix/xxx` | 버그 수정 | `main` | PR 필수 |
| `hotfix/xxx` | 프로덕션 긴급 수정 | `release/*` → `main` | PR 필수 |

### Branch Naming

```
feature/add-bookmark-screen
feature/improve-search-ux
fix/profile-login-state
fix/post-list-empty
hotfix/crash-on-launch
release/1.2.0
```

- 소문자 + 하이픈 (kebab-case)
- 짧고 명확한 설명 (3-5 단어)
- 이슈 번호가 있으면 접두사: `feature/GH-42-bookmark-screen`

## Commit Message Convention

### Format

```
<type>: <subject>

[optional body]

[optional footer]
```

### Types

| Type | Usage |
|---|---|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 코드 리팩토링 (기능 변경 없음) |
| `style` | 코드 포맷, 세미콜론 등 (기능 변경 없음) |
| `docs` | 문서 변경 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 설정, 의존성 변경 |
| `a11y` | 접근성 개선 |

### Examples

```
feat: 북마크 화면 추가

- BookmarkScreen, BookmarkViewModel 생성
- Route.bookmark 케이스 추가
- DIContainer에 등록

fix: 프로필 패널 로그인 상태 미반영

loadProfile()에서 authRepo.isLoggedIn 직접 확인하도록 수정.
guard vm == nil 제거하여 패널 열릴 때마다 재로드.

Closes #23
```

### Rules

- Subject: 한국어 또는 영어 (프로젝트 내 일관되게)
- Subject 50자 이내, body 72자 줄바꿈
- 명령형 사용: "추가" (O), "추가함" (X), "추가했음" (X)
- Body: "왜" 변경했는지 설명 (what은 코드에서 보임)

## Pull Request

### PR Title Format

```
[type] 간결한 설명
```

Examples:
- `[feat] 북마크 화면 및 UseCase 추가`
- `[fix] 게시글 목록 빈 배열 반환 수정`
- `[refactor] DataSource 싱글톤 제거`

### PR Template

```markdown
## Summary
- 변경 사항 1-3줄 요약

## Changes
- [ ] 구체적 변경 내역

## Test Plan
- [ ] 빌드 성공 확인
- [ ] 영향 받는 화면 동작 확인
- [ ] 다크 모드 확인

## Related
- Closes #이슈번호
- Requirement: HOME-01-03
```

### PR Rules

- **1 PR = 1 기능/수정** — 여러 기능 묶지 않기
- **빌드 통과 필수** — `xcodebuild` 성공 확인
- **requirements-first 스킬 준수** — 요구사항 문서 먼저 업데이트
- **designing-ui 스킬 준수** — UI 변경 시 디자인 시스템 체크

## Merge Rules

| 상황 | 방식 |
|---|---|
| feature → main | Squash merge (커밋 정리) |
| fix → main | Squash merge |
| release → main | Merge commit (`--no-ff`) |
| hotfix → release | Merge commit (`--no-ff`) |
| hotfix → main | Cherry-pick 또는 merge |

### Merge Checklist

1. PR 리뷰 완료
2. 빌드 성공
3. 충돌 해결
4. 요구사항 문서 업데이트 확인
5. `--no-ff` 로 merge (release/hotfix)

## Release Flow

```
1. main에서 release/x.x.x 브랜치 생성
2. release 브랜치에서 QA 진행
3. QA 중 발견된 버그 → release 브랜치에서 수정
4. QA 완료 → main에 --no-ff merge
5. main에 버전 태그: v1.2.0
6. App Store 제출
```

### Version Tagging

```bash
git tag -a v1.2.0 -m "Release 1.2.0: 북마크 기능, 검색 개선"
git push origin v1.2.0
```

Semantic Versioning: `MAJOR.MINOR.PATCH`
- MAJOR: 호환 안 되는 변경
- MINOR: 새 기능 (하위 호환)
- PATCH: 버그 수정

## Rules

**DO:**
- feature 브랜치에서 작업, main에 PR로 merge
- 커밋 메시지에 type 접두사 사용
- PR 제출 전 빌드 확인
- Release 브랜치에서 QA 후 태그

**DON'T:**
- main에 직접 push
- 여러 기능을 하나의 PR에 묶기
- merge 전 빌드 실패 무시
- force push to main/release (hotfix 제외)
- 커밋 메시지에 "수정", "변경" 같은 모호한 단어만 사용
