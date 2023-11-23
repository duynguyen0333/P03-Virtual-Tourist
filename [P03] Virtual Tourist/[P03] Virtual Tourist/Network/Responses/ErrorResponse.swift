//
//  ErrorResponse.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int?
    let message: String?
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
