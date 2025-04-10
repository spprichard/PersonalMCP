//
//  EmailServerFactory.swift
//  API
//
//  Created by Steven Prichard on 2025-04-07.
//

import Foundation
import Hummingbird
import SwiftDotenv

public enum EmailServerFactory {
    @discardableResult
    public static func makeV1(on router: Router<BasicRequestContext>) throws -> EmailServerV1 {
        let configuration = try loadConfiguration()
        
        let emailServer = EmailServerV1(imap: configuration)
        try emailServer.registerHandlers(on: router)
        
        return emailServer
    }
    
    private static func loadConfiguration() throws -> IMAPConfiguration {
        // Get IMAP credentials
        guard case let .string(host) = Dotenv["IMAP_HOST"],
              case let .integer(port) = Dotenv["IMAP_PORT"],
              case let .string(username) = Dotenv["IMAP_USERNAME"],
              case let .string(password) = Dotenv["IMAP_PASSWORD"] else {
            throw Errors.failedToLoadConfiguration
        }
        
        return .init(
            host: host,
            port: port,
            username: username,
            password: password
        )
    }
    
    enum Errors: Error {
        case failedToLoadConfiguration
    }
}
