//
//  Extensions.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import Foundation
import SwiftMail

package extension Components.Schemas.MessageInfo {
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
    
    static func uID(_ info: SwiftMail.MessageInfo) -> Int? {
        guard let uID = info.uid else { return nil }
        return Int(uID.value)
    }
    
    static func parts(_ info: SwiftMail.MessageInfo) -> [Components.Schemas.MessagePart] {
        return info.parts.map { part in
            Components.Schemas.MessagePart(
                contentType: part.contentType
            )
        }
    }
}

package extension SwiftMail.MessageInfo {
    init(info: Components.Schemas.MessageInfo) {
        self.init(
            sequenceNumber: SequenceNumber(info.sequenceNumber),
            uid: Self.uID(from: info),
            subject: info.subject,
            from: info.from,
            to: info.to,
            cc: nil,
            date: Self.date(from: info),
            messageId: nil,
            flags: [],
            parts: info.parts.map(Self.convert),
            additionalFields: nil
        )
    }
    
    static func uID(from info: Components.Schemas.MessageInfo) -> UID? {
        guard let uIDInt = info.uID else { return nil }
        return UID(uIDInt)
    }
    
    static func date(from info: Components.Schemas.MessageInfo) -> Date? {
        guard let dateString = info.date else { return nil }
        return EmailServerV1.dateFormatter.date(from: dateString)
    }
    
    static func convert(part: Components.Schemas.MessagePart) -> SwiftMail.MessagePart {
        .init(
            section: [],
            contentType: part.contentType,
        )
    }
}
