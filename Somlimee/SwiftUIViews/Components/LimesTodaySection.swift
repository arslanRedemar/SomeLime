//
//  LimesTodaySection.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct LimesTodaySection: View {
    @Environment(\.diContainer) private var container
    @State private var vm: HomeLimesTodayViewModelImpl?
    @State private var selectedTab = 0
    private let tabs = ["All", "Hot", "New"]

    var body: some View {
        VStack(spacing: 0) {
            TabSelectorView(tabs: tabs, selectedIndex: $selectedTab)

            if let posts = vm?.postList?.list {
                ForEach(Array(posts.enumerated()), id: \.offset) { _, post in
                    PostCellView(post: post)
                    Divider()
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .task {
            guard vm == nil else { return }
            vm = container.resolve(HomeLimesTodayViewModel.self) as? HomeLimesTodayViewModelImpl
            await vm?.loadPostList(boardName: "\u{AD11}\u{C7A5}")
        }
    }
}

#if DEBUG
#Preview {
    LimesTodaySection()
        .previewWithContainer()
}
#endif
