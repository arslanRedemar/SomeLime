//
//  CategoryRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol CategoryRepository{
    func getCategoryData() async throws -> CategoryData?
}

class CategoryRepositoryImpl: CategoryRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func getCategoryData() async throws -> CategoryData? {
        Log.repo.debug("[CategoryRepositoryImpl.getCategoryData] Fetching category data")
        do {
            guard let data = try await dataSource.getCategoryData() else {
                Log.repo.debug("[CategoryRepositoryImpl.getCategoryData] No category data found")
                return nil
            }
            let result = try DictionaryDecoder.decode(CategoryData.self, from: data)
            Log.repo.debug("[CategoryRepositoryImpl.getCategoryData] Successfully fetched category data")
            return result
        } catch {
            Log.repo.error("[CategoryRepositoryImpl.getCategoryData] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
