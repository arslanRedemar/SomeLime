//
//  LocalDataSourceService.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation
import SQLite


final class SQLiteDataSource{
    static let sharedInstance = SQLiteDataSource()
    var database: Connection?
    var isInit: Bool = false
    private init(){
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appending(path:"Somlimee").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
        } catch{
            database = nil
        }
    }
}
