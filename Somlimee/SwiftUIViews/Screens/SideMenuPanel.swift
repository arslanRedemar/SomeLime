//
//  SideMenuPanel.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct SideMenuPanel: View {
    @Environment(\.diContainer) private var container
    @State private var vm: SideMenuViewModelImpl?
    var onSelect: (Route) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo
            Image("SomeLimeLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - 성격 라임방 Section
                    sectionHeader("성격 라임방")

                    ForEach(BoardRegistry.personalityBoards, id: \.self) { board in
                        menuRow(
                            icon: "person.3.fill",
                            title: board,
                            subtitle: SomeLiMePTTypeDesc.typeDetail[board]
                        ) {
                            onSelect(.limeRoom(boardName: board))
                        }
                        Divider().padding(.leading, 52)
                    }

                    // MARK: - 일반 게시판 Section
                    sectionHeader("일반 게시판")

                    ForEach(BoardRegistry.generalBoards.keys.sorted(), id: \.self) { board in
                        menuRow(
                            icon: BoardRegistry.sfSymbol(for: board) ?? "list.bullet",
                            title: BoardRegistry.shortDisplayName(for: board)
                        ) {
                            onSelect(.limeRoom(boardName: board))
                        }
                        Divider().padding(.leading, 52)
                    }

                    // MARK: - 커뮤니티 Section
                    sectionHeader("커뮤니티")

                    menuRow(icon: "magnifyingglass", title: "검색") {
                        onSelect(.search)
                    }
                    Divider().padding(.leading, 52)

                    menuRow(icon: "flame.fill", title: "인기 트렌드", iconColor: .orange) {
                        onSelect(.trendSearchResult(keyword: "인기"))
                    }
                    Divider().padding(.leading, 52)

                    menuRow(icon: "brain.head.profile", title: "심리 테스트") {
                        onSelect(.psyTestList)
                    }

                    // MARK: - 내 활동 Section (auth-gated)
                    if vm?.isLoggedIn == true {
                        sectionHeader("내 활동")

                        menuRow(icon: "bell.fill", title: "알림") {
                            onSelect(.notifications)
                        }
                        Divider().padding(.leading, 52)

                        menuRow(icon: "doc.text.fill", title: "내 게시글") {
                            onSelect(.userCurrentPosts)
                        }
                        Divider().padding(.leading, 52)

                        menuRow(icon: "bubble.left.fill", title: "내 댓글") {
                            onSelect(.userCurrentComments)
                        }
                    }

                    // MARK: - 설정 Section
                    sectionHeader("설정")

                    menuRow(icon: "gearshape.fill", title: "환경설정") {
                        onSelect(.appSettings)
                    }

                    if vm?.isLoggedIn == true {
                        Divider().padding(.leading, 52)

                        menuRow(icon: "person.crop.circle.fill", title: "프로필 설정") {
                            onSelect(.profileSettings)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // MARK: - Footer
            Divider()
            HStack(spacing: 6) {
                Image(systemName: vm?.isLoggedIn == true ? "person.fill.checkmark" : "person.fill.xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(vm?.isLoggedIn == true ? Color.somLimePrimary : Color.somLimeSystemGray)
                Text(vm?.isLoggedIn == true ? "로그인 상태" : "비로그인 상태")
                    .font(.hanSansNeoRegular(size: 12))
                    .foregroundStyle(Color.somLimeSecondaryLabel)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(Color.somLimeBackground)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(SideMenuViewModel.self) as? SideMenuViewModelImpl
            await vm?.loadMenuList()
            await vm?.loadIsLoggedIn()
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.hanSansNeoBold(size: 11))
            .foregroundStyle(Color.somLimeSecondaryLabel)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }

    // MARK: - Menu Row

    private func menuRow(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = Color.somLimePrimary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
                    .frame(width: 20, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.hanSansNeoMedium(size: 14))
                        .foregroundStyle(Color.somLimeLabel)

                    if let subtitle {
                        Text(subtitle)
                            .font(.hanSansNeoRegular(size: 11))
                            .foregroundStyle(Color.somLimeSecondaryLabel)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    SideMenuPanel(onSelect: { _ in })
        .frame(width: 280)
        .previewWithContainer()
}
#endif
