//
//  OCRServerFactory.swift
//  API
//
//  Created by Steven Prichard on 2025-04-15.
//

import Foundation
import EmailAPI
import Hummingbird
//import OpenAPIRuntime
//import ServiceLifecycle
//import OpenAPIHummingbird

public enum OCRServerFactory {
    @discardableResult
    public static func makeMistralOCRServer(on router: Router<BasicRequestContext>) throws -> APIProtocol {
        let server = OCRServerV1(
            emailProvider: try EmailClient(),
            ocrProviding: MistralOCRProvider(
                api: try MistralAPIFactory.make()
            )
        )
        
        print("@@: \(URL.defaultOpenAPIServerURL)")
        
        try server.registerHandlers(on: router)
        
        return server
    }
}
