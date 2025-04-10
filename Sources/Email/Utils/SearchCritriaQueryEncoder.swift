//
//  SearchCritriaQueryEncoder.swift
//  API
//
//  Created by Steven Prichard on 2025-04-10.
//

import SwiftMail
import Foundation

enum SearchCritriaQueryEncoder {
    typealias SimpleCriteria = String
    typealias SingleValueCriteria = Components.Schemas.SingleValueSearch
    
    static func encode(criteria: [SearchCriteria]) -> Components.Schemas.SearchCriteriaQuery {
        let simpleCriteria = encodeSimpleCriteria(from: criteria)
        let singleValueCriteria = encodeSingleValueCriteria(from: criteria)
        
        return Components.Schemas.SearchCriteriaQuery(
            simple: simpleCriteria,
            singleValue: singleValueCriteria
        )
    }
    
    private static func encodeSimpleCriteria(from criteria: [SearchCriteria]) -> [SimpleCriteria] {
        criteria.compactMap { searchCriteria in
            switch searchCriteria {
            case .all:
                return "all"
            case .answered:
                return "answered"
            case .flagged:
                return "flagged"
            case .deleted:
                return "deleted"
            case .draft:
                return "draft"
            case .new:
                return "new"
            case .old:
                return "old"
            case .recent:
                return "recent"
            case .seen:
                return "seen"
            case .unseen:
                return "unseen"
            default:
                return nil
            }
        }
    }
    
    private static func encodeSingleValueCriteria(from criteria: [SearchCriteria]) -> [SingleValueCriteria] {
        criteria.compactMap { searchCriteria in
            switch searchCriteria {
            case .before(let date):
                return .init(
                    criteriaType: .case1(.init(_type: .dateBefore)),
                    value: EmailServerV1.dateFormatter.string(from: date)
                )
            case .on(let date):
                return .init(
                    criteriaType: .case1(.init(_type: .dateOn)),
                    value: EmailServerV1.dateFormatter.string(from: date)
                )
            case .since(let date):
                return .init(
                    criteriaType: .case1(.init(_type: .since)),
                    value: EmailServerV1.dateFormatter.string(from: date)
                )
            case .sentOn(let date):
                return .init(
                    criteriaType: .case1(.init(_type: .since)),
                    value: EmailServerV1.dateFormatter.string(from: date)
                )
            case .body(let value):
                return .init(
                    criteriaType: .case1(.init(_type: .bodyContaining)),
                    value: value
                )
            case .from(let sender):
                return .init(
                    criteriaType: .case1(.init(_type: .from)),
                    value: sender
                )
            case .keyword(let value):
                return .init(
                    criteriaType: .case1(.init(_type: .keyword)),
                    value: value
                )
            case .subject(let value):
                return .init(
                    criteriaType: .case1(.init(_type: .subject)),
                    value: value
                )
            case .text(let value):
                return SingleValueCriteria(
                    criteriaType: .case1(.init(_type: .text)),
                    value: value
                )
            default:
                return nil
            }
        }
    }
}
