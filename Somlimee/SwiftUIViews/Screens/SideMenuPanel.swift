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
                .padding(.horizontal)
                .padding(.bottom, 20)

            Divider()

            if let items = vm?.menuList?.list {
                ForEach(items, id: \.self) { item in
                    Button {
                        onSelect(.limeRoom(boardName: item))
                    } label: {
                        Text(item)
                            .font(.hanSansNeoRegular(size: 16))
                            .foregroundStyle(Color.somLimeLabel)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider().padding(.horizontal)
                }
            }
            Divider()

            // Psychology Tests
            Button {
                onSelect(.psyTestList)
            } label: {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(Color.somLimePrimary)
                    Text("심리 테스트")
                        .font(.hanSansNeoRegular(size: 16))
                        .foregroundStyle(Color.somLimeLabel)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider().padding(.horizontal)

            // Settings
            Button {
                onSelect(.appSettings)
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color.somLimePrimary)
                    Text("환경설정")
                        .font(.hanSansNeoRegular(size: 16))
                        .foregroundStyle(Color.somLimeLabel)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .background(Color.somLimeBackground)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(SideMenuViewModel.self) as? SideMenuViewModelImpl
            await vm?.loadMenuList()
        }
    }
}

#if DEBUG
#Preview {
    SideMenuPanel(onSelect: { _ in })
        .frame(width: 280)
        .previewWithContainer()
}
#endif
