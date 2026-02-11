//
//  ProfilePanel.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct ProfilePanel: View {
    @Environment(\.diContainer) private var container
    @State private var vm: ProfileViewModelImpl?
    var onNavigate: (Route) -> Void
    var onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let profile = vm?.userProfile {
                ProfileCardView(profile: profile)
            }
            if let result = vm?.testResult {
                ProfileTestResultView(result: result)
            }

            Divider().padding(.vertical, 8)

            Button {
                onNavigate(.profileSettings)
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }

            Button("My Posts") { onNavigate(.userCurrentPosts) }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("My Comments") { onNavigate(.userCurrentComments) }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Divider().padding(.vertical, 8)

            Button(action: {
                vm?.signOut()
                onSignOut()
            }) {
                Text("Sign Out")
                    .font(.hanSansNeoBold(size: 15))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .padding(.top, 60)
        .background(Color.somLimeBackground)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(ProfileViewModel.self) as? ProfileViewModelImpl
            await vm?.loadProfile()
            await vm?.loadTestResult()
        }
    }
}
