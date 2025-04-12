//
//  Email.swift
//  API
//
//  Created by Steven Prichard on 2025-04-03.
//

@preconcurrency import SwiftMail
import Foundation
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient

public struct EmailClient: Sendable {
    public typealias EmailMessage = Components.Schemas.EmailMessage
    private let jsonEncoder: JSONEncoder
    private var client: Client
    
    public init() throws {
        self.jsonEncoder = JSONEncoder()
        let url = try Servers.Server1.url()
        
        self.client = .init(
            serverURL: url,
            transport: AsyncHTTPClientTransport()
        )
    }
    
    public func health() async throws -> Operations.GetHealth.Output {
        try await client.getHealth()
    }
    
    public func search(mailbox: String, with criteria: [SearchCriteria]) async throws -> [EmailMessage] {
        guard !mailbox.isEmpty else {
            throw Errors.missingMailbox
        }
        
        let searchCriteria = try encodeSearchCriteria(criteria)

        let result = try await client.getSearch(
            .init(
                query: .init(
                    mailbox: mailbox,
                    criteria: searchCriteria
                )
            )
        )
        
        switch result {
        case .ok(let response):
            do {
                return try response.body.json.map { $0 }
            } catch let error {
                print("❌ Failed to fetch messages: \(error)")
                return []
            }
            
        case .undocumented(let statusCode, let payload):
            throw Errors.undocumented(statusCode, payload)
        }
    }
    
    
    private func encodeSearchCriteria(_ criteria: [SearchCriteria]) throws -> String {
        let searchCriteriaQuery = SearchCritriaQueryEncoder.encode(criteria: criteria)
        let encodedSearchParameter = try jsonEncoder.encode(searchCriteriaQuery)
        
        guard let searchCriteria = String(data: encodedSearchParameter, encoding: .utf8) else {
            throw Errors.searchCriteriaEncodingFailed
        }
        
        return searchCriteria
    }
}

extension EmailClient {
    enum Errors: Error {
        case missingMailbox
        case searchCriteriaEncodingFailed
        case undocumented(Int, UndocumentedPayload)
    }
}
