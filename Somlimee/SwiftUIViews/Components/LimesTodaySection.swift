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

    private let boards: [(id: String, label: String)] = BoardRegistry.generalBoards.keys.sorted().map { key in
        (id: key, label: BoardRegistry.shortDisplayName(for: key))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.somLimeSecondary)
                Text("라임 Today's")
                    .font(.hanSansNeoBold(size: 17))
                    .foregroundStyle(Color.somLimeLabel)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Board tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(boards.enumerated()), id: \.offset) { index, board in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
                            Task { await vm?.loadPostList(boardName: board.id) }
                        } label: {
                            Text(board.label)
                                .font(.hanSansNeoMedium(size: 13))
                                .foregroundStyle(selectedTab == index ? .white : .secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedTab == index ? Color.somLimePrimary : Color.somLimeLightPrimary)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)

            // Posts list
            if vm?.isLoading == true {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 32)
            } else if let posts = vm?.postList?.list, !posts.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(posts.prefix(10).enumerated()), id: \.offset) { index, post in
                        todayPostRow(post)
                        if index < min(posts.count, 10) - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
            } else {
                Text("게시물이 없습니다")
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            }
        }
        .task {
            guard vm == nil else { return }
            vm = container.resolve(HomeLimesTodayViewModel.self) as? HomeLimesTodayViewModelImpl
            if let firstBoard = boards.first {
                await vm?.loadPostList(boardName: firstBoard.id)
            }
        }
    }

    private func todayPostRow(_ post: LimeRoomPostMeta) -> some View {
        NavigationLink(value: Route.boardPost(boardName: post.boardName, postId: post.postID)) {
            HStack(spacing: 8) {
                Text(post.title)
                    .font(.hanSansNeoRegular(size: 14))
                    .foregroundStyle(Color.somLimeLabel)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if post.numOfComments > 0 {
                    Text("[\(post.numOfComments)]")
                        .font(.hanSansNeoBold(size: 12))
                        .foregroundStyle(Color.somLimePrimary)
                }

                Text(RelativeTimeFormatter.string(from: post.publishedTime))
                    .font(.hanSansNeoLight(size: 11))
                    .foregroundStyle(.tertiary)
                    .fixedSize()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    LimesTodaySection()
        .previewWithContainer()
}
#endif
