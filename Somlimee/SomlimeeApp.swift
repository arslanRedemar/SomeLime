//
//  SomlimeeApp.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import SwiftUI
import FirebaseCore
import Swinject
import os

@main
struct SomlimeeApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var isReady = false
    let container: Container

    init() {
        Log.app.info("SomlimeeApp: init start")
        FirebaseApp.configure()
        Log.app.info("SomlimeeApp: Firebase configured")
        let c = Container()
        DIContainer.setupContainer(c)
        Log.app.info("SomlimeeApp: DI container ready")
        self.container = c
        Task {
            do {
                try await c.resolve(AppStateRepository.self)?.appStatesInit()
                let localDS = c.resolve(LocalDataSource.self) as? SQLiteDataSource
                try await localDataSourceInit(database: localDS?.database)
                Log.app.info("SomlimeeApp: init completed successfully")
            } catch {
                Log.app.error("SomlimeeApp: init failed — \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.diContainer, container)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
