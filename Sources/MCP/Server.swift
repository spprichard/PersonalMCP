//
//  Server.swift
//  API
//
//  Created by Steven Prichard on 2025-04-05.
//

import Email
import SwiftMCP
import SwiftMail

@MCPServer(name: "MCPServer", version: "0.0.1")
actor MCPAPIServer {
    private let emailAPI: EmailClient
    let hostname: String
    let port: Int

    init(hostname: String, port: Int) throws {
        self.hostname = hostname
        self.port = port
        self.emailAPI = try EmailClient()
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
    
    @MCPTool(description: "Fetches emails with PDF attachments")
    func fetchMessagesContainingPDFAttachment(in mailbox: String) async throws -> [MessageInfo] {
        let messages = try await emailAPI.search(
            mailbox: mailbox,
            with: [.text(".pdf")]
        )
        
        return messages
    }
}
