//
//  RootView.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import SwiftUI
import Swinject
import Combine

struct RootView: View {
    @Environment(\.diContainer) private var container
    @State private var path = NavigationPath()
    @State private var showSideMenu = false
    @State private var showProfile = false
    @State private var authRefreshID = UUID()

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                HomeScreen(
                    onMenuTap: { showSideMenu = true },
                    onNotificationTap: {
                        path.append(Route.notifications)
                    },
                    onProfileTap: { showProfile = true }
                )
                .id(authRefreshID)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .limeRoom(let name):
                        LimeRoomScreen(boardName: name)
                    case .boardPost(let board, let post):
                        BoardPostScreen(boardName: board, postId: post)
                    case .boardPostWrite(let board):
                        BoardPostWriteScreen(boardName: board)
                    case .search:
                        SearchScreen()
                    case .personalityTest:
                        PersonalityTestScreen()
                    case .personalityTestResult:
                        PersonalityTestResultScreen()
                    case .login:
                        LoginScreen()
                    case .signUp:
                        SignUpScreen()
                    case .verifyEmail:
                        VerifyEmailScreen(onVerified: {
                            path.append(Route.personalityTest)
                        })
                    case .profileSettings:
                        ProfileSettingsScreen(onAccountDeleted: {
                            path = NavigationPath()
                        })
                    case .forgotPassword:
                        ForgotPasswordScreen()
                    case .changePassword:
                        ChangePasswordScreen()
                    case .psyTestList:
                        PsyTestListScreen()
                    case .userCurrentPosts:
                        UserCurrentPostsScreen()
                    case .userCurrentComments:
                        UserCurrentCommentsScreen()
                    case .appSettings:
                        AppSettingsScreen()
                    case .trendSearchResult(let keyword):
                        TrendSearchResultScreen(keyword: keyword)
                    case .report(let board, let post):
                        ReportScreen(boardName: board, postId: post)
                    case .notifications:
                        NotificationsScreen()
                    case .home:
                        HomeScreen(
                            onMenuTap: { showSideMenu = true },
                            onNotificationTap: {
                                path.append(Route.notifications)
                            },
                            onProfileTap: { showProfile = true }
                        )
                    }
                }
            }

            // Side menu overlay
            if showSideMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSideMenu = false } }
                    .transition(.opacity)
            }
            if showSideMenu {
                HStack {
                    SideMenuPanel(onSelect: { route in
                        withAnimation { showSideMenu = false }
                        path.append(route)
                    })
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
                    Spacer()
                }
            }

            // Profile overlay
            if showProfile {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showProfile = false } }
                    .transition(.opacity)
            }
            if showProfile {
                HStack {
                    Spacer()
                    ProfilePanel(
                        onNavigate: { route in
                            withAnimation { showProfile = false }
                            path.append(route)
                        },
                        onSignOut: {
                            withAnimation { showProfile = false }
                            path = NavigationPath()
                            authRefreshID = UUID()
                        }
                    )
                    .frame(width: 300)
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSideMenu)
        .animation(.easeInOut(duration: 0.25), value: showProfile)
        .onReceive(NotificationCenter.default.publisher(for: .authStateDidChange)) { _ in
            authRefreshID = UUID()
        }
    }
}

#if DEBUG
#Preview {
    RootView()
        .previewWithContainer()
}
#endif
