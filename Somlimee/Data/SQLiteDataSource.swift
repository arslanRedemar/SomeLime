//
//  LocalDataSourceService.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation
import SQLite
import os


final class SQLiteDataSource: LocalDataSource{
    var database: Connection?
    var isInit: Bool = false

    init(){
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appending(path:"Somlimee").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
            Log.data.info("SQLiteDataSource: initialized at \(fileUrl.path)")
        } catch{
            Log.data.error("SQLiteDataSource: init failed — \(error.localizedDescription)")
            database = nil
        }
    }

    func appStatesInit() async throws -> Void{
        Log.data.debug("appStatesInit: start")
        try await SQLiteDatabaseCommands.createAppStatesTable(database: database)
        let result = try await SQLiteDatabaseCommands.presentAppStatesData(database: database)
        if result == nil {
            return
        }else{
            if result?["isFirstTimeLaunched"] == false {
                return
            }
        }
        try await SQLiteDatabaseCommands.insertAppStatesRow(name: "isFirstTimeLaunched", bool: true, database: database)
        try await SQLiteDatabaseCommands.insertAppStatesRow(name: "isNeedToUpdateLocalDataSource", bool: false, database: database)
        Log.data.debug("appStatesInit: done")
    }

    func updateAppStates(appStates: AppStatesData) async throws {
        Log.data.debug("updateAppStates: start")
        try await SQLiteDatabaseCommands.updateAppStates(appStates: appStates, database: database)
    }

    func getCategoryData() async throws -> [String : Any]? {
        Log.data.debug("getCategoryData: start")
        do {
            let result = try await SQLiteDatabaseCommands.presentCategoryRows(database: database)
            Log.data.debug("getCategoryData: success")
            return result
        } catch {
            Log.data.error("getCategoryData: failed — \(error.localizedDescription)")
        }
        return nil
    }

    func getBoardListData() async throws -> [String : Any]? {
        Log.data.debug("getBoardListData: start")
        do {
            let result = try await SQLiteDatabaseCommands.presentBoardRows(database: database)
            Log.data.debug("getBoardListData: success")
            return result
        } catch {
            Log.data.error("getBoardListData: failed — \(error.localizedDescription)")
        }
        return nil
    }

    func getAppState() async throws -> [String : Any]? {
        Log.data.debug("getAppState: start")
        return try await SQLiteDatabaseCommands.presentAppStatesData(database: database)
    }
}
