//
//  AppSettingsScreen.swift
//  Somlimee
//

import SwiftUI
import Swinject

struct AppSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @State private var vm: AppSettingsViewModelImpl?

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.somLimeLabel)
                }
                Spacer()
                Text("Settings")
                    .font(.hanSansNeoBold(size: 18))
                Spacer()
                Image(systemName: "chevron.left").hidden()
            }
            .padding()
            .background(.ultraThinMaterial)

            List {
                Section {
                    Toggle(isOn: Binding(
                        get: { vm?.commentNotificationsEnabled ?? true },
                        set: { newValue in
                            vm?.commentNotificationsEnabled = newValue
                            vm?.saveSettings()
                        }
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.somLimePrimary)
                            Text("Comment notifications")
                                .font(.hanSansNeoRegular(size: 15))
                        }
                    }
                    .tint(.somLimePrimary)

                    Toggle(isOn: Binding(
                        get: { vm?.darkModeEnabled ?? false },
                        set: { newValue in
                            vm?.darkModeEnabled = newValue
                            vm?.saveSettings()
                        }
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.somLimePrimary)
                            Text("Dark mode")
                                .font(.hanSansNeoRegular(size: 15))
                        }
                    }
                    .tint(.somLimePrimary)
                } header: {
                    Text("Preferences")
                        .font(.hanSansNeoBold(size: 13))
                }

                Section {
                    HStack {
                        Text("Version")
                            .font(.hanSansNeoRegular(size: 15))
                        Spacer()
                        Text("1.0.0")
                            .font(.hanSansNeoLight(size: 14))
                            .foregroundColor(.somLimeSystemGray)
                    }
                } header: {
                    Text("About")
                        .font(.hanSansNeoBold(size: 13))
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color.somLimeGroupedBackground)
        .navigationBarHidden(true)
        .task {
            guard vm == nil else { return }
            vm = container.resolve(AppSettingsViewModel.self) as? AppSettingsViewModelImpl
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AppSettingsScreen()
    }
    .previewWithContainer()
}
#endif
