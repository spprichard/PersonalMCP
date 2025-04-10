//
//  SearchCritriaQueryDecoder.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import SwiftMail
import Foundation

enum SearchCritriaQueryDecoder {
    static func decode(_ input: Components.Schemas.SearchCriteriaQuery) throws -> [SearchCriteria] {
        try input.toSearchCriteria()
    }
}
