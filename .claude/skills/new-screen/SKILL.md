---
name: new-screen
description: Scaffold a new SwiftUI screen with ViewModel, Route, and DI wiring following Clean Architecture patterns.
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: [ScreenName]
---

# New Screen Scaffold

Create a new SwiftUI screen named `$ARGUMENTS` with all required wiring.

## Files to create

1. **Screen view**: `Somlimee/SwiftUIViews/Screens/$ARGUMENTSScreen.swift`
2. **ViewModel**: `Somlimee/ViewModels/$ARGUMENTSViewModel.swift`

## Files to modify

3. **Route enum**: Add a new case to `Somlimee/SwiftUIViews/Navigation/Route.swift`
4. **RootView**: Add `navigationDestination` for the new route in `Somlimee/SwiftUIViews/RootView.swift`
5. **DIContainer**: Register the ViewModel in `Somlimee/CoreBL/Utils/Configurations/DIContainer.swift`

## Patterns to follow

### ViewModel (`@Observable`, constructor injection)

```swift
import Foundation

protocol $ARGUMENTSViewModel {
    // declare observable properties and methods
}

@Observable
final class $ARGUMENTSViewModelImpl: $ARGUMENTSViewModel {
    // inject repositories or use cases via init
    init(/* dependencies */) { }
}
```

### Screen view (resolve ViewModel from DI container)

```swift
import SwiftUI

struct $ARGUMENTSScreen: View {
    @Environment(\.diContainer) private var container
    @State private var viewModel: (any $ARGUMENTSViewModel)?

    var body: some View {
        // view content
    }
}
```

### Route case

```swift
case screenName  // lowercase camelCase
```

### DI registration

```swift
container.register($ARGUMENTSViewModel.self) { r in
    $ARGUMENTSViewModelImpl(/* resolve dependencies */)
}
```

## Rules

- ViewModel must NOT import UIKit or SwiftUI
- Screen must use `@Environment(\.diContainer)` to resolve the ViewModel
- Follow existing naming conventions in the project
- Read existing screens and ViewModels first to match the exact style
