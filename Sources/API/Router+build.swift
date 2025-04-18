//
//  Router+Build.swift
//  API
//
//  Created by Steven Prichard on 2025-04-03.
//

import Logging
import Hummingbird
import OpenAPIHummingbird

// Request context used by application
typealias AppRequestContext = BasicRequestContext

extension App {
    /// Build router
    static func buildRouter(
        _ environment: Environment,
    ) throws -> Router<AppRequestContext> {
        
        let router = Router(context: AppRequestContext.self)
        // Add middleware
        router.addMiddleware {
            LogRequestsMiddleware(.info)
        }
        
        return router
    }
}
