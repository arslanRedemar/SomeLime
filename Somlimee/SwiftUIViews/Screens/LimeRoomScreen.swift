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
    @State private var selectedTab = 0
    @State private var showLoginAlert = false
    let boardName: String

    var body: some View {
        VStack(spacing: 0) {
            LimeRoomNavBarView(
                title: vm?.meta?.limeRoomName ?? boardName,
                onBack: { dismiss() }
            )

            if let error = vm?.errorMessage {
                Text(error)
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            if let tabs = vm?.meta?.limeRoomTabs, !tabs.isEmpty {
                TabSelectorView(
                    tabs: tabs,
                    selectedIndex: $selectedTab
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
                Text("게시글이 없습니다")
                    .font(.hanSansNeoRegular(size: 14))
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
        .overlay(alignment: .bottomTrailing) {
            Group {
                if vm?.isLoggedIn == true {
                    NavigationLink(value: Route.boardPostWrite(boardName: boardName)) {
                        writeButtonLabel
                    }
                } else {
                    Button { showLoginAlert = true } label: {
                        writeButtonLabel
                    }
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 72)
        }
        .alert("로그인 필요", isPresented: $showLoginAlert) {
            NavigationLink("로그인", value: Route.login)
            Button("취소", role: .cancel) {}
        } message: {
            Text("글을 작성하려면 로그인이 필요합니다.")
        }
        .task {
            guard vm == nil else { return }
            vm = container.resolve(LimeRoomViewModel.self) as? LimeRoomViewModelImpl
            await vm?.loadMeta(boardName: boardName)
            await vm?.loadPostList(boardName: boardName, page: 0)
            await vm?.loadIsLoggedIn()
        }
    }

    private var writeButtonLabel: some View {
        Image(systemName: "pencil")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background(Color.somLimePrimary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
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
