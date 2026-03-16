//
//  UCSearchFailures.swift
//  Somlimee
//

import Foundation

enum UCSearchFailures: Error {
    case emptyQuery
    case noBoardsAvailable
    case searchFailed
}
