---
name: requirements-first
description: Enforces a requirements-first workflow for feature and screen changes. Before modifying code, read the relevant requirement doc in docs/requirements/, update it to reflect the change, then implement. Use when adding, modifying, or removing features, screens, or components.
---

# Requirements-First Workflow

All feature and screen work **must** follow this order:

```
1. Read requirements  →  2. Update requirements  →  3. Implement code
```

Never skip steps 1-2 and go straight to code.

## Step 1: Identify the Relevant Requirement Doc

| Feature Area | Document |
|---|---|
| Login, sign-up, email verification, passwords | `docs/requirements/01-AUTH.md` |
| Home screen, trends, My LimeRoom, today's lime | `docs/requirements/02-HOME.md` |
| LimeRoom (board list, post pagination) | `docs/requirements/03-LIMEROOM.md` |
| Post view, write, vote, comments, report | `docs/requirements/04-POST.md` |
| Personality test (questions, results, report) | `docs/requirements/05-PERSONALITY-TEST.md` |
| Search, trend search results | `docs/requirements/06-SEARCH.md` |
| Profile, my posts, my comments, profile settings | `docs/requirements/07-PROFILE.md` |
| Navigation, side menu, profile panel, notifications | `docs/requirements/08-NAVIGATION.md` |
| App settings (notifications toggle, dark mode) | `docs/requirements/09-SETTINGS.md` |
| Index of all documents | `docs/requirements/README.md` |

If the feature doesn't fit any existing document, create a new one following the naming pattern `NN-FEATURE_NAME.md` and add it to `README.md`.

## Step 2: Read and Understand Current Requirements

Before any code change, read the relevant requirement document(s) to understand:

- What requirements already exist (IDs, descriptions, priorities, statuses)
- The current data flow diagrams
- ViewModel/UseCase interface contracts
- What is implemented vs. not implemented
- Dependencies between features

## Step 3: Update Requirements Before Code

### Adding a new feature or screen

1. Add a new `## F-XXX-NN:` section in the appropriate doc
2. Fill in the requirement table:

```markdown
## F-XXX-NN: Feature Name

**Screen**: `ScreenName`
**Route**: `.routeName`
**ViewModel**: `ViewModelName`

### Requirements

| ID | Description | Priority | Status |
|---|---|---|---|
| XXX-NN-01 | Requirement description | P0 | Pending |
| XXX-NN-02 | Another requirement | P1 | Pending |

### Data Flow

\```
ViewModel.method()
  -> UseCase.execute()
  -> Repository.method()
  -> DataSource.method()
\```

### Dependencies

- List of repositories, use cases, etc.
```

3. If a new Route is needed, add it to the Route table in `08-NAVIGATION.md`
4. If a new ViewModel is needed, add the interface contract

### Modifying an existing feature

1. Find the existing requirement IDs that will change
2. Update the description if behavior changes
3. Add new requirement rows if new behavior is introduced
4. Update the data flow diagram if the flow changes
5. Update the ViewModel/UseCase interface if signatures change

### Removing a feature

1. Change the status to `Removed` (do not delete the row — keep history)
2. Add a note explaining why it was removed

### Status Values

| Status | Meaning |
|---|---|
| `Pending` | Not yet implemented |
| `In Progress` | Currently being implemented |
| `Implemented` | Code complete |
| `UI Only` | UI exists but backend not connected |
| `Removed` | Feature removed from codebase |

### Priority Values

| Priority | Meaning |
|---|---|
| `P0` | Core functionality, must work |
| `P1` | Important but app functional without it |
| `P2` | Nice to have, polish |

## Step 4: Implement Code

Only after the requirement doc is updated, proceed to modify the codebase. During implementation:

- Follow the data flow documented in the requirement
- Match the ViewModel interface contract
- Use the Route name specified in the requirement
- Mark requirement status as `Implemented` after code is complete

## Requirement Doc Format Reference

Every requirement document follows this structure:

```markdown
# NN. Feature Name (Korean)

## Overview

Brief description of the feature area.

---

## F-PREFIX-NN: Sub-feature Name

**Screen**: `ScreenName`
**Route**: `.routeName`
**ViewModel**: `ViewModelName`

### Prerequisites (if any)

- e.g., Login required

### Requirements

| ID | Description | Priority | Status |
|---|---|---|---|

### Data Flow

Code-block showing ViewModel → UseCase → Repository → DataSource chain.

### Data Model (if relevant)

Swift struct showing the entity shape.

### Dependencies

- Repository/UseCase list

---

## ViewModel Interface

Protocol definition for the ViewModel.

---

## UseCase Interface (if relevant)

Protocol definition for the UseCase.
```

## ID Convention

Requirement IDs follow the pattern: `PREFIX-SECTION-SEQUENCE`

| Prefix | Area |
|---|---|
| `AUTH` | Authentication |
| `HOME` | Home screen |
| `LR` | LimeRoom |
| `POST` | Post operations |
| `TEST` | Personality test |
| `SEARCH` | Search |
| `PROF` | Profile |
| `NAV` | Navigation |
| `SET` | Settings |

Example: `AUTH-02-05` = Authentication, section 02 (sign-up), requirement 05.

## Cross-Cutting Changes

If a change spans multiple feature areas:

1. Update **all** affected requirement docs
2. Check the navigation doc (`08-NAVIGATION.md`) for Route changes
3. Verify data flow consistency across documents

## Rules

**DO:**
- Always read the requirement doc before touching code
- Write the requirement change first, then implement
- Keep requirement IDs stable (never renumber existing IDs)
- Add new rows at the end of a section's table
- Update data flow diagrams when plumbing changes
- Update `README.md` when adding new requirement docs

**DON'T:**
- Delete existing requirement rows (mark as `Removed` instead)
- Implement code without updating requirements first
- Change requirement IDs after they've been assigned
- Skip the data flow section for features with backend interaction
- Write requirements in English (use Korean for descriptions, English for IDs and technical terms)
