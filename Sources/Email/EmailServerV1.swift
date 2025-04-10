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
        let messagesSet: MessageIdentifierSet<UID> = try await imapServer.search(
            criteria: input.query.criteria.compactMap {
                do {
                    return try $0.toSearchCriteria()
                } catch {
                    print("❌ Search Criteria Error: \(error)")
                    return nil
                }
            }
        )
        
        print("ℹ️ MessageSet Count: \(messagesSet.count)")
        
        if messagesSet.isEmpty {
            return .ok(
                .init(body: .json(.init()))
            )
        }
        
        let payload = try await imapServer
            .fetchMessageInfo(using: messagesSet)
            .map { Components.Schemas.MessageInfo(info: $0) }
    
        print("ℹ️ payload count: \(payload.count)")
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

extension EmailServerV1 {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
}

extension Components.Parameters.CriteriaPayload {
    func toSearchCriteria() throws -> SearchCriteria? {
        do {
            switch self {
            case .case1(let simplePayload):
                return SearchCriteria.decoded(from: simplePayload)
            case .case2(let compoundPayload):
                return try SearchCriteria.decoded(from: compoundPayload)
            case .case3(let multiValuePayload):
                throw SearchCriteriaErrors.unsupportedPayload
            }
        } catch {
            print("⚠️ Error decoding search criteria: \(error)")
            return nil
        }
    }
}

enum SearchCriteriaErrors: Error {
    case dateDecodingFailed
    case unsupportedPayload
    case unsupportedSearchCriteria
}

extension SearchCriteria {
    static func decoded(from payload: Components.Parameters.CriteriaPayload.Case3Payload) -> SearchCriteria {
        switch payload._type {
        case .header:
            return .header(payload.value1, payload.value2)
        }
    }
    
    static func decoded(from payload: Components.Parameters.CriteriaPayload.Case2Payload) throws -> SearchCriteria {
        switch payload._type {
        case .dateBefore:
            guard let date = EmailServerV1.dateFormatter.date(from: payload.value) else {
                throw SearchCriteriaErrors.dateDecodingFailed
            }
            
            return .before(date)
        case .dateOn:
            guard let date = EmailServerV1.dateFormatter.date(from: payload.value) else {
                throw SearchCriteriaErrors.dateDecodingFailed
            }
            
            return .on(date)
        case .since:
            guard let date = EmailServerV1.dateFormatter.date(from: payload.value) else {
                throw SearchCriteriaErrors.dateDecodingFailed
            }
            
            return .since(date)
        case .sentOn:
            guard let date = EmailServerV1.dateFormatter.date(from: payload.value) else {
                throw SearchCriteriaErrors.dateDecodingFailed
            }
            return .sentOn(date)
        case .bodyContaining:
            return .body(payload.value)
        case .from:
            return .from(payload.value)
        case .keyword:
            return .keyword(payload.value)
        case .subject:
            return .subject(payload.value)
        }
    }
    
    static func decoded(from payload: Components.Parameters.CriteriaPayload.Case1Payload) -> SearchCriteria {
        switch payload {
        case .all:
            return .all
        case .answered:
            return .answered
        case .flagged:
            return .flagged
        case .deleted:
            return .deleted
        case .draft:
            return .draft
        case .new:
            return .new
        case .old:
            return .old
        case .recent:
            return .recent
        case .seen:
            return .seen
        case .unseen:
            return .unseen
        }
    }
}

extension Components.Schemas.MessagePart {
    init(messagePart: MessagePart) {
        self.contentType = messagePart.contentType
        // TODO: Complete this
    }
}


public struct IMAPConfiguration {
    public let host: String
    public let port: Int
    public let username: String
    public let password: String
}
