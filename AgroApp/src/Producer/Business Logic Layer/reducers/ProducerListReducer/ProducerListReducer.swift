//
//  ProducerListReducer.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-01.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import ReSwift

extension Reducers {
    public static func producerListReducer(action: Action, state: ProducerListState?) -> ProducerListState {
        var state = state ?? ProducerListState(uuidState: UUID().uuidString)

        switch action {
        case let successGetFamers as ProducerListAction.GetProducerListSuccesAction:
            break
        default:
            break
        }
        
        return state
    }
}
