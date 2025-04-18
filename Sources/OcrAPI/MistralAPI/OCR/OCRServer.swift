//
//  OCRServer.swift
//  API
//
//  Created by Steven Prichard on 2025-04-15.
//

import EmailAPI
import SwiftMail
import Foundation

struct OCRServerV1: APIProtocol, Sendable {
    let emailProvider: EmailClient
    let ocrProvider: OCRProviding
    
    init(
        emailProvider: EmailClient,
        ocrProviding: OCRProviding
    ) {
        self.emailProvider = emailProvider
        self.ocrProvider = ocrProviding
    }
    
    enum Errors: Error {
        case noEmailFound
        case noPDFFound
        case failedDecodingMessage
        case failedDecodingData
    }
    
    func ocrEmail(_ input: Operations.OcrEmail.Input) async throws -> Operations.OcrEmail.Output {
        guard case .json(let details) = input.body else {
            return .badRequest(
                .init(
                    body: .json(
                        .init(
                            error: "Failed to decode request body"
                        )
                    )
                )
            )
        }
        
        // TODO: Should use search headers
        guard let part = try await emailProvider.search(
            mailbox: details.mailbox,
            with: [
                .uid(details.uID)
            ]
        ).first(where: { header in
            let matchingPart = header
                .parts
                .first(where: {
                    let sectionMatches = Section($0.section) == Section(details.section)
                    let isPDF = $0.contentType == "application/pdf"
                    
                    return sectionMatches && isPDF
                })
            
            let isSequenceNumberMatching = header.sequenceNumber == details.sequenceNumber
            let isMessagePartValid = matchingPart != nil
            
            return isSequenceNumberMatching && isMessagePartValid
        })?.parts.first(where: { $0.contentType == "application/pdf" })
        else {
            return .notFound(
                .init(
                    body: .json(
                        .init(error: "Could not find attachment matching criteria")
                    )
                )
            )
        }
    
        
        guard let messageData = part.data?.data(using: .utf8) else {
            // I think this would return a 500?
            throw Errors.failedDecodingMessage
        }

        guard let decodedData = Data(
            base64Encoded: messageData,
            options: [.ignoreUnknownCharacters]
        ) else {
            throw Errors.failedDecodingData
        }
        
        let result = try await ocrProvider.ocr(fileData: decodedData)
        
        var contents: String = ""
        for page in result.pages {
            contents.append(page.markdown + "\n")
        }
        
        return .ok(
            .init(
                body: .json(
                    .init(
                        filename: part.filename ?? "unknown-ocr-attachment.pdf",
                        text: contents
                    )
                )
            )
        )
    }
        
    func getHealth(_ input: Operations.GetHealth.Input) async throws -> Operations.GetHealth.Output {
        .ok(
            .init(
                body: .json(
                    .init(
                        status: "Ok"
                    )
                )
            )
        )
    }
}
