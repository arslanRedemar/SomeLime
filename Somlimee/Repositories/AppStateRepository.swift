//
//  AppStateRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol AppStateRepository {
    func appStatesInit() async throws -> Void
    func updateAppStates(appStates: AppStatesData) async throws
}

class AppStateRepositoryImpl: AppStateRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }
    func appStatesInit() async throws -> Void {
        Log.repo.info("[AppStateRepositoryImpl.appStatesInit] Initializing app states")
        do {
            try await dataSource.appStatesInit()
            Log.repo.info("[AppStateRepositoryImpl.appStatesInit] App states initialized successfully")
        } catch {
            Log.repo.error("[AppStateRepositoryImpl.appStatesInit] Failed — \(error.localizedDescription)")
            throw error
        }
    }
    func updateAppStates(appStates: AppStatesData) async throws {
        Log.repo.info("[AppStateRepositoryImpl.updateAppStates] Updating app states")
        do {
            try await dataSource.updateAppStates(appStates: appStates)
            Log.repo.info("[AppStateRepositoryImpl.updateAppStates] App states updated successfully")
        } catch {
            Log.repo.error("[AppStateRepositoryImpl.updateAppStates] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
