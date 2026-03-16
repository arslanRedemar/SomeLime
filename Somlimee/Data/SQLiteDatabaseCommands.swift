//
//  LocalDataSourceCommands.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/01.
//

import Foundation
import SQLite
import SQLite3
import os
class SQLiteDatabaseCommands{
    static var categoryTable = Table("Category")
    static var appStatesTable = Table("AppStates")
    static var boardTable = Table("Board")
    //Expressions
    static let categoryName = Expression<String>("categoryName")
    static let boardName = Expression<String>("boardName")
    static let stateName = Expression<String>("stateName")
    static let stateValue = Expression<Bool>("stateValue")
    //Create CategoryTable
    static func createCategoryTable(database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        // if not extists: true - will not create a table
        do{
            try database.run(categoryTable.create(ifNotExists: true){ table in
                table.column(categoryName)
            })
        }catch{
            throw SQLiteDatabaseFailures.CouldNotCreateCategoryTable
        }
    }
    static func createBoardTable(database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        // if not extists: true - will not create a table
        do{
            try database.run(boardTable.create(ifNotExists: true){ table in
                table.column(boardName)
            })
        }catch{
            throw SQLiteDatabaseFailures.CouldNotCreateBoardTable
        }
    }

    static func createAppStatesTable(database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        // if not extists: true - will not create a table
        do{
            try database.run(appStatesTable.create(ifNotExists: true){ table in
                table.column(stateName)
                table.column(stateValue)

            })
        }catch{
            throw SQLiteDatabaseFailures.CouldNotCreateAppStatesTable
        }
    }
    // inserting row
    static func insertCategoryRow(_ values: String, database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            try database.run(categoryTable.insert(categoryName <- values))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {

            Log.data.error("insertCategoryRow: constraint error — \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertCategoryRow

        }catch let error{

            Log.data.error("insertCategoryRow: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertCategoryRow

        }
    }
    static func presentCategoryRows(database: Connection?) async throws -> [String : Any]?{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        let ordered = categoryTable.order(categoryName.desc)
        do {
            var list: [String] = []
            for category in try database.prepare(ordered){
                let name: String = category[categoryName]
                list.append(name)
            }
            return ["list": list]
        } catch{
            Log.data.error("presentCategoryRows: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentCategoryTable
        }
    }
    static func insertBoardRow(_ value: String, database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            try database.run(boardTable.insert(boardName <- value))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {

            Log.data.error("insertBoardRow: constraint error — \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertBoardRow

        }catch let error{

            Log.data.error("insertBoardRow: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertBoardRow

        }
    }

    static func deleteAllBoardRows(database: Connection?) async throws {
        guard let database = database else {
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do {
            try database.run(boardTable.delete())
            Log.data.info("deleteAllBoardRows: success")
        } catch {
            Log.data.error("deleteAllBoardRows: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertBoardRow
        }
    }

    static func presentBoardRows(database: Connection?) async throws -> [String : Any]?{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        let ordered = boardTable.order(boardName.desc)
        do {
            var list: [String] = []
            for category in try database.prepare(ordered){
                let name: String = category[boardName]
                list.append(name)
            }
            return ["list": list]
        } catch{
            Log.data.error("presentBoardRows: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentBoardTable
        }
    }

    static func insertAppStatesRow(name: String, bool: Bool, database: Connection?) async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            // if not extists: true - will not create a table
            try database.run(appStatesTable.insert(stateName <- name, stateValue <- bool))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {

            Log.data.error("insertAppStatesRow: constraint error — \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertAppStatesRow

        }catch let error{

            Log.data.error("insertAppStatesRow: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertAppStatesRow

        }
    }
    static func presentAppStatesData(database: Connection?) async throws -> [String: Bool]?{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do {
            var map: [String: Bool] = [:]
            for t in try database.prepare(appStatesTable){
                let stateName: String = t[stateName]
                let bool: Bool = t[stateValue]
                map[stateName] = bool
            }
            return map
        } catch{
            Log.data.error("presentAppStatesData: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentAppStatesTable
        }
    }
    static func updateAppStates(appStates: AppStatesData, database: Connection?)async throws -> Void{
        guard let database = database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do {

            let isFirstTimeLaunched = appStatesTable.filter(stateName == "isFirstTimeLaunched")
            try database.run(isFirstTimeLaunched.update(stateValue <- appStates.isFirstTimeLaunched))

            let isNeedToUpdateLDS = appStatesTable.filter(stateName == "isNeedToUpdateLocalDataSource")
            try database.run(isNeedToUpdateLDS.update(stateValue <- appStates.isNeedToUpdateLocalDataSource))

            //상태 추가시 여기에 추가

        } catch{
            Log.data.error("updateAppStates: failed — \(error)")
            throw SQLiteDatabaseFailures.CouldNotUpdateAppStatesTable
        }
    }
}
