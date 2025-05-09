//
//  Components+Ext.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import SwiftMail
import Foundation

/// MARK: Components.Schemas.EmailMessage
extension Components.Schemas.EmailMessage {
    init(message: SwiftMail.Message) {
        self.init(
            sequenceNumber: Int(message.sequenceNumber.value),
            uID: Self.uID(message),
            subject: message.subject,
            from: message.from,
            to: nil,
            date: nil,
            parts: Self.parts(message)
        )
    }
}

extension Components.Schemas.EmailMessage {
    static func uID(_ info: SwiftMail.Message) -> Int? {
        guard let uID = info.uid else { return nil }
        return Int(uID.value)
    }
    
    static func parts(_ message: SwiftMail.Message) -> [Components.Schemas.MessagePart] {
        message.parts.map { Components.Schemas.MessagePart(messagePart: $0) }
    }
}

/// MARK: Components.Schemas.MessagePart
extension Components.Schemas.MessagePart {
    init(messagePart: SwiftMail.MessagePart) {
        self.init(
            section: messagePart.section.description,
            contentType: messagePart.contentType,
            disposition: messagePart.disposition,
            encoding: messagePart.encoding,
            filename: messagePart.filename,
            contentId: messagePart.contentId,
            data: String(data: messagePart.data ?? Data(), encoding: .utf8),
            decodedData: nil
        )
    }
}
