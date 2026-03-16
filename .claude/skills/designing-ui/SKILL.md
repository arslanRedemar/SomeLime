---
name: designing-ui
description: SomLimee design system + iOS HIG compliance. Enforces project color tokens, SpoqaHanSansNeo typography with Dynamic Type, 8pt spacing grid, Korean localization, component patterns, accessibility, and Apple Human Interface Guidelines. Use when building screens, components, or reviewing UI code.
---

# SomLimee Design System & iOS HIG

SomLimee 프로젝트 전용 디자인 시스템과 Apple HIG를 결합한 가이드.

## Priority Order

1. Apple HIG accessibility requirements (Dynamic Type, VoiceOver, tap targets)
2. SomLimee design tokens & patterns (this file)
3. Apple Human Interface Guidelines (visual & navigation)
4. SwiftUI defaults

> Accessibility is non-negotiable — it always takes priority. For visual styling, project tokens override HIG defaults.

---

## Color Tokens

Use project semantic tokens for branded UI. Never use raw `Color.blue`, `.red`, or hex literals.

| Token | Usage |
|---|---|
| `somLimePrimary` | CTA, active tabs, links, accent icons |
| `somLimeDarkPrimary` | Pressed states, emphasis |
| `somLimeLightPrimary` | Tag/pill backgrounds, icon button fills |
| `somLimeSecondary` | Success, secondary actions |
| `somLimeBackground` | Full-screen background |
| `somLimeGroupedBackground` | Card/section fills |
| `somLimeLabel` | Primary text |
| `somLimeSecondaryLabel` | Captions, metadata |
| `somLimeSystemGray` | Disabled states, dividers |

**Text hierarchy colors** — these system styles are allowed for text opacity levels:
- `.foregroundStyle(.secondary)` — for de-emphasized text (captions, descriptions)
- `.foregroundStyle(.tertiary)` — for stat counts, timestamps, meta info

> These adapt to dark mode automatically and complement `somLime*` tokens.

**Not allowed**: `.foregroundStyle(.primary)` for text — use `Color.somLimeLabel` instead.

Destructive actions: `.red.opacity(0.8)`. Dark mode handled by Asset Catalog automatically.

## Typography

Use `SpoqaHanSansNeo` exclusively via the `hanSansNeo*` Font extensions. **Never use system font styles** (`.body`, `.title`, `.caption`, `.headline`).

All font methods support Dynamic Type via the `relativeTo:` parameter (defaults to `.body`):

| Role | API | Size | relativeTo |
|---|---|---|---|
| Screen title | `.hanSansNeoBold(size:)` | 20 | `.title2` |
| Section header | `.hanSansNeoBold(size:)` | 16 | `.headline` |
| Card title | `.hanSansNeoMedium(size:)` | 15 | `.subheadline` |
| Body / Button label | `.hanSansNeoMedium(size:)` or `.hanSansNeoRegular(size:)` | 14 | `.body` (default) |
| Tab label | `.hanSansNeoMedium(size:)` | 13 | `.subheadline` |
| Caption / Author | `.hanSansNeoRegular(size:)` | 12 | `.caption` |
| Tag / Pill text | `.hanSansNeoMedium(size:)` | 11 | `.caption2` |
| Timestamp | `.hanSansNeoLight(size:)` | 11 | `.caption2` |
| Micro label | `.hanSansNeoRegular(size:)` | 10 | `.caption2` |

For screen titles, use: `.font(.hanSansNeoBold(size: 20, relativeTo: .title2))`.
For body text, the default `relativeTo: .body` is used: `.font(.hanSansNeoRegular(size: 14))`.

> **HIG compliance**: Custom fonts scale with user's Dynamic Type preferences via `Font.custom(_:size:relativeTo:)`.

## Spacing (8pt Grid)

All spacing values must be multiples of 4, preferring multiples of 8.

| Context | Value |
|---|---|
| Screen horizontal padding | 16 |
| Card padding | 16h, 14v |
| Section gap | 8 |
| Nav bar padding | 16h, 10v |
| Form field padding | 40h |
| Capsule button padding | 14h, 10v |
| Full-width button padding | maxWidth .infinity, 14v |
| Inline icon-text gap | 3-4 |
| Tag/pill internal | 8h, 3v |
| Menu row | 20h, 13v |

## Component Patterns

For complete code templates of each component, see [components.md](components.md).

### Card / Cell
`VStack(alignment: .leading, spacing: 10)` with `.padding(.horizontal, 16).padding(.vertical, 14)` on `somLimeBackground`. No borders, use `Divider()` between list items.

