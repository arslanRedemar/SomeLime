//
//  DictionaryDecoder.swift
//  Somlimee
//
//  Created by Chanhee on 2026/02/11.
//

import Foundation

enum DictionaryDecoder {
    static func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(type, from: data)
    }
}
