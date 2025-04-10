import Logging
import SwiftMCP
import Foundation
import Hummingbird
import ServiceLifecycle

import Email

public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
}

extension App {
    static let name = "api_server"

    package static func buildApplication(
        _ arguments: some AppArguments,
        environment: Environment
    ) async throws -> some ApplicationProtocol {
        let router = try App.buildRouter(environment)
        
        let emailServer = try EmailServerFactory.makeV1(on: router)
        try await emailServer.setup()

        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(
                    arguments.hostname,
                    port: arguments.port
                ),
                serverName: name
            ),
            // If feels like the "right" thing to do here is have the emailServer be
            // a service...
            services: [],
            logger: Self.buildLogger()
        )
        return app
    }
}

extension App {
    package static func buildLogger() -> Logger {
        Logger(label: App.name)
    }
}
