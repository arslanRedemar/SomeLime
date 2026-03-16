//
//  HomeScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct HomeScreen: View {
    @Environment(\.diContainer) private var container
    @State private var vm: HomeViewModelImpl?
    @State private var notifVM: NotificationViewModelImpl?
    var onMenuTap: () -> Void
    var onNotificationTap: (() -> Void)?
    var onProfileTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeNavBarView(
                    onMenuTap: onMenuTap,
                    onNotificationTap: onNotificationTap,
                    onProfileTap: onProfileTap,
                    hasUnreadNotifications: (notifVM?.unreadCount ?? 0) > 0
                )

                if let error = vm?.errorMessage {
                    Text(error)
                        .font(.hanSansNeoRegular(size: 13))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }

                // 1) My Lime Room card (top priority)
                myLimeRoomSection
                    .padding(.vertical, 12)

                // 2) Browse Lime Rooms
                OtherLimeRoomsSection(rooms: vm?.limeRoomList?.list ?? [])
                    .padding(.vertical, 12)

                // 3) Lime Trends
                if let trends = vm?.trends {
                    LimeTrendSection(trends: trends.list)
                        .padding(.vertical, 12)
                }

                // 4) Lime Today's (general boards with tabs)
                LimesTodaySection()
                    .padding(.vertical, 12)

                // 5) Lime Tests (horizontal scroll)
                LimeTestSection(testList: vm?.psyTestList?.list ?? [])
                    .padding(.vertical, 12)
            }
        }
        .refreshable {
            await vm?.loadTrends()
            await vm?.loadLimeRoomList()
            await vm?.loadPsyTestList()
            await vm?.loadUserStatus()
            await vm?.loadUserTypeName()
            if let name = vm?.userTypeName?.name, !name.isEmpty {
                await vm?.loadMyLimeRoomPostsList(limeRoomName: name)
            }
            await notifVM?.loadNotifications()
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(HomeViewModel.self) as? HomeViewModelImpl
            notifVM = container.resolve(NotificationViewModel.self) as? NotificationViewModelImpl
            await vm?.loadTrends()
            await vm?.loadLimeRoomList()
            await vm?.loadPsyTestList()
        }
        .onAppear {
            Task {
                await vm?.loadUserStatus()
                await vm?.loadUserTypeName()
                if let name = vm?.userTypeName?.name, !name.isEmpty {
                    await vm?.loadMyLimeRoomPostsList(limeRoomName: name)
                }
                await notifVM?.loadNotifications()
            }
        }
    }

    // MARK: - My Lime Room Section

    @ViewBuilder
    private var myLimeRoomSection: some View {
        if let status = vm?.userStatus, status.isLoggedIn {
            let typeName = vm?.userTypeName?.name ?? ""
            if typeName.isEmpty {
                myLimeRoomNeedTestCard
            } else {
                MyLimeRoomLoggedSection(
                    typeName: typeName,
                    posts: vm?.myLimeRoomPostList?.list ?? []
                )
            }
        } else {
            MyLimeRoomNotLoggedSection()
        }
    }

    // MARK: - Need Test Card

    private var myLimeRoomNeedTestCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(Color.somLimePrimary.opacity(0.7))
                .padding(.top, 28)

            VStack(spacing: 6) {
                Text("나의 라임방")
                    .font(.hanSansNeoBold(size: 17))
                    .foregroundStyle(Color.somLimeLabel)

                Text("성격 테스트를 완료하면 나만의 라임방이 열려요")
                    .font(.hanSansNeoRegular(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(value: Route.psyTestList) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 15, weight: .medium))
                    Text("성격 테스트 하기")
                        .font(.hanSansNeoBold(size: 14))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.somLimePrimary.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.somLimeGroupedBackground)
        )
        .padding(.horizontal)
    }
}

#if DEBUG
#Preview {
    HomeScreen(onMenuTap: {}, onNotificationTap: {}, onProfileTap: {})
        .previewWithContainer()
}
#endif
