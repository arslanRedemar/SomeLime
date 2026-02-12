//
//  LocalDataSourceInit.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/20.
//

import Foundation
import SQLite

func localDataSourceInit(database: Connection?) async throws -> Void{
    try await SQLiteDatabaseCommands.createCategoryTable(database: database)
    try await SQLiteDatabaseCommands.createBoardTable(database: database)
    guard let appStates = try await SQLiteDatabaseCommands.presentAppStatesData(database: database) else{
        throw SQLiteDatabaseFailures.CouldNotPresentAppStatesTable
    }
    let isFirstTimeLaunched = appStates["isFirstTimeLaunched"] ?? false
    let isNeedToUpdateLDS = appStates["isNeedToUpdateLocalDataSource"] ?? false
    if isFirstTimeLaunched{

        // Add Categories for the first time.
        try await SQLiteDatabaseCommands.insertCategoryRow("활력성", database: database)
        try await SQLiteDatabaseCommands.insertCategoryRow("결집성", database: database)
        try await SQLiteDatabaseCommands.insertCategoryRow("수용성", database: database)
        try await SQLiteDatabaseCommands.insertCategoryRow("조화성", database: database)
        try await SQLiteDatabaseCommands.insertCategoryRow("무결정", database: database)

        // Add Boards for the first time — personality type codes matching Firestore BoardInfo docs.
        for boardCode in SomeLiMePTTypeDesc.typeDetail.keys.sorted() {
            try await SQLiteDatabaseCommands.insertBoardRow(boardCode, database: database)
        }

        try await SQLiteDatabaseCommands.updateAppStates(appStates: AppStatesData(isFirstTimeLaunched: false, isNeedToUpdateLocalDataSource: false), database: database)
    }else if isNeedToUpdateLDS{
        //update LDS
        // - delete all category or board data
        // - recreate all category or board data

        //update Appstates
        let isNeedToUpdateLocalDataSource = false
        try await SQLiteDatabaseCommands.updateAppStates(appStates: AppStatesData(isFirstTimeLaunched: appStates["isFirstTimeLaunched"] ?? false, isNeedToUpdateLocalDataSource: isNeedToUpdateLocalDataSource), database: database)
        return
    }

}
