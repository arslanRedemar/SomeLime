//
//  HomeScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct HomeScreen: View {
    @Environment(\.diContainer) private var container
    @State private var vm: HomeViewModelImpl?
    @State private var selectedTab = 0
    var onMenuTap: () -> Void
    var onProfileTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeNavBarView(onMenuTap: onMenuTap, onProfileTap: onProfileTap)

                // Lime Trends
                if let trends = vm?.trends {
                    LimeTrendSection(trends: trends.list)
                        .padding(.vertical, 8)
                }

                // Tab selector
                TabSelectorView(
                    tabs: ["MY라임방", "오늘의 라임", "라임 테스트"],
                    selectedIndex: $selectedTab
                )

                switch selectedTab {
                case 0:
                    if let status = vm?.userStatus, status.isLoggedIn {
                        MyLimeRoomLoggedSection(
                            typeName: vm?.userTypeName?.name ?? "",
                            posts: vm?.myLimeRoomPostList?.list ?? []
                        )
                    } else {
                        MyLimeRoomNotLoggedSection()
                    }
                case 1:
                    LimesTodaySection()
                case 2:
                    LimeTestSection(testList: vm?.psyTestList?.list ?? [])
                default:
                    EmptyView()
                }

                // Other Lime Rooms
                OtherLimeRoomsSection(rooms: vm?.limeRoomList?.list ?? [])
                    .padding(.vertical, 8)
            }
        }
        .background(Color.somLimeBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(HomeViewModel.self) as? HomeViewModelImpl
            await vm?.loadTrends()
            await vm?.loadUserStatus()
            await vm?.loadUserTypeName()
            await vm?.loadLimeRoomList()
            await vm?.loadPsyTestList()
            if let name = vm?.userTypeName?.name {
                await vm?.loadMyLimeRoomPostsList(limeRoomName: name)
            }
        }
    }
}

#if DEBUG
#Preview {
    HomeScreen(onMenuTap: {}, onProfileTap: {})
        .previewWithContainer()
}
#endif
