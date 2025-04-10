import Logging
import Hummingbird
import ArgumentParser

@main
struct App: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        let environment = try await Environment().merging(with: .dotEnv())
        
        
        let app = try await App.buildApplication(self, environment: environment)
        try await app.runService()
    }
}
