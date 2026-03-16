//
//  BoardListRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol BoardListRepository{
    func getBoardListData() async throws -> [String]?
}

class BoardListRepositoryImpl: BoardListRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func getBoardListData() async throws -> [String]? {
        Log.repo.debug("[BoardListRepositoryImpl.getBoardListData] Fetching board list")
        do {
            guard let dataList = try await dataSource.getBoardListData()?["list"] as? [String] else{
                Log.repo.debug("[BoardListRepositoryImpl.getBoardListData] No board list found")
                return nil
            }
            Log.repo.debug("[BoardListRepositoryImpl.getBoardListData] Successfully fetched \(dataList.count) boards")
            return dataList
        } catch {
            Log.repo.error("[BoardListRepositoryImpl.getBoardListData] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
