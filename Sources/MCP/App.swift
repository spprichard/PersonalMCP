//
//  App.swift
//  API
//
//  Created by Steven Prichard on 2025-04-05.
//

import Foundation
import ArgumentParser

@main
struct App: AsyncParsableCommand {
    func run() async throws {
        let server = try MCPAPIServer(
            hostname: "localhost",
            port: 8081
        )
        
        try await server.run()
    }
    
}
