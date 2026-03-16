//
//  LocalDataSource.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/24.
//

import Foundation

protocol LocalDataSource {
    
    func getCategoryData() async throws -> [String : Any]?
    
    func getBoardListData() async throws -> [String: Any]?
    
    func updateAppStates(appStates: AppStatesData) async throws -> Void
    
    func getAppState()async throws -> [String : Any]?
    
    func appStatesInit() async throws -> Void
    
}
