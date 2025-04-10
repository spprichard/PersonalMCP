//
//  Email.swift
//  API
//
//  Created by Steven Prichard on 2025-04-03.
//

import SwiftMail
import Foundation
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient

public struct EmailClient: Sendable {
    private var client: Client
    
    public init() throws {
        let url = try Servers.Server1.url()
        print("ℹ️ Creating client with url: \(url)")
        
        self.client = .init(
            serverURL: url,
            transport: AsyncHTTPClientTransport()
        )
    }
    
    public func health() async throws -> Operations.GetHealth.Output {
        try await client.getHealth()
    }
    
    public func search(mailbox: String, with criteria: [SearchCriteria]) async throws -> [MessageInfo] {
        guard !mailbox.isEmpty else {
            throw Errors.missingMailbox
        }
                
        let result = try await client.getSearch(
            .init(
                query: .init(
                    mailbox: mailbox,
                    criteria: try encode(criteria)
                )
            )
        )
        
        switch result {
        case .ok(let response):
            do {
                return try response.body.json.map { MessageInfo(info: $0) }
            } catch let error {
                print("❌ Failed to fetch messages: \(error)")
                return []
            }
            
        case .undocumented(let statusCode, let payload):
            throw Errors.undocumented(statusCode, payload)
        }
    }
    
    private func encode(_ criteria: [SearchCriteria]) throws -> [Components.Parameters.CriteriaPayload]  {
        try criteria.map { criteria in
            switch criteria {
            case .all:
                return .case1(.all)
            case .answered:
                return .case1(.answered)
            case .flagged:
                return .case1(.flagged)
            case .deleted:
                return .case1(.deleted)
            case .draft:
                return .case1(.draft)
            case .new:
                return .case1(.new)
            case .old:
                return .case1(.old)
            case .recent:
                return .case1(.recent)
            case .seen:
                return .case1(.seen)
            case .unseen:
                return .case1(.unseen)
            default:
                throw SearchCriteriaErrors.unsupportedSearchCriteria
            }
        }
    }
}



extension EmailClient {
    enum Errors: Error {
        case missingMailbox
        case undocumented(Int, UndocumentedPayload)
    }
}
