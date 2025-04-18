//
//  OCRAPIClient.swift
//  API
//
//  Created by Steven Prichard on 2025-04-15.
//

import OpenAPIAsyncHTTPClient

public struct OcrAPIClient: Sendable {
    let client: Client
    
    enum Errors: Error {
        case undocumented(statusCode: Int)
    }
    
    public init() throws {
        let url = try Servers.Server1.url()
        
        self.client = .init(
            serverURL: url,
            transport: AsyncHTTPClientTransport()
        )
    }
    
    
    public func health() async throws -> String {
        let result = try await client.getHealth(.init())
        
        switch result {
        case .ok(let payload):
            return try payload.body.json.status
        case .undocumented(let statusCode, _):
            throw Errors.undocumented(statusCode: statusCode)
        }
    }
    
    // Currently just used for testing
    public func performOCR() async throws {
//        try await client.performOCR(
//            .init(
//                headers: .init(accept: .init()),
//                body: .json(.init(filename: "test.pdf"))
//            )
//        )
    }
    
}
