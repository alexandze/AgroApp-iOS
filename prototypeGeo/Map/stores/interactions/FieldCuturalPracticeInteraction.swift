//
//  FieldCuturalPracticeInteraction.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-03-01.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation

class FieldCulturalPracticeInteractionImpl: FieldCulturalPracticeInteraction  {
    let actionDispatcher: ActionDispatcher
    
    // MARK: - Methods
    init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }
}

protocol FieldCulturalPracticeInteraction  {
    
}
