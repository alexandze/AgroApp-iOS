//
//  Field.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-27.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation

struct Field {
    var id: Int
    var type: String
    var culturalPratice: CulturalPractice?
    var polygon: [PolygonWithData<PayloadFieldAnnotation>]
    var annotation: [AnnotationWithData<PayloadFieldAnnotation>]
    var idPleinTerre: IdPleineTerre?
    var nim: NimSelectValue?

    func set(culturalPractice: CulturalPractice, of field: Field) -> Field {
        var copyField = field
        copyField.culturalPratice = culturalPractice
        return copyField
    }
    
    func isValid() -> Bool {
        isNimValid() &&
        isIdPleinTerreValid()
    }
    
    private func isNimValid() -> Bool {
        nim?.getIndexValueSelected() != nil
    }
    
    private func isIdPleinTerreValid() -> Bool {
        let count = idPleinTerre?.value.count
        return count != nil && count! > 0
    }
}
