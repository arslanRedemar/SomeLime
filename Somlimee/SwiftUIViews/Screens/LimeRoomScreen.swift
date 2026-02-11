//
//  LimeRoomScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct LimeRoomScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: LimeRoomViewModelImpl?
    @State private var currentPage = 0
    let boardName: String

    var body: some View {
        VStack(spacing: 0) {
            LimeRoomNavBarView(
                title: vm?.meta?.limeRoomName ?? boardName,
                onBack: { dismiss() }
            )

            if let tabs = vm?.meta?.limeRoomTabs, !tabs.isEmpty {
                TabSelectorView(
                    tabs: tabs,
                    selectedIndex: .constant(0)
                )
            }

            if let posts = vm?.postList?.list {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(posts.enumerated()), id: \.offset) { _, post in
                            PostCellView(post: post)
                            Divider()
                        }
                    }
                }
            } else if vm?.isLoading == true {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                Spacer()
                Text("No posts yet")
                    .foregroundStyle(.secondary)
                Spacer()
            }

            LimeRoomBottomBar(
                currentPage: currentPage,
                onPageChange: { page in
                    currentPage = page
                    Task { await vm?.loadPostList(boardName: boardName, page: page) }
                }
            )
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(LimeRoomViewModel.self) as? LimeRoomViewModelImpl
            await vm?.loadMeta(boardName: boardName)
            await vm?.loadPostList(boardName: boardName, page: 0)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LimeRoomScreen(boardName: "SDR")
    }
    .previewWithContainer()
}
#endif
