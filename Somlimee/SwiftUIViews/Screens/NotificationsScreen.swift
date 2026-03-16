//
//  NotificationsScreen.swift
//  Somlimee
//

import SwiftUI

struct NotificationsScreen: View {
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var vm: NotificationViewModelImpl?
    @State private var selectedFilter = 0

    private let filters = ["전체", "댓글", "추천", "언급"]

    private var filtered: [AppNotification] {
        guard let notifications = vm?.notifications else { return [] }
        switch selectedFilter {
        case 1: return notifications.filter { $0.type == .comment || $0.type == .reply }
        case 2: return notifications.filter { $0.type == .upvote }
        case 3: return notifications.filter { $0.type == .mention }
        default: return notifications
        }
    }

    private var unreadCount: Int {
        vm?.unreadCount ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            filterTabs
            notificationList
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(NotificationViewModel.self) as? NotificationViewModelImpl
            await vm?.loadNotifications()
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.somLimeLabel)
                    .frame(width: 36, height: 36)
                    .background(Color.somLimeLightPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel("뒤로 가기")

            Spacer()

            Text("알림")
                .font(.hanSansNeoBold(size: 20))
                .foregroundStyle(Color.somLimeLabel)

            Spacer()

            if unreadCount > 0 {
                Button {
                    Task { await vm?.markAllAsRead() }
                } label: {
                    Text("모두 읽음")
                        .font(.hanSansNeoMedium(size: 12))
                        .foregroundStyle(Color.somLimePrimary)
                }
                .frame(width: 36 + 28, alignment: .trailing)
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.somLimeBackground)
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Filter Tabs

    private var filterTabs: some View {
        HStack(spacing: 6) {
            ForEach(Array(filters.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = index }
                } label: {
                    Text(tab)
                        .font(.hanSansNeoMedium(size: 13))
                        .foregroundStyle(selectedFilter == index ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedFilter == index ? Color.somLimePrimary : Color.somLimeLightPrimary)
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - List

    private var notificationList: some View {
        ScrollView {
            if let error = vm?.errorMessage {

                Text(error)
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            if filtered.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { item in
                        notificationCell(item)
                            .onTapGesture {
                                Task { await vm?.markAsRead(id: item.id) }
                            }
                            .background(
                                NavigationLink(value: notificationRoute(for: item)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            )
                        Divider().padding(.leading, 60)
                    }
                }
            }
        }
        .refreshable {
            await vm?.loadNotifications()
        }
    }

    // MARK: - Cell

    private func notificationCell(_ item: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.isRead ? Color.somLimeSystemGray.opacity(0.2) : Color.somLimeLightPrimary)
                    .frame(width: 40, height: 40)
                Image(systemName: iconName(for: item.type))
                    .font(.system(size: 15))
                    .foregroundStyle(item.isRead ? Color.somLimeSecondaryLabel : Color.somLimePrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.senderName)
                        .font(.hanSansNeoMedium(size: 14))
                        .foregroundStyle(Color.somLimeLabel)

                    if let boardName = item.boardName {
                        Text(boardName)
                            .font(.hanSansNeoMedium(size: 11))
                            .foregroundStyle(Color.somLimePrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.somLimeLightPrimary)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    if !item.isRead {
                        Circle()
                            .fill(Color.somLimePrimary)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(item.message)
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(item.isRead ? Color.somLimeSecondaryLabel : Color.somLimeLabel)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.timestamp)
                    .font(.hanSansNeoLight(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(item.isRead ? Color.somLimeBackground : Color.somLimeLightPrimary.opacity(0.3))
        .contentShape(Rectangle())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.somLimeSystemGray)
            Text("알림이 없습니다")
                .font(.hanSansNeoMedium(size: 15))
                .foregroundStyle(Color.somLimeSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Helpers

    private func iconName(for type: AppNotification.NotificationType) -> String {
        switch type {
        case .comment: "bubble.right"
        case .reply:   "arrowshape.turn.up.left"
        case .upvote:  "arrow.up"
        case .mention: "at"
        }
    }

    private func notificationRoute(for item: AppNotification) -> Route {
        if let boardName = item.boardName, let postId = item.postId {
            return .boardPost(boardName: boardName, postId: postId)
        }
        return .notifications
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        NotificationsScreen()
    }
    .previewWithContainer()
}
#endif
