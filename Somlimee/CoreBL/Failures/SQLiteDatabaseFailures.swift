//
//  SQLiteDatabaseFailures.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/20.
//

import Foundation

enum SQLiteDatabaseFailures: Error{
    case CouldNotConnectDatabase
    case CouldNotCreateCategoryTable
    case CouldNotCreateAppStatesTable
    case CouldNotInsertCategoryRow
    case CouldNotPresentCategoryTable
    case CouldNotInsertAppStatesRow
    case CouldNotPresentAppStatesTable
    case CouldNotUpdateAppStatesTable
    case CouldNotCreateBoardTable
    case CouldNotInsertBoardRow
    case CouldNotPresentBoardTable
}
