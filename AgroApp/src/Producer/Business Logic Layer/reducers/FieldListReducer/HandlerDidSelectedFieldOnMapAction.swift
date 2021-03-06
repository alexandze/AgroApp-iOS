//
//  HandlerDidSelectedFieldOnMapAction.swift
//  AgroApp
//
//  Created by Alexandre Andze Kande on 2020-08-04.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
extension FieldListReducerHandler {
    class HandlerDidSelectedFieldOnMapAction: HandlerReducer {

        func handle(
            action: MapFieldAction.WillSelectedFieldOnMapAction,
            _ state: FieldListState
        ) -> FieldListState {
            let util = UtilHandlerDidSelectedFieldOnMapAction(fieldFromAction: action.field, state: state)

            return (
                isFieldExist(util:) >>>
                    setNimSelectValueOfFieldSelectedWrapper(util: ) >>>
                    addFieldIfFieldNotExist(util:) >>>
                    newState(util:)
                )(util) ?? state
        }

        private func isFieldExist(util: UtilHandlerDidSelectedFieldOnMapAction?) -> UtilHandlerDidSelectedFieldOnMapAction? {
            guard let idField = util?.fieldFromAction.id,
                var newUtil = util
                else { return nil }

            guard let fieldList = util?.state.fieldList else {
                newUtil.newFieldList = []
                newUtil.isFieldExist = false
                return newUtil
            }

            newUtil.newFieldList = fieldList
            let indexFieldFind = newUtil.newFieldList?.firstIndex { $0.id == idField }

            guard let indexField = indexFieldFind else {
                newUtil.isFieldExist = false
                return newUtil
            }

            newUtil.isFieldExist = true
            newUtil.indexFieldFind = indexField
            return newUtil
        }
        
        private func setNimSelectValueOfFieldSelectedWrapper(
            util: UtilHandlerDidSelectedFieldOnMapAction?
        ) -> UtilHandlerDidSelectedFieldOnMapAction? {
            guard var newUtil = util else {
                return nil
            }
            
            guard let nimSelectValue = newUtil.state.nimSelectValue else {
                return newUtil
            }
            
            newUtil.fieldFromAction = setNimSelectValueOfFieldSelected(newUtil.fieldFromAction, nimSelectValue)
            return newUtil
        }
        
        private func setNimSelectValueOfFieldSelected(_ fieldSelected: Field, _ nimSelectValue: NimSelectValue) -> Field {
            var copyField = fieldSelected
            copyField.nim = nimSelectValue
            return copyField
        }

        private func addFieldIfFieldNotExist(util: UtilHandlerDidSelectedFieldOnMapAction?) -> UtilHandlerDidSelectedFieldOnMapAction? {
            guard var newUtil = util,
                let isFieldExist = newUtil.isFieldExist,
                !isFieldExist,
                let currentFieldArray = newUtil.newFieldList else { return nil }

            let firstArrayWithField = [newUtil.fieldFromAction]
            let newFieldList = firstArrayWithField + currentFieldArray
            newUtil.newFieldList = newFieldList
            return newUtil
        }

        private func newState(util: UtilHandlerDidSelectedFieldOnMapAction?) -> FieldListState? {
            guard let newUtil = util else { return nil }
            
            return newUtil
                .state
                .changeValue(
                    fieldList: newUtil.newFieldList,
                    currentField: newUtil.fieldFromAction,
                    subAction: .selectedFieldOnMapActionSuccess
            )
        }
    }

    private struct UtilHandlerDidSelectedFieldOnMapAction {
        var fieldFromAction: Field
        var state: FieldListState
        var isFieldExist: Bool?
        var newFieldList: [Field]?
        var indexFieldFind: Int?
    }
}
