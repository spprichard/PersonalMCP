//
//  Components+Ext.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import SwiftMail
import Foundation

/// MARK: Components.Schemas.MessageInfo
extension Components.Schemas.MessageInfo {
    init(info: SwiftMail.MessageInfo) {
        self.init(
            sequenceNumber: Int(info.sequenceNumber.value),
            uID: Self.uID(info),
            subject: info.subject,
            from: info.from,
            to: nil,
            date: nil,
            parts: Self.parts(info)
        )
    }
}

extension Components.Schemas.MessageInfo {
    static func uID(_ info: SwiftMail.MessageInfo) -> Int? {
        guard let uID = info.uid else { return nil }
        return Int(uID.value)
    }
    
    static func parts(_ info: SwiftMail.MessageInfo) -> [Components.Schemas.MessagePart] {
        info.parts.map { Components.Schemas.MessagePart(messagePart: $0) }
    }
}

/// MARK: Components.Schemas.MessagePart
extension Components.Schemas.MessagePart {
    init(messagePart: SwiftMail.MessagePart) {
        section = messagePart.section.description
        contentType = messagePart.contentType
    }
}
