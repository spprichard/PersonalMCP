//
//  ServerTypes.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import Foundation

enum SearchCriteriaErrors: Error, Sendable {
    case dateDecodingFailed
    case unsupportedPayload
    case unsupportedSearchCriteria
}

public struct IMAPConfiguration {
    public let host: String
    public let port: Int
    public let username: String
    public let password: String
}
