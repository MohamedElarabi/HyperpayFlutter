//
//  JSONCodable.swift
//  ElMokhtas
//
//  Created by Mohamed Akl on 7/28/20.
//  Copyright © 2020 Youssef. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static func getJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static func getJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static func decodeFromData<U: Codable>(_ model: U.Type, data: Data) throws -> U {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(U.self, from: data)
        } catch let error {
            debugPrint(error)
            throw error
        }
    }
}

