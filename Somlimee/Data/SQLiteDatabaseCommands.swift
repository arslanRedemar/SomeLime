//
//  LocalDataSourceCommands.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/01.
//

import Foundation
import SQLite
import SQLite3
class SQLiteDatabaseCommands{
    static var categoryTable = Table("Category")
    static var appStatesTable = Table("AppStates")
    static var boardTable = Table("Board")
    //Expressions
    static let categoryName = Expression<String>("categoryName")
    static let boardName = Expression<String>("boardName")
    static let stateName = Expression<String>("stateName")
    static let stateValue = Expression<Bool>("stateValue")
    //Ceate CategoryTable
    static func createCategoryTable() async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
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
    static func createBoardTable() async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
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
    
    static func createAppStatesTable() async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
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
    static func insertCategoryRow(_ values: String) async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            try database.run(categoryTable.insert(categoryName <- values))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            
            print("Insert Row Failed: \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertCategoryRow
            
        }catch let error{
            
            print("Insert Row Failed: \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertCategoryRow
            
        }
    }
    static func presentCategoryRows() async throws -> [String : Any]?{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        categoryTable = categoryTable.order(categoryName.desc)
        do {
            var list: [String] = []
            for category in try database.prepare(categoryTable){
                let name: String = category[categoryName]
                list.append(name)
            }
            return ["list": list]
        } catch{
            print("present Category Data error: \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentCategoryTable
        }
    }
    static func insertBoardRow(_ value: String) async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            try database.run(boardTable.insert(boardName <- value))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            
            print("Insert Row Failed: \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertBoardRow
            
        }catch let error{
            
            print("Insert Row Failed: \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertBoardRow
            
        }
    }
    
    static func presentBoardRows() async throws -> [String : Any]?{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        boardTable = boardTable.order(boardName.desc)
        do {
            var list: [String] = []
            for category in try database.prepare(boardTable){
                let name: String = category[boardName]
                list.append(name)
            }
            return ["list": list]
        } catch{
            print("present Board Data error: \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentBoardTable
        }
    }
    
    static func insertAppStatesRow(name: String, bool: Bool) async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do{
            // if not extists: true - will not create a table
            try database.run(appStatesTable.insert(stateName <- name, stateValue <- bool))
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            
            print("Insert Row Failed: \(message), in \(String(describing: statement))")
            throw SQLiteDatabaseFailures.CouldNotInsertAppStatesRow
            
        }catch let error{
            
            print("Insert Row Failed: \(error)")
            throw SQLiteDatabaseFailures.CouldNotInsertAppStatesRow
            
        }
    }
    static func presentAppStatesData() async throws -> [String: Bool]?{
        guard let database = SQLiteDataSource.sharedInstance.database else{
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
            print("present appStates Data error: \(error)")
            throw SQLiteDatabaseFailures.CouldNotPresentAppStatesTable
        }
    }
    static func updateAppStates(appStates: AppStates)async throws -> Void{
        guard let database = SQLiteDataSource.sharedInstance.database else{
            throw SQLiteDatabaseFailures.CouldNotConnectDatabase
        }
        do {
            
            let isFirstTimeLaunched = appStatesTable.filter(stateName == "isFirstTimeLaunched")
            try database.run(isFirstTimeLaunched.update(stateValue <- appStates.isFirstTimeLaunched))
            
            let isNeedToUpdateLDS = appStatesTable.filter(stateName == "isNeedToUpdateLocalDataSource")
            try database.run(isNeedToUpdateLDS.update(stateValue <- appStates.isNeedToUpdateLocalDataSource))
            
            //상태 추가시 여기에 추가
            
        } catch{
            print("update appStates Data error: \(error)")
            throw SQLiteDatabaseFailures.CouldNotUpdateAppStatesTable
        }
    }
}
