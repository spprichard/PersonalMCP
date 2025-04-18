//
//  MistralAPIFactory.swift
//  API
//
//  Created by Steven Prichard on 2025-04-12.
//

import Foundation
import SwiftDotenv

public enum MistralAPIFactory {
    typealias MistralAPIKey = String
    
    public static func make() throws -> MistralAPIClient {
        return MistralAPIClient(
            apiKey: try loadConfiguration()
        )
    }
    
    private static func loadConfiguration() throws -> MistralAPIKey {
        guard case let .string(mistralAPIKey) = Dotenv["MISTRAL_API_KEY"] else {
            print("❌ Missing or invalid IMAP credentials in .env file")
            throw Errors.invalidConfiguration
        }
        
        return mistralAPIKey
    }
    
    public enum Errors: Error {
        case invalidConfiguration
    }
}
