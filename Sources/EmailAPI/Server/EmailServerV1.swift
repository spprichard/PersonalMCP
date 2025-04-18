//
//  EmailServerV1.swift
//  API
//
//  Created by Steven Prichard on 2025-04-06.
//

import Foundation
import Hummingbird
import SwiftDotenv
import OpenAPIRuntime
import ServiceLifecycle
import OpenAPIHummingbird
@preconcurrency import SwiftMail

public actor EmailServerV1: APIProtocol {
    private let configuration: IMAPConfiguration
    private let imapServer: IMAPServer
    
    public init(imap: IMAPConfiguration) {
        self.configuration = imap
        self.imapServer = IMAPServer(
            host: imap.host,
            port: imap.port
        )
    }
    
    public func setup() async throws {
        try await imapServer.connect()
        try await imapServer.login(
            username: configuration.username,
            password: configuration.password
        )
    }
    
    public func getHealth(_ input: Operations.GetHealth.Input) async throws -> Operations.GetHealth.Output {
        return .ok(
            .init(
                body: .json(
                    .init(
                        status: "Ok"
                    )
                )
            )
        )
    }
    
    // Searches just the message header, without loading all parts of the message
    public func getSearchMessageHeaders() async throws {
        // TODO: just like get search, but with the method below
        //let headers = try await imapServer.fetchMessageInfo(using: messagesSet)
    }
    
    public func getSearch(_ input: Operations.GetSearch.Input) async throws -> Operations.GetSearch.Output {
        let mailboxName = input.query.mailbox
        let _ = try await imapServer.selectMailbox(mailboxName)
        
        guard let rawSearchCriteriaData = input.query.criteria.data(using: .utf8) else {
            fatalError("failed decoding search criteria")
        }
        
        let decodedSearchCriteria = try JSONDecoder()
            .decode(
                Components.Schemas.SearchCriteriaQuery.self,
                from: rawSearchCriteriaData
            )
            .toSearchCriteria()
        
        let messagesSet: MessageIdentifierSet<UID> = try await imapServer.search(criteria: decodedSearchCriteria)
         
        if messagesSet.isEmpty {
            return .ok(
                .init(body: .json(.init()))
            )
        }
        
        let messages = try await imapServer
            .fetchMessages(using: messagesSet, limit: 5) // TODO: Figure out if we want this
            .map { Components.Schemas.EmailMessage(message: $0) }
            
        return .ok(
            .init(
                body: .json(
                    .init(messages)
                )
            )
        )
    }
    
    func decode(uID: UID?) -> Int? {
        guard let uID = uID else { return nil }
        return Int(uID.value)
    }
    
    func decodeParts(_ messageParts: [MessagePart]) -> [Components.Schemas.MessagePart] {
        messageParts
            .map { part in
                Components.Schemas.MessagePart(messagePart: part)
            }
    }
}
