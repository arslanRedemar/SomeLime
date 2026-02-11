//
//  DataSourceFailure.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/01.
//

import Foundation

enum DataSourceFailures: Error{
    case CouldNotFindRemoteDataBase
    case CouldNotFindDocument
    case DocumentIsEmpty
    case CouldNotWritePost
}
