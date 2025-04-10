//
//  EmailServerV1.swift
//  API
//
//  Created by Steven Prichard on 2025-04-06.
//

@preconcurrency import  SwiftMail
import Foundation
import Hummingbird
import SwiftDotenv
import OpenAPIRuntime
import ServiceLifecycle
import OpenAPIHummingbird

public actor EmailServerV1: APIProtocol {
    public static let rootPath = "api/v1/email"
    public static let searchPath = "\(EmailServerV1.rootPath)/search"
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
        
        let payload = try await imapServer
            .fetchMessageInfo(using: messagesSet)
            .map { Components.Schemas.MessageInfo(info: $0) }
    
        return .ok(
            .init(
                body: .json(
                    .init(payload)
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

extension Components.Schemas.SearchCriteriaQuery {
    func toSearchCriteria() throws -> [SearchCriteria] {
        var criteria: [SearchCriteria] = []
        
        if !self.simple.isEmpty {
            criteria.append(contentsOf: try self.simple.map { try $0.searchCriteria() })
        }
        
        if !self.singleValue.isEmpty {
            criteria.append(contentsOf: try singleValue.map { try $0.searchCriteria() })
        }

        return criteria
    }
}

extension String {
    func searchCriteria() throws -> SearchCriteria {
        switch self {
        case "all":
            return .all
        case "answered":
            return .answered
        case "flagged":
            return .flagged
        case "deleted":
            return .deleted
        case "draft":
            return .draft
        case "new":
            return .new
        case "old":
            return .old
        case "recent":
            return .recent
        case "seen":
            return .seen
        case "unseen":
            return .unseen
        default:
            throw SearchCriteriaErrors.unsupportedSearchCriteria
        }
    }
}

extension Components.Schemas.SingleValueSearch {
    func searchCriteria() throws -> SearchCriteria {
        switch self.criteriaType {
        case .case1(let payload):
            switch payload._type {
            case .dateBefore:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .before(date)
            case .dateOn:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .on(date)
            case .since:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .since(date)
            case .sentOn:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .sentOn(date)
            case .text:
                return .text(self.value)
            case .bodyContaining:
                return .body(value)
            case .from:
                return .from(value)
            case .keyword:
                return .keyword(value)
            case .subject:
                return .subject(value)
            }
        }
    }
}