### Tag / Pill
`Capsule()` with `somLimeLightPrimary` fill, `somLimePrimary` text, Medium 11pt.

### Tab Selector
`Capsule()` fill toggling between `somLimePrimary` (selected, white text) and `somLimeLightPrimary` (unselected, `.secondary` text). Medium 13pt.

### Nav Bar
`HStack(spacing: 16)` with leading/trailing actions, Spacer, centered title/logo. Background `somLimeBackground` with bottom `Divider()`. Icon buttons: 36x36 Circle with `somLimeLightPrimary` fill. All icon-only buttons must have `.accessibilityLabel()`.

### Primary Button
Full-width: `RoundedRectangle(cornerRadius: 12)` filled `somLimePrimary`, Bold 15pt white text.
Capsule: `.buttonStyle(.borderedProminent).tint(.somLimePrimary)`.

### Menu Row
`HStack(spacing: 12)` with icon (15pt, `somLimePrimary`), title (Medium 14pt), Spacer, chevron.right (12pt). Use `.buttonStyle(.plain)` and `.contentShape(Rectangle())`.

### Stat Item
`HStack(spacing: 3)` with icon (11pt `.medium`) and count (Regular 11pt), `.foregroundStyle(.tertiary)`.

## Elevation

| Level | Usage | Value |
|---|---|---|
| None | List cells | No shadow |
| Subtle | Cards | `.shadow(color: .black.opacity(0.05), radius: 4, y: 2)` |
| Medium | Drawer panels | `.shadow(color: .black.opacity(0.15), radius: 10, x: -4, y: 0)` |
| Strong | Floating actions | `.shadow(color: .black.opacity(0.25), radius: 8, y: 4)` |

## Corner Radius

| Element | Value |
|---|---|
| Cards / Sections | `RoundedRectangle(cornerRadius: 12)` |
| Buttons | `RoundedRectangle(cornerRadius: 10)` or `12` |
| Tags / Tabs | `Capsule()` |
| Avatars / Icon buttons | `Circle()` |

## Icons

SF Symbols only for UI chrome. Custom assets only for: app logo, user avatars, test type illustrations.
For the full icon mapping table, see [icons.md](icons.md).

Key sizing: Nav bar icons 20pt `.medium`, inline stat icons 11pt `.medium`, menu icons 15pt, chevrons 12pt `.medium`.

**SF Symbols advanced usage:**

```swift
// Symbol with rendering mode
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)

// Symbol effect (iOS 17+)
Image(systemName: "bell.fill")
    .symbolEffect(.bounce, value: notificationCount)
```

## Animation

| Trigger | Animation |
|---|---|
| Tab switch | `.easeInOut(duration: 0.2)` |
| Overlay show/hide | `.easeInOut(duration: 0.25)` |
| State toggle | `.spring(duration: 0.3)` |

Always use `withAnimation { }` for user-triggered state changes. No animation on data loads.

## Navigation

- `.navigationBarHidden(true)` on all screens. Custom nav bars only.
- Back navigation via `@Environment(\.dismiss)`.
- All routing via `NavigationLink(value: Route.xxx)` or `path.append(Route.xxx)`.
- Side menu (280pt, leading) and profile panel (300pt, trailing) are `ZStack` overlays, not nav destinations.
- Dismiss overlays via dimming backdrop (`Color.black.opacity(0.3)`) tap.
- Use `.sheet()` for transient modal actions (confirmations, alerts, quick input). Do NOT use `.sheet()` for content navigation — use Route enum instead.

> **HIG note**: Apple's `NavigationStack` pattern is used, but system nav bars are hidden in favor of custom implementations to match the design system.

## SwiftUI Layout Patterns

### Stack-Based Layouts

```swift
VStack(alignment: .leading, spacing: 12) {
    Text("Title")
        .font(.hanSansNeoBold(size: 16, relativeTo: .headline))
    Text("Subtitle")
        .font(.hanSansNeoRegular(size: 13))
        .foregroundStyle(.secondary)
}
```

### Grid Layouts

