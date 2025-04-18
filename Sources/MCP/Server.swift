//
//  Server.swift
//  API
//
//  Created by Steven Prichard on 2025-04-05.
//

import Email
import SwiftMCP
import SwiftMail
import MistralKit

@MCPServer(name: "MCPServer", version: "0.0.1")
actor MCPAPIServer {
    private let emailAPI: EmailClient
    private let ocrAPI: MistralOCRServer
    
    let hostname: String
    let port: Int

    init(hostname: String, port: Int) throws {
        self.hostname = hostname
        self.port = port
        self.emailAPI = try EmailClient()
        let mistralAPI = try MistralAPIFactory.make()
        self.ocrAPI = MistralOCRServer(api: mistralAPI)
    }
    
    func run() async throws {
        let transport = HTTPSSETransport(
            server: self,
            host: hostname,
            port: port
        )
        transport.serveOpenAPI = true

        // Set up signal handling to shut down the transport on Ctrl+C
        let signalHandler = SignalHandler(transport: transport)
        await signalHandler.setup()

        // Run the server (blocking)
        try await transport.run()
    }

    @MCPTool(description: "Ping the MCP API Server")
    func ping() async throws -> String {
        return "Pong!"
    }
    @MCPTool(description: "Send a greeting to a provided name")
    func greet(name: String) -> String {
        "Hello, \(name)!"
    }
    
    @MCPTool(description: "Returns the current health status of the API")
    func health() async throws -> String {
        let result = try await emailAPI.health()
        switch result {
        case .ok(let status):
            return try status.body.json.status
        case .undocumented(let statusCode, _):
            return "Failed with status code: \(statusCode)"
        }
    }
    
    @MCPTool(description: "Fetches unseen emails from a specified mailbox")
    func fetchUnseenEmail(in mailbox: String) async throws -> String {
        let messages = try await emailAPI.search(
            mailbox: mailbox,
            with: [.unseen]
        )
        return "✅ Found \(messages.count) unseen email(s)"
    }
    
    @MCPTool(description: "Fetches emails with PDF attachments, from provided mailbox")
    func fetchMessagesContainingPDFAttachment(in mailbox: String) async throws -> [Components.Schemas.EmailMessage] {
        let messages = try await emailAPI.search(
            mailbox: mailbox,
            with: [.text(".pdf")]
        )
        
        return messages
    }
    
    @MCPTool(description: "Performs Optical Character Recognition (OCR) on message in mailbox")
    func performOCR() async throws -> String {
        
        //guard messagePart.contentType == "application/pdf" else {
        //    throw Errors.unsupportedContentType
        //}
        //
        //guard let messageContent = messagePart.data else {
        //    throw Errors.missingMessageData
        //}
        //
        //print("ℹ️ messageContent: \n\(messageContent)")
        //
        //guard let base64EncodedData = messageContent.data(using: .utf8) else {
        //    throw Errors.messageDataParsingFailed
        //}
        //
        //guard let decodedData = Data(base64Encoded: base64EncodedData, options: [.ignoreUnknownCharacters]) else {
        //    throw Errors.base64DecodingFailure
        //}
        //
        //print("ℹ️ decodedData Content: \n\(String(data: decodedData, encoding: .utf8))")

        
        
        
        
        guard let message = try await emailAPI.search(
            mailbox: "Receipts",
            with: [
                .text("Strive")
            ])
            .first else {
            return "NO EMAIL FOUND"
        }
        
        guard let part = message.parts
            .first(where: { $0.contentType == "application/pdf" })
        else  {
            return "NO PDF ATTACHMENT FOUND"
        }
        
        let ocrResponse = try await ocrAPI.ocr(messagePart: part)
        
        var contents: String = ""
        for page in ocrResponse.pages {
            contents.append(page.markdown + "\n")
        }
        
        return .init(contents)
    }
}
