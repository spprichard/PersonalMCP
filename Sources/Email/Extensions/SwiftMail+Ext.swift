//
//  SwiftMail+Ext.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import SwiftMail
import Foundation

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
