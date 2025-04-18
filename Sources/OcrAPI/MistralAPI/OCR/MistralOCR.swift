//
//  MistralOCRServer.swift
//  API
//
//  Created by Steven Prichard on 2025-04-12.
//

import Foundation

protocol OCRProviding: Sendable {
    // TODO: Refactor `OCRResponse` to be not tightly coupled to Mistral API
    func ocr(fileData: Data) async throws -> OCRResponse
}

actor MistralOCRProvider: OCRProviding {
    let api: MistralAPIClient
    
    public init(api: MistralAPIClient) {
        self.api = api
    }
    
    public func ocr(fileData: Data) async throws -> OCRResponse {
        let uploadResult = try await upload(fileName: "test.pdf", data: fileData)
        print("ℹ️ File updated: ID - \(uploadResult.id)")
        
        let signedURL = try await api.signedURL(for: uploadResult.id)
        print("ℹ️ Signed URL: \(signedURL.url)")
        
        return try await api.ocr(
            type: .document(
                url: signedURL.url
            )
        )
    }
    
    func upload(fileName: String, data: Data) async throws -> UploadFileResponse {
        let file = MistralAPIClient.FileClient.File(
            name: fileName,
            type: .pdf,
            data: data
        )
        
        return try await api.upload(file)
    }
}

extension MistralOCRProvider {
    enum Errors: Error {
        case messageDataParsingFailed
        case missingMessageData
        case base64DecodingFailure
        case unsupportedContentType
    }
}

