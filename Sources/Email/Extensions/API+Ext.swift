//
//  API+Ext.swift
//  API
//
//  Created by Steven Prichard on 2025-04-11.
//

import SwiftMail
import Foundation

extension String {
    func searchCriteria() throws -> SearchCriteria {
        switch self {
        case "all":
            return .all
        case "answered":
            return .answered
        case "flagged":
            return .flagged
        case "deleted":
            return .deleted
        case "draft":
            return .draft
        case "new":
            return .new
        case "old":
            return .old
        case "recent":
            return .recent
        case "seen":
            return .seen
        case "unseen":
            return .unseen
        default:
            throw SearchCriteriaErrors.unsupportedSearchCriteria
        }
    }
}



extension Components.Schemas.SingleValueSearch {
    func searchCriteria() throws -> SearchCriteria {
        switch self.criteriaType {
        case .case1(let payload):
            switch payload._type {
            case .dateBefore:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .before(date)
            case .dateOn:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .on(date)
            case .since:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .since(date)
            case .sentOn:
                guard let date = EmailServerV1.dateFormatter.date(from: value) else {
                    throw SearchCriteriaErrors.dateDecodingFailed
                }
                return .sentOn(date)
            case .text:
                return .text(self.value)
            case .bodyContaining:
                return .body(value)
            case .from:
                return .from(value)
            case .keyword:
                return .keyword(value)
            case .subject:
                return .subject(value)
            }
        }
    }
}

extension Components.Schemas.SearchCriteriaQuery {
    func toSearchCriteria() throws -> [SearchCriteria] {
        var criteria: [SearchCriteria] = []
        
        if !self.simple.isEmpty {
            criteria.append(contentsOf: try self.simple.map { try $0.searchCriteria() })
        }
        
        if !self.singleValue.isEmpty {
            criteria.append(contentsOf: try singleValue.map { try $0.searchCriteria() })
        }

        return criteria
    }
}

