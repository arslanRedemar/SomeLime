# Component Code Templates

## Card / Cell

```swift
VStack(alignment: .leading, spacing: 10) {
    // Header: tag + timestamp
    HStack(spacing: 6) {
        Text(tag)
            .font(.hanSansNeoMedium(size: 11))
            .foregroundStyle(Color.somLimePrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.somLimeLightPrimary)
            .clipShape(Capsule())
        Spacer()
        Text(timestamp)
            .font(.hanSansNeoLight(size: 11))
            .foregroundStyle(.tertiary)
    }

    // Title
    Text(title)
        .font(.hanSansNeoMedium(size: 15))
        .foregroundStyle(Color.somLimeLabel)
        .lineLimit(2)

    // Footer: author + stats
    HStack(spacing: 0) {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 13))
            .foregroundStyle(.quaternary)
        Text(authorName)
            .font(.hanSansNeoRegular(size: 12))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
        Spacer()
        HStack(spacing: 14) {
            statItem(icon: "arrow.up", count: votes)
            statItem(icon: "bubble.right", count: comments)
            statItem(icon: "eye", count: views)
        }
    }
}
.padding(.horizontal, 16)
.padding(.vertical, 14)
.background(Color.somLimeBackground)
```

## Tag / Pill

```swift
Text(label)
    .font(.hanSansNeoMedium(size: 11))
    .foregroundStyle(Color.somLimePrimary)
    .padding(.horizontal, 8)
    .padding(.vertical, 3)
    .background(Color.somLimeLightPrimary)
    .clipShape(Capsule())
```

## Tab Selector

```swift
HStack(spacing: 6) {
    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedIndex = index }
        } label: {
            Text(tab)
                .font(.hanSansNeoMedium(size: 13))
                .foregroundStyle(selectedIndex == index ? .white : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedIndex == index ? Color.somLimePrimary : Color.somLimeLightPrimary)
                )
        }
    }
    Spacer()
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
```

## Navigation Bar

```swift
HStack(spacing: 16) {
    Button(action: leadingAction) {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.somLimeLabel)
            .frame(width: 36, height: 36)
            .background(Color.somLimeLightPrimary)
            .clipShape(Circle())
    }
    Spacer()
    // Center: title or logo
    Spacer()
    Button(action: trailingAction) {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.somLimePrimary)
            .frame(width: 36, height: 36)
            .background(Color.somLimeLightPrimary)
            .clipShape(Circle())
    }
}
.padding(.horizontal, 16)
.padding(.vertical, 10)
.background(Color.somLimeBackground)
.overlay(alignment: .bottom) { Divider() }
```

## Primary Button (Full Width)

```swift
Button(action: action) {
    Text("label")
        .font(.hanSansNeoBold(size: 15))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.somLimePrimary))
}
.padding(.horizontal, 40)
```

## Primary Button (Capsule)

```swift
Button("label") { action() }
    .buttonStyle(.borderedProminent)
    .tint(Color.somLimePrimary)
```

## Stat Item

```swift
private func statItem(icon: String, count: Int) -> some View {
    HStack(spacing: 3) {
        Image(systemName: icon)
            .font(.system(size: 11, weight: .medium))
        Text("\(count)")
            .font(.hanSansNeoRegular(size: 11))
    }
    .foregroundStyle(.tertiary)
}
```

## Menu Row

```swift
Button(action: action) {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 15))
            .foregroundStyle(Color.somLimePrimary)
            .frame(width: 24, alignment: .center)
        Text(title)
            .font(.hanSansNeoMedium(size: 14))
            .foregroundStyle(Color.somLimeLabel)
        Spacer()
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.somLimeSecondaryLabel)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 13)
    .contentShape(Rectangle())
}
.buttonStyle(.plain)
```

## Profile Stat (Vertical)

```swift
VStack(spacing: 2) {
    Text("\(value)")
        .font(.hanSansNeoBold(size: 14))
        .foregroundStyle(Color.somLimeLabel)
    Text(label)
        .font(.hanSansNeoRegular(size: 10))
        .foregroundStyle(Color.somLimeSecondaryLabel)
}
.frame(maxWidth: .infinity)
```

Separated by 1pt vertical divider:
```swift
Rectangle()
    .fill(Color.somLimeSecondaryLabel.opacity(0.3))
    .frame(width: 1, height: 24)
```

## Drawer Overlay

```swift
// Dimming backdrop
Color.black.opacity(0.3)
    .ignoresSafeArea()
    .onTapGesture { withAnimation { showOverlay = false } }
    .transition(.opacity)

// Slide-in panel
Panel()
    .frame(width: 280)  // Side menu: 280, Profile: 300
    .transition(.move(edge: .leading))  // or .trailing
```

## Input Field

```swift
TextField("placeholder", text: $value)
    .textFieldStyle(.roundedBorder)
    .padding(.horizontal, 40)
```

## Grouped Section Card

```swift
VStack(spacing: 8) {
    // content
}
.padding(12)
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.somLimeGroupedBackground)
)
```
