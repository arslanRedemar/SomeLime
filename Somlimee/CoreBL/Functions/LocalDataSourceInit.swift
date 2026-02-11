//
//  LocalDataSourceInit.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/20.
//

import Foundation

func localDataSourceInit()async throws -> Void{
    try await SQLiteDatabaseCommands.createCategoryTable()
    try await SQLiteDatabaseCommands.createBoardTable()
    guard let appStates = try await SQLiteDatabaseCommands.presentAppStatesData() else{
        throw SQLiteDatabaseFailures.CouldNotPresentAppStatesTable
    }
    let isFirstTimeLaunched = appStates["isFirstTimeLaunched"] ?? false
    let isNeedToUpdateLDS = appStates["isNeedToUpdateLocalDataSource"] ?? false
    if isFirstTimeLaunched{
        
        // Add Categories for the first time.
        try await SQLiteDatabaseCommands.insertCategoryRow("유머")
        
        try await SQLiteDatabaseCommands.insertCategoryRow("스포츠")
        
        try await SQLiteDatabaseCommands.insertCategoryRow("정치")
        
        // Add Boards for the first time.
        try await SQLiteDatabaseCommands.insertBoardRow("유머")
        
        try await SQLiteDatabaseCommands.insertBoardRow("스포츠")
        
        try await SQLiteDatabaseCommands.insertBoardRow("정치")
        
        try await SQLiteDatabaseCommands.updateAppStates(appStates: AppStates(isFirstTimeLaunched: false, isNeedToUpdateLocalDataSource: false))
    }else if isNeedToUpdateLDS{
        //update LDS
        // - delete all category or board data
        // - recreate all category or board data
        
        //update Appstates
        let isNeedToUpdateLocalDataSource = false
        try await SQLiteDatabaseCommands.updateAppStates(appStates: AppStates(isFirstTimeLaunched: appStates["isFirstTimeLaunched"] ?? false, isNeedToUpdateLocalDataSource: isNeedToUpdateLocalDataSource))
        return
    }
    
}