```swift
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 150, maximum: 200))
], spacing: 16) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

### Materials (blur effects)

```swift
Text("Overlay")
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
```

## Safe Areas

- Respect system safe areas. Do NOT use `.ignoresSafeArea()` unless for full-bleed backgrounds.
- Use `safeAreaInset` for sticky headers/footers instead of hardcoded bottom padding.
- Screen horizontal padding (16pt) is applied inside the safe area, not in place of it.

## Screen Template

```swift
struct XxxScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Custom nav bar
                // Content sections
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
    }
}
```

## Localization

All user-facing strings must be in Korean.
For the full translation table, see [localization.md](localization.md).

## Accessibility (HIG)

Accessibility is a **mandatory** requirement, not optional polish.

- **Tap targets**: Ensure 44x44pt minimum on all interactive elements
- **Accessibility labels**: Add `.accessibilityLabel("한국어 설명")` on ALL icon-only buttons (back, close, menu, search, send, etc.)
- **Accessibility hints**: Use `.accessibilityHint()` for non-obvious interactions
- **Hit areas**: Use `.contentShape(Rectangle())` on tappable rows to expand hit area
- **Dynamic Type**: All custom fonts use `relativeTo:` for automatic scaling
- **VoiceOver**: Test with VoiceOver enabled — every screen must be navigable

### Standard Accessibility Labels

| Button | Label |
|---|---|
| Back (chevron.left) | `"뒤로 가기"` |
| Close (xmark) | `"닫기"` |
| Menu (line.3.horizontal) | `"메뉴"` |
| Notification (bell) | `"알림"` |
| Profile (person.circle.fill) | `"프로필"` |
| Search (magnifyingglass) | `"검색"` |
| Send (paperplane.fill) | `"댓글 전송"` |
| Report (exclamationmark.triangle) | `"신고"` |
| Remove image (xmark.circle.fill) | `"이미지 삭제"` |
| Previous page | `"이전 페이지"` |
| Next page | `"다음 페이지"` |

## State Restoration

Use `@SceneStorage` for preserving user state across app launches:

```swift
@SceneStorage("selectedTab") private var selectedTab = 0
```

Preserve: selected tab index, scroll positions, form input drafts.

## iPad Considerations

The app currently targets iPhone. When building new views:
- Prefer flexible layouts (`adaptive` grid items, `maxWidth: .infinity`) over fixed widths
- Avoid hardcoded frame sizes that break on larger screens
- Use `horizontalSizeClass` if iPad-specific layouts are needed in the future

## Gradient Usage

Gradients (`.gradient`) are allowed only for:
- **Brand CTA buttons** — primary action buttons (personality test CTA, sign-up CTA)
- **Chart visualizations** — personality bar charts, test result graphics

Do NOT use gradients on: submit buttons in forms, standard navigation elements, non-brand UI.

## Rules

**DO:**
- Use SomLimee color tokens for branded UI elements
- Use `.foregroundStyle(.secondary)` / `.foregroundStyle(.tertiary)` for text hierarchy
- Use `SpoqaHanSansNeo` fonts exclusively (never `.body`, `.headline`, `.caption`)
- Use `Capsule()` for tags and tab selectors
- Use `.contentShape(Rectangle())` on tappable rows
- Use `Divider()` between list items
- Use `foregroundStyle` over `foregroundColor`
- Ensure 44x44pt minimum tap targets
- Add `.accessibilityLabel()` on ALL icon-only buttons
- Use `LazyVStack`/`LazyHStack` for long scrolling lists
- Ensure `NavigationLink` values are `Hashable`
- Test views in both light and dark `#Preview`
- Use `.sheet()` for transient modals (confirmation, alerts)

**DON'T:**
- Use raw colors (`.blue`, `.red`) or system font styles (`.body`, `.headline`, `.caption`)
- Use `.foregroundStyle(.primary)` for text — use `Color.somLimeLabel`
- Add borders on cards
- Use `.sheet()` for content navigation (use Route enum)
- Put padding on items when parent already provides it
- Use UIKit in SwiftUI view files
- Use gradients on non-brand UI elements
- Use `.fixedSize()` liberally — prefer flexible layouts
- Hardcode colors — use asset catalog colors for dark mode
- Ship icon-only buttons without `.accessibilityLabel()`
- Use `.ignoresSafeArea()` unless for full-bleed backgrounds

## Common Issues

- **Layout Breaking**: Use `.fixedSize()` sparingly; prefer flexible layouts
- **Performance**: Use `LazyVStack`/`LazyHStack` for long scrolling lists
- **Navigation Bugs**: Ensure `NavigationLink` values are `Hashable`
- **Dark Mode**: All `somLime*` tokens auto-adapt via Asset Catalog
- **Memory Leaks**: Watch for strong reference cycles in closures
- **Accessibility**: Missing `.accessibilityLabel()` on icon buttons — VoiceOver cannot describe the action

## Resources

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SF Symbols App](https://developer.apple.com/sf-symbols/)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)
